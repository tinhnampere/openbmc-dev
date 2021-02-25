#include "card_manager.hpp"
#include "smbus.hpp"

#include <filesystem>
#include <map>
#include <phosphor-logging/elog-errors.hpp>
#include <phosphor-logging/log.hpp>
#include <sdbusplus/message.hpp>
#include <sstream>
#include <string>

#define MONITOR_INTERVAL_SECONDS 5
static constexpr auto configFile = "/etc/card/config.json";

/* This is OCP 2.0 offset specification */
#define I2C_NIC_ADDR                            0x1f
#define I2C_NIC_SENSOR_TEMP_REG                 0x01
#define I2C_NIC_SENSOR_DEVICE_ID_LOW_REG        0xFF
#define I2C_NIC_SENSOR_DEVICE_ID_HIGH_REG       0xF1
#define I2C_NIC_SENSOR_MFR_ID_HIGH_REG          0xF0
#define I2C_NIC_SENSOR_MFR_ID_LOW_REG           0xFE

/* This is NVME specification */
#define NVME_SSD_SLAVE_ADDRESS                  0x6a
#define NVME_TEMP_REG                           0x3
#define NVME_VENDOR_REG                         0x9
#define NVME_SERIAL_NUM_REG                     0x0b
#define NVME_SERIAL_NUM_SIZE                    20

/* PCIe-SIG Vendor ID Code*/
#define VENDOR_ID_HGST                          0x1C58
#define VENDOR_ID_HYNIX                         0x1C5C
#define VENDOR_ID_INTEL                         0x8086
#define VENDOR_ID_LITEON                        0x14A4
#define VENDOR_ID_MICRON                        0x1344
#define VENDOR_ID_SAMSUNG                       0x144D
#define VENDOR_ID_SEAGATE                       0x1BB1
#define VENDOR_ID_TOSHIBA                       0x1179
#define VENDOR_ID_FACEBOOK                      0x1D9B
#define VENDOR_ID_BROARDCOM                     0x14E4
#define VENDOR_ID_QUALCOMM                      0x17CB
#define VENDOR_ID_SSSTC                         0x1E95

/* static variables */
static constexpr int SERIALNUMBER_START_INDEX   = 3;
static constexpr int SERIALNUMBER_END_INDEX     = 23;

namespace fs = std::filesystem;

namespace phosphor
{
namespace nic
{
using namespace std;
using namespace phosphor::logging;

static int nvmeMaxTemp = 0;
static const std::string nvmeMaxTempName = "_max";

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

    if (!present)
    {
        std::string serial = "";
        util::SDBusPlus::setProperty(bus, INVENTORY_BUSNAME, inventoryPath,
                                     ASSET_IFACE, "SerialNumber", serial);
    }
    else if (!cardData.serial.empty())
    {
        auto serial_str = nvmeSerialFormat(cardData.serial);
        util::SDBusPlus::setProperty(bus, INVENTORY_BUSNAME, inventoryPath,
                                     ASSET_IFACE, "SerialNumber", serial_str);
    }
}

/** @brief Get info over i2c */
bool CardManager::getCardInfobyBusID(
    CardConfig& config, phosphor::nic::CardManager::CardData& cardData)
{
    phosphor::smbus::Smbus smbus;
    static std::unordered_map<int, bool> isErrorSmbus;
    int ret = 0;

    cardData.name = "Unknown OCP card";
    cardData.present = false;
    cardData.functional = false;
    cardData.sensorValue = 0;
    cardData.serial = {};

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
        for (const auto& mux : config.muxes)
        {
            ret = smbus.smbusMuxToChan(config.busID, mux.first, 1 << mux.second);
            if (ret < 0)
            {
                goto error;
            }
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
        goto error;
    }

    /* Done, close the bus */
    smbus.smbusClose(config.busID);
    return true;

error:
    /* Close the bus */
    smbus.smbusClose(config.busID);
    return false;

}

/** @brief Get NVMe info over smbus  */
bool CardManager::getNVMeInfobyBusID(
    CardConfig& config, phosphor::nic::CardManager::CardData& cardData)
{
    static std::unordered_map<int, bool> isErrorSmbus;
    phosphor::smbus::Smbus smbus;
    int ret = 0;
    std::vector<uint8_t> tmp;
    uint8_t temp = 0;

    cardData.name = "";
    cardData.present = false;
    cardData.functional = false;
    cardData.sensorValue = 0;
    cardData.serial = {};

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
        for (const auto& mux : config.muxes)
        {
            ret = smbus.smbusMuxToChan(config.busID, mux.first, 1 << mux.second);
            if (ret < 0)
            {
                goto error;
            }
        }

        /* Read NVME temp data */
        auto tempValue = smbus.smbusReadByteData(config.busID, NVME_SSD_SLAVE_ADDRESS,
                                       NVME_TEMP_REG);
        if (tempValue < 0)
        {
            goto error;
        }

        /* Read VendorID 2 bytes 9-10 */
        int value = smbus.smbusReadWordData(
            config.busID, NVME_SSD_SLAVE_ADDRESS, NVME_VENDOR_REG);

        if (value < 0)
        {
            goto error;
        }
        int vendorId = (value & 0xFF00) >> 8 | (value & 0xFF) << 8;

        /* Read SerialID 20 bytes 11-31 */
        for (int count = 0; count < NVME_SERIAL_NUM_SIZE; count++)
        {
            temp = smbus.smbusReadByteData(config.busID, NVME_SSD_SLAVE_ADDRESS,
                                           NVME_SERIAL_NUM_REG + count);
            if (temp < 0)
            {
                goto error;
            }
            tmp.emplace_back(temp);
        }

        if (vendorId > 0)
        {
            cardData.name = nvmeNameFormat(vendorId);
            cardData.present = true;
            cardData.functional = true;
            cardData.sensorValue = tempValue;
            cardData.mfrId = vendorId;
            cardData.serial.insert(cardData.serial.end(), tmp.begin(), tmp.end());

            /* Update the NVME maximum temp value */
            if (tempValue > nvmeMaxTemp)
            {
                nvmeMaxTemp = tempValue;
            }
        }
    }
    catch (const std::exception& e)
    {
        goto error;
    }

