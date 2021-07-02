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

# Time out to check S0_FW_BOOT_OK is 60 seconds
cnt=60
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
            if [ ! -d "/run/openbmc" ]; then
                mkdir -p /run/openbmc
            fi
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
if [ $val == 0 ]; then
    error=1
fi

exit $error


