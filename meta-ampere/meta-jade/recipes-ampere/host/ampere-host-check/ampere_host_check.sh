#!/bin/bash
host_status() {
    st=$(busctl get-property xyz.openbmc_project.State.Host /xyz/openbmc_project/state/host0 xyz.openbmc_project.State.Host CurrentHostState | cut -d"." -f6)
    if [ "$st" == "Running\"" ]; then
        echo "on"
    else
        echo "off"
    fi
}

function gpio_number() {
    GPIO_BASE=$(cat /sys/class/gpio/gpio*/base)
    echo $((${GPIO_BASE} + $1))
}

function gpio_export_pin() {
    gpioId=$(gpio_number $1)
    if [ ! -d "/sys/class/gpio/gpio$gpioId" ]; then
        echo $gpioId > /sys/class/gpio/export
    else
        echo "Error: Directory /sys/class/gpio/gpio$gpioId does exists."
    fi
}

function gpio_unexport_pin() {
    gpioId=$(gpio_number $1)
    if [ -d "/sys/class/gpio/gpio$gpioId" ]; then
        echo $gpioId > /sys/class/gpio/unexport
    else
        echo "Error: Directory /sys/class/gpio/gpio$gpioId does not exists."
    fi
}

function gpio_get_pin() {
    gpioId=$(gpio_number $1)
    echo $(cat /sys/class/gpio/gpio$gpioId/value)
}

createFile=$1
setState=$2

error=0
if [ $(host_status) == "on" ]; then
    exit $error
fi

S0_FW_BOOT_OK=48
#query S0_FW_BOOT_OK Pin
gpio_export_pin $S0_FW_BOOT_OK

# Time out is 5 seconds when check the host state in BMC reboot
# and 60 seconds when check the host state in powering on the host
cnt=60
if [ ! -f "/run/ampere/fistboot" ]; then
    cnt=5
fi

val=0
while [ true ];
do
    val=$(gpio_get_pin $S0_FW_BOOT_OK)
    cnt=$((cnt - 1))
    echo "$cnt S0_FW_BOOK_OK = $val"
    if [ $val == 1 ]; then
        # Sleep 5 second before the host is ready
        sleep 5
        if [ $createFile == 1 ]; then
            echo "Creating /run/openbmc/host@0-on"
            touch /run/openbmc/host@0-on
        fi
        break
    fi
    if [ $cnt == 0 ]; then
        break
    fi
    sleep 1
done

gpio_unexport_pin $S0_FW_BOOT_OK
# Return the error when the host is failed to boot
if [ -f "/run/ampere/fistboot" ]; then
    if [ $val == 0 ]; then
        error=1
    fi
fi

# Create fistboot at BMC reboot
if [ ! -f "/run/ampere/fistboot" ]; then
    if [ ! -d "/run/ampere" ]; then
        mkdir -p /run/ampere
    fi
    touch /run/ampere/fistboot
fi

exit $error