    /* switch the mux back */
    for (auto it = config.muxes.rbegin(); it != config.muxes.rend(); ++it)
    {
        ret = smbus.smbusMuxToChan(config.busID, it->first, 0);
        if (ret < 0)
        {
            goto error;
        }
    }

    /* Done, close the bus */
    smbus.smbusClose(config.busID);
    return true;

error:
    smbus.smbusClose(config.busID);
    return false;
}

std::string CardManager::nvmeSerialFormat(std::vector<uint8_t> serial)
{
    std::stringstream ss;
    ss.str("");
    if (!serial.empty())
    {
        for (auto it = serial.begin(); it != serial.end(); it++)
        {
            ss << *it;
        }
    }

    return ss.str();
}

std::string CardManager::nvmeNameFormat(uint16_t vendorId)
{
    std::stringstream ss;
    ss.str("");

    switch (vendorId)
    {
        case VENDOR_ID_HGST:
            ss << "HGST (" << std::hex << std::setw(4) << std::setfill('0')
               << vendorId << ")";
            break;
        case VENDOR_ID_HYNIX:
            ss << "Hynix (" << std::hex << std::setw(4) << std::setfill('0')
               << vendorId << ")";
            break;
        case VENDOR_ID_INTEL:
            ss << "Intel (" << std::hex << std::setw(4) << std::setfill('0')
               << vendorId << ")";
            break;
        case VENDOR_ID_LITEON:
            ss << "Lite-on (" << std::hex << std::setw(4) << std::setfill('0')
               << vendorId << ")";
            break;
        case VENDOR_ID_MICRON:
            ss << "Micron (" << std::hex << std::setw(4) << std::setfill('0')
               << vendorId << ")";
            break;
        case VENDOR_ID_SAMSUNG:
            ss << "Samsung (" << std::hex << std::setw(4) << std::setfill('0')
               << vendorId << ")";
            break;
        case VENDOR_ID_SEAGATE:
            ss << "Seagate (" << std::hex << std::setw(4) << std::setfill('0')
               << vendorId << ")";
            break;
        case VENDOR_ID_TOSHIBA:
            ss << "Toshiba (" << std::hex << std::setw(4) << std::setfill('0')
               << vendorId << ")";
            break;
        case VENDOR_ID_FACEBOOK:
            ss << "Facebook (" << std::hex << std::setw(4) << std::setfill('0')
               << vendorId << ")";
            break;
        case VENDOR_ID_BROARDCOM:
            ss << "Broadcom (" << std::hex << std::setw(4) << std::setfill('0')
               << vendorId << ")";
            break;
        case VENDOR_ID_QUALCOMM:
            ss << "Qualcomm (" << std::hex << std::setw(4) << std::setfill('0')
               << vendorId << ")";
            break;
        case VENDOR_ID_SSSTC:
            ss << "SSSTC (" << std::hex << std::setw(4) << std::setfill('0')
               << vendorId << ")";
            break;
        default:
            ss << "Unknown (" << std::hex << std::setw(4) << std::setfill('0')
               << vendorId << ")";
            break;
    }

    return ss.str();
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
std::vector<phosphor::nic::CardManager::CardConfig>
    CardManager::getConfig()
{
    std::vector<phosphor::nic::CardManager::CardConfig> cardConfigs;

    try
    {
        auto data = parseSensorConfig();
        static const std::vector<Json> empty{};

        /* Read and parse 'ocp' config */
        std::vector<Json> readings = data.value("ocp", empty);
        parseConfig(readings, OCP, cardConfigs);

        /* Read and parse 'nmve' config */
        readings = data.value("nvme", empty);
        parseConfig(readings, NVME, cardConfigs);
    }
    catch (const Json::exception& e)
    {
        log<level::ERR>("Json Exception caught."), entry("MSG: %s", e.what());
    }

    return cardConfigs;
}

void CardManager::parseConfig(
    std::vector<Json> readings, phosphor::nic::CardManager::CardType type,
    std::vector<phosphor::nic::CardManager::CardConfig>& cardConfigs)
{
    static const std::vector<Json> empty{};

    if (!readings.empty())
    {
        for (const auto& instance : readings)
        {
            phosphor::nic::CardManager::CardConfig cardConfig;
            uint8_t index = instance.value("Index", 0);

            int busID = instance.value("BusId", 0);
            cardConfig.index = std::to_string(index);
            cardConfig.busID = busID;
            cardConfig.type = type;
            cardConfig.id = std::to_string(type) + "_" + std::to_string(index);

            std::vector<Json> muxes = instance.value("Muxes", empty);
            if (!muxes.empty())
            {
                for (const auto& mux : muxes)
                {
                    std::string muxAddr = mux["MuxAddress"].get<std::string>();
                    std::string channelId = mux["Channel"].get<std::string>();

                    uint8_t address = std::strtoul(muxAddr.c_str(), 0, 16) & 0xFF;
                    int channel = std::strtoul(channelId.c_str(), 0, 16) & 0xFF;
                    auto p = std::make_pair(address, channel);

                    cardConfig.muxes.push_back(p);
                }
            }

            cardConfigs.push_back(cardConfig);
        }
    }
}

void CardManager::createCardInventory()
{
    using Properties = std::map<std::string, std::variant<std::string, bool>>;
    using Interfaces = std::map<std::string, Properties>;

    std::string inventoryPath;
    std::map<sdbusplus::message::object_path, Interfaces> obj;

    for (const auto config : configs)
    {
        if (config.type == OCP)
        {
            inventoryPath = "/system/chassis/motherboard/card" + config.index;
        }
        else if (config.type == NVME)
        {
            inventoryPath = "/system/chassis/motherboard/nvme" + config.index;
        }

        obj = {{ inventoryPath, {{ITEM_IFACE, {}}, {OPERATIONAL_STATUS_INTF, {}},
                {ASSET_IFACE, {}}},
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
    std::string inventoryPath;
    std::string objPath;
    CardData cardData;
    bool success = 0;

    if (config.type == OCP)
    {
        inventoryPath = CARD_INVENTORY_PATH + config.index;
        objPath = CARD_OBJ_PATH + config.index;
        success = getCardInfobyBusID(config, cardData);
    }
    else if (config.type == NVME)
    {
        inventoryPath = NVME_INVENTORY_PATH + config.index;
        objPath = NVME_OBJ_PATH + config.index;

        success = getNVMeInfobyBusID(config, cardData);
    }

    if (success && cardData.present)
    {
        auto result = cards.find(config.id);

        if (result == cards.end())
        {
            auto card =
                std::make_shared<phosphor::nic::Nic>(bus, objPath.c_str());
            cards.emplace(config.id, card);

            setCardInventoryProperties(cardData.present, cardData,
                                       inventoryPath);
            card->setSensorValueToDbus(cardData.sensorValue);
        }
        else
        {
            setCardInventoryProperties(cardData.present, cardData,
                                       inventoryPath);
            result->second->setSensorValueToDbus(cardData.sensorValue);
        }
    }
    else
    {
        cards.erase(config.id);
    }
}

void CardManager::nvmeMaxTempSensor()
{
    std::string objPath;
    std::string sensorName;

    sensorName = std::to_string(NVME) + nvmeMaxTempName;
    auto result = cards.find(sensorName);
    if (result == cards.end())
    {
        objPath = NVME_OBJ_PATH + nvmeMaxTempName;
        auto card = std::make_shared<phosphor::nic::Nic>(bus, objPath.c_str());

        cards.emplace(sensorName, card);
        card->setSensorValueToDbus(nvmeMaxTemp);
    }
    else
    {
        result->second->setSensorValueToDbus(nvmeMaxTemp);
    }
}

/** @brief Monitor every one second  */
void CardManager::read()
{
    nvmeMaxTemp = 0;
    for (auto config : configs)
    {
        std::string inventoryPath;

        /* set default for each config */
        if (config.type == OCP)
        {
            inventoryPath = CARD_INVENTORY_PATH + config.index;
        }
        else if (config.type == NVME)
        {
            inventoryPath = NVME_INVENTORY_PATH + config.index;
        }

        CardData cardData = CardData();
        cardData.name = "";
        cardData.present = false;
        cardData.functional = false;
        cardData.sensorValue = 0;
        cardData.serial = {};

        setCardInventoryProperties(false, cardData, inventoryPath);
        readCardData(config);

        /* Update nvme max temp sensor */
        nvmeMaxTempSensor();
    }
}
} // namespace nic
} // namespace phosphor
