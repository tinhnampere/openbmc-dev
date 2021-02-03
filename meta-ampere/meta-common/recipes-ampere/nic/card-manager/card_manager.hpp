#pragma once

#include "config.h"
#include "cards.hpp"
#include "sdbusplus.hpp"

#include <fstream>
#include <sdbusplus/bus.hpp>
#include <sdbusplus/server.hpp>
#include <sdbusplus/server/object.hpp>
#include <sdeventplus/clock.hpp>
#include <sdeventplus/event.hpp>
#include <sdeventplus/utility/timer.hpp>

namespace phosphor
{
namespace nic
{

/** @class CardManager
 *  @brief CardManager manager implementation.
 */
class CardManager
{
  public:
    CardManager() = delete;
    CardManager(const CardManager&) = delete;
    CardManager& operator=(const CardManager&) = delete;
    CardManager(CardManager&&) = delete;
    CardManager& operator=(CardManager&&) = delete;

    /** @brief Constructs CardManager
     *
     * @param[in] bus     - Handle to system dbus
     * @param[in] objPath - The dbus path of nic
     */
    CardManager(sdbusplus::bus::bus& bus) :
        bus(bus), _event(sdeventplus::Event::get_default()),
        _timer(_event, std::bind(&CardManager::read, this))
    {
        // read json file
        configs = getCardConfig();
    }

    /*
     * Structure for keeping card information
     *
     * */
    struct PcieCard
    {
        uint32_t vendorID;
        uint32_t deviceID;
        std::string deviceName;
    };

    /**
     * Structure for keeping nic configure data required by nic monitoring
     */
    struct CardConfig
    {
        std::string index;
        int busID;
        uint8_t channelId;
        uint8_t muxAddress;
        uint8_t slaveAddress;

        /* just store information, not support now */
        int8_t criticalHigh;
        int8_t criticalLow;
        int8_t maxValue;
        int8_t minValue;
        int8_t warningHigh;
        int8_t warningLow;
    };

    /**
     * Structure for keeping nic data required by nic monitoring
     */
    struct CardData
    {
        bool present;
        bool functional;
        int8_t remoteTemp;
        int8_t sensorValue;
        int16_t mfrId;
        int16_t deviceId;
        std::string name;
    };

    /** @brief Setup polling timer in a sd event loop and attach to D-Bus
     *         event loop.
     */
    void run();

    /** @brief Map of the object CardManagerSSD */
    std::unordered_map<std::string, std::shared_ptr<phosphor::nic::Nic>> cards;

    /** @brief Set inventory properties of nic */
    void setCardInventoryProperties(
        bool present, const phosphor::nic::CardManager::CardData& cardData,
        const std::string& inventoryPath);

    void createCardInventory();

    /** @brief read and update data to dbus */
    void readCardData(CardConfig& config);

  private:
    /** @brief sdbusplus bus client connection. */
    sdbusplus::bus::bus& bus;
    /** @brief the Event Loop structure */
    sdeventplus::Event _event;
    /** @brief Read Timer */
    sdeventplus::utility::Timer<sdeventplus::ClockId::Monotonic> _timer;

    std::vector<phosphor::nic::CardManager::CardConfig> configs;

    /** @brief Set up initial configuration value */
    void init();

    /** @brief Monitor card every one second  */
    void read();

    /** @brief Get card configuration */
    std::vector<phosphor::nic::CardManager::CardConfig> getCardConfig();

    /** @brief Read card info via I2C */
    bool getCardInfobyBusID(CardConfig& config,
                    phosphor::nic::CardManager::CardData& cardData);
};
} // namespace nic
} // namespace phosphor
