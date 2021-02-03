#include "card_manager.hpp"
#include "smbus.hpp"

#include <filesystem>
#include <map>
#include <nlohmann/json.hpp>
#include <phosphor-logging/elog-errors.hpp>
#include <phosphor-logging/log.hpp>
#include <sdbusplus/message.hpp>
#include <sstream>
#include <string>

#define MONITOR_INTERVAL_SECONDS 1
static constexpr auto configFile = "/etc/ocp/ocp_config.json";
static constexpr auto delay = std::chrono::milliseconds{100};
using Json = nlohmann::json;

/* This is OCP 2.0 offset specification */
#define I2C_NIC_ADDR						0x1f
#define I2C_NIC_SENSOR_TEMP_REG				0x01
#define I2C_NIC_SENSOR_DEVICE_ID_LOW_REG	0xFF
#define I2C_NIC_SENSOR_DEVICE_ID_HIGH_REG	0xF1
#define I2C_NIC_SENSOR_MFR_ID_HIGH_REG		0xF0
#define I2C_NIC_SENSOR_MFR_ID_LOW_REG		0xFE

namespace fs = std::filesystem;

namespace phosphor
{
namespace nic
{
using namespace std;
using namespace phosphor::logging;

static std::vector<CardManager::PcieCard> supported = {
    {0x8119, 0x1017, "Mellanox Technologies MT27800 Family [ConnectX-5]"}
};

void CardManager::setCardInventoryProperties(
    bool present, const phosphor::nic::CardManager::CardData& cardData,
    const std::string& inventoryPath)
{
    util::SDBusPlus::setProperty(bus, INVENTORY_BUSNAME, inventoryPath,
                                 ITEM_IFACE, "Present", present);

    util::SDBusPlus::setProperty(bus, INVENTORY_BUSNAME, inventoryPath,
                                 ASSET_IFACE, "Model", cardData.name);

    util::SDBusPlus::setProperty(bus, INVENTORY_BUSNAME, inventoryPath,
                                 OPERATIONAL_STATUS_INTF, "Functional",
                                 cardData.functional);
}

/** @brief Get info over i2c */
bool CardManager::getCardInfobyBusID(
    CardConfig& config, phosphor::nic::CardManager::CardData& cardData)
{
    phosphor::smbus::Smbus smbus;
    static std::unordered_map<int, bool> isErrorSmbus;
    int ret = 0;

    cardData.name = "Unknown";
    cardData.present = false;
    cardData.functional = false;
    cardData.sensorValue = 0;

    auto init = smbus.smbusInit(config.busID);
    if (init == -1)
    {
        if (isErrorSmbus[config.busID] != true)
        {
            log<level::ERR>("smbusInit fail!");
        }
        return false;
    }

    try
    {
        /* Switch the mux */
        ret = smbus.smbusMuxToChan(config.busID, config.muxAddress,
                                   config.channelId);
        if (ret < 0)
        {
            log<level::ERR>("set the mux failed!");
            return false;
        }

        /* Read card vendor and card id */
        uint8_t mfrIdHigh = smbus.smbusReadByteData(
            config.busID, I2C_NIC_ADDR, I2C_NIC_SENSOR_MFR_ID_HIGH_REG);

        uint8_t mfrIdLow = smbus.smbusReadByteData(
            config.busID, I2C_NIC_ADDR, I2C_NIC_SENSOR_MFR_ID_LOW_REG);
        /* Manufacture id is 2 bytes */
        auto mfrId = mfrIdLow | (mfrIdHigh << 8);

        /* Read device id */
        uint8_t devIdHigh = smbus.smbusReadByteData(
            config.busID, I2C_NIC_ADDR, I2C_NIC_SENSOR_DEVICE_ID_HIGH_REG);
        uint8_t devIdLow = smbus.smbusReadByteData(
            config.busID, I2C_NIC_ADDR, I2C_NIC_SENSOR_DEVICE_ID_LOW_REG);
        auto deviceId = devIdLow | (devIdHigh << 8);

        auto result = std::find_if(
            supported.begin(), supported.end(),
            [deviceId, mfrId](CardManager::PcieCard card) {
                return (card.deviceID == deviceId && card.vendorID == mfrId);
            });

        /* Found supported card */
        if (result != supported.end())
        {
            uint8_t value = smbus.smbusReadByteData(config.busID, I2C_NIC_ADDR,
                                                    I2C_NIC_SENSOR_TEMP_REG);
            if (value != 0xff)
            {
                cardData.present = true;
                cardData.sensorValue = value;
                cardData.deviceId = deviceId;
                cardData.mfrId = mfrId;
                cardData.name = result->deviceName;
                cardData.functional = true;
            }
        }
    }
    catch (const std::exception& e)
    {
        log<level::ERR>("Json Exception caught."), entry("MSG: %s", e.what());
        return false;
    }

    /* Done, close the bus */
    smbus.smbusClose(config.busID);

    return true;
}

void CardManager::run()
{
    init();

    std::function<void()> callback(std::bind(&CardManager::read, this));
    try
    {
        u_int64_t interval = MONITOR_INTERVAL_SECONDS * 1000000;
        _timer.restart(std::chrono::microseconds(interval));
    }
    catch (const std::exception& e)
    {
        log<level::ERR>("Error in polling loop. "),
            entry("ERROR = %s", e.what());
    }
}

/** @brief Parsing Card config JSON file  */
Json parseSensorConfig()
{
    std::ifstream jsonFile(configFile);
    if (!jsonFile.is_open())
    {
        log<level::ERR>("Card config JSON file not found");
    }

    auto data = Json::parse(jsonFile, nullptr, false);
    if (data.is_discarded())
    {
        log<level::ERR>("Card config readings JSON parser failure");
    }

    return data;
}

/** @brief Obtain the initial configuration value of Card  */
std::vector<phosphor::nic::CardManager::CardConfig> CardManager::getCardConfig()
{
    phosphor::nic::CardManager::CardConfig cardConfig;
    std::vector<phosphor::nic::CardManager::CardConfig> cardConfigs;
    int8_t criticalHigh = 0;
    int8_t criticalLow = 0;
    int8_t maxValue = 0;
    int8_t minValue = 0;
    int8_t warningHigh = 0;
    int8_t warningLow = 0;

    try
    {
        auto data = parseSensorConfig();
        static const std::vector<Json> empty{};
        std::vector<Json> readings = data.value("config", empty);
        std::vector<Json> thresholds = data.value("threshold", empty);
        if (!thresholds.empty())
        {
            for (const auto& instance : thresholds)
            {
                criticalHigh = instance.value("criticalHigh", 0);
                criticalLow = instance.value("criticalLow", 0);
                maxValue = instance.value("maxValue", 0);
                minValue = instance.value("minValue", 0);
                warningHigh = instance.value("warningHigh", 0);
                warningLow = instance.value("warningLow", 0);
            }
        }
        else
        {
            log<level::ERR>(
                "Invalid Card config file, thresholds dosen't exist");
        }

        if (!readings.empty())
        {
            for (const auto& instance : readings)
            {
                uint8_t index = instance.value("Index", 0);
                int busID = instance.value("BusId", 0);

                std::string channelId =
                    instance["ChannelId"].get<std::string>();
                std::string slaveAddr =
                    instance["SlaveAddress"].get<std::string>();
                std::string muxAddr = instance["MuxAddress"].get<std::string>();

                cardConfig.index = std::to_string(index);
                cardConfig.busID = busID;

                cardConfig.channelId = std::strtoul(channelId.c_str(), 0, 16);
                cardConfig.muxAddress = std::strtoul(muxAddr.c_str(), 0, 16);
                cardConfig.slaveAddress =
                    std::strtoul(slaveAddr.c_str(), 0, 16);

                cardConfig.criticalHigh = criticalHigh;
                cardConfig.criticalLow = criticalLow;
                cardConfig.warningHigh = warningHigh;
                cardConfig.warningLow = warningLow;
                cardConfig.maxValue = maxValue;
                cardConfig.minValue = minValue;

                cardConfigs.push_back(cardConfig);
            }
        }
        else
        {
            log<level::ERR>("Invalid Card config file, config dosen't exist");
        }
    }
    catch (const Json::exception& e)
    {
        log<level::ERR>("Json Exception caught."), entry("MSG: %s", e.what());
    }

    return cardConfigs;
}

void CardManager::createCardInventory()
{
    using Properties = std::map<std::string, std::variant<std::string, bool>>;
    using Interfaces = std::map<std::string, Properties>;

    std::string inventoryPath;
    std::map<sdbusplus::message::object_path, Interfaces> obj;

    for (const auto config : configs)
    {
        inventoryPath = "/system/chassis/motherboard/card" + config.index;

        obj = {{
            inventoryPath,
            {{ITEM_IFACE, {}}, {OPERATIONAL_STATUS_INTF, {}}, {ASSET_IFACE, {}}},
        }};
        util::SDBusPlus::CallMethod(bus, INVENTORY_BUSNAME, INVENTORY_NAMESPACE,
                                    INVENTORY_MANAGER_IFACE, "Notify", obj);
    }
}

void CardManager::init()
{
    createCardInventory();
}

void CardManager::readCardData(CardConfig& config)
{
    std::string inventoryPath = CARD_INVENTORY_PATH + config.index;
    CardData cardData;

    // get card information through i2c by busID.
    auto success = getCardInfobyBusID(config, cardData);
    auto iter = cards.find(config.index);

    if (iter == cards.end())
    {
        std::string objPath = CARD_OBJ_PATH + config.index;
        auto card =
            std::make_shared<phosphor::nic::Nic>(bus, objPath.c_str());
        cards.emplace(config.index, card);

        setCardInventoryProperties(cardData.present, cardData, inventoryPath);
        card->setSensorValueToDbus(cardData.sensorValue);
    }
    else
    {
        setCardInventoryProperties(cardData.present, cardData, inventoryPath);
        iter->second->setSensorValueToDbus(cardData.sensorValue);
    }

}

/** @brief Monitor every one second  */
void CardManager::read()
{
    std::string inventoryPath;

    for (auto config : configs)
    {
        /* set default for each config */
        CardData cardData = CardData();
        inventoryPath = CARD_INVENTORY_PATH + config.index;
        setCardInventoryProperties(false, cardData, inventoryPath);
        cards.erase(config.index);

        readCardData(config);
    }
}
} // namespace nic
} // namespace phosphor
