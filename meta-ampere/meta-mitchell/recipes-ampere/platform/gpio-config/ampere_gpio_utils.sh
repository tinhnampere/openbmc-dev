#!/bin/bash

# shellcheck disable=SC2046
# shellcheck source=/dev/null

source /usr/sbin/gpio-lib.sh

function usage() {
    echo "usage: ampere_gpio_utils.sh [power] [on|off]";
}

set_gpio_power_off() {
    echo "Setting GPIO before Power off"
}

set_gpio_power_on() {
    echo "Setting GPIO before Power on"
}

unbind_aspeed_smc_driver() {
    # Switch the Host SPI-NOR to BMC
    gpio_name_set spi0-program-sel 1
    # Check the HNOR partition available
    HOST_MTD=$(< /proc/mtd grep "hnor" | sed -n 's/^\(.*\):.*/\1/p')
    if [ -z "$HOST_MTD" ]; then
        # If the HNOR partition is not available, then bind and unbind driver
        echo "Bind/Unbind the ASpeed SMC driver"
        echo 1e630000.spi > /sys/bus/platform/drivers/spi-aspeed-smc/bind
        sleep 1
        echo 1e630000.spi > /sys/bus/platform/drivers/spi-aspeed-smc/unbind
    else
        # If the HNOR partition is available, then unbind driver
        echo "Unbind the ASpeed SMC driver"
        echo 1e630000.spi > /sys/bus/platform/drivers/spi-aspeed-smc/unbind
    fi

    # Switch the Host SPI-NOR to HOST
    gpio_name_set spi0-program-sel 0
    sleep 0.5
}

if [ $# -lt 2 ]; then
    echo "Total number of parameter=$#"
    echo "Insufficient parameter"
    usage;
    exit 0;
fi

if [ "$1" == "power" ]; then
    if [ "$2" == "on" ]; then
        pgood=$(busctl get-property org.openbmc.control.Power /org/openbmc/control/power0 org.openbmc.control.Power pgood | cut -d' ' -f2)
        if [ "$pgood" == "0" ]; then
            set_gpio_power_on
            unbind_aspeed_smc_driver
        fi
    elif [ "$2" == "off" ]; then
        set_gpio_power_off
    fi
    exit 0;
else
    echo "Invalid parameter1=$1"
    usage;
    exit 0;
fi
exit 0;
