#!/bin/bash
#ampere_platform_config.sh is platform configuration file

# shellcheck disable=SC2046
# shellcheck source=/dev/null

state=$(gpioget $(gpiofind s1-fw-boot-ok))
if [ "$state" == "1" ]; then
    echo 1
fi

