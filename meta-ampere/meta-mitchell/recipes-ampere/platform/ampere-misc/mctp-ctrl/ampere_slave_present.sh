#!/bin/bash
#ampere_platform_config.sh is platform configuration file

# shellcheck disable=SC2046
# shellcheck source=/dev/null

source /usr/sbin/gpio-lib.sh
state=$(gpio_name_get presence-cpu1)
if [ "$state" == "0" ]; then
    echo 1
fi

