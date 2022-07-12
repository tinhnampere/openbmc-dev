#!/bin/bash

# shellcheck disable=SC2046
# shellcheck source=/dev/null

source /usr/sbin/gpio-lib.sh

# Do event trigger
function sel_trigger()
{
	echo "Error: system firmware hang, trigger sel"
	ampere_add_redfishevent.sh OpenBMC.0.1.SystemPowerOnFailed.Critical
}

# Do reset the system
function reset_system()
{
	echo "Error: system firmware hang, reset the system"
	ipmitool chassis power reset
}

s0_last_hb_state=0; cnt=-1;
last_host_state=0
sleep_times=0
while true
do
    if [ "$sleep_times" == "20" ]; then
        st=$(busctl get-property xyz.openbmc_project.State.Host \
            /xyz/openbmc_project/state/host0 xyz.openbmc_project.State.Host \
            CurrentHostState | cut -d"." -f6)
        if [ "$st" == "Running\"" ]; then
            last_host_state=1
        else
            last_host_state=0
        fi
        sleep_times=0
    fi
    sleep_times=$((sleep_times + 1))
    if [ "$last_host_state" == "1" ]; then
        # Monitor heart beat GPIO value, GPIOF4 for Socket 0
        s0_hb_state=$(gpio_name_get s0-heartbeat)

        if [ "$s0_last_hb_state" != "$s0_hb_state" ]; then
            cnt=0
        else
            cnt=$((cnt + 1))
        fi

        if [ "$cnt" -ge 6 ]; then
            state=$(busctl get-property org.openbmc.control.Power \
                /org/openbmc/control/power0 org.openbmc.control.Power \
                pgood | cut -d' ' -f2)
            if [ "$state" == "1" ]; then
                echo "Error: system firmware hang"
                sel_trigger
                reset_system
            fi
            s0_last_hb_state=0; cnt=-1
        fi
        s0_last_hb_state="$s0_hb_state"
    fi
    sleep 0.5
done
