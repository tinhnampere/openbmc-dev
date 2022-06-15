#!/bin/bash

# shellcheck disable=SC2046
# shellcheck source=/dev/null

source /usr/sbin/gpio-lib.sh


function power_on_sequence_monitoring_log() {
	local cnt="$1"
	while [ "$cnt" -gt 0 ];
	do
		cnt=$((cnt - 1))
		if [ "$2" == "power-chassis-good" ]; then
			state=$(busctl get-property org.openbmc.control.Power /org/openbmc/control/power0 org.openbmc.control.Power pgood | cut -d' ' -f2)
			if [ "$state" == "1" ]; then
				break
			fi
		else
			state=$(gpio_name_get "$2")
			if [ "$state" -ne "0" ]; then
				break
			fi
		fi
		sleep 1
	done

	if [ "$cnt" == 0 ]; then
		# Host can not be powered on, create event log
		echo "Error: Cannot power on host"
		ampere_add_redfishevent.sh "$3" "$4"
		echo 1
	fi

	echo 0
}

# Check current Host status. Do nothing when the Host is currently ON
st=$(busctl get-property xyz.openbmc_project.State.Host \
	/xyz/openbmc_project/state/host0 xyz.openbmc_project.State.Host \
	CurrentHostState | cut -d"." -f6)
if [ "$st" == "Running\"" ]; then
	exit 0
fi

# Check CPU presence, identify whether it is 1P or 2P system
oneP_presence=$(gpio_name_get presence-cpu0)
twoP_presence=$(gpio_name_get presence-cpu1)
if [ "$oneP_presence" == "0" ] && [ "$twoP_presence" == "0" ]; then
	ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.OK "Host firmware boots with 2 Processor"
elif [ "$oneP_presence" == "0" ]; then
	ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.OK "Host firmware boots with 1 Processor"
else
	ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.OK "No Processor is present"
fi

# ATX power good monitoring
echo "ATX power good monitoring"
st=$(power_on_sequence_monitoring_log 60 power-chassis-good OpenBMC.0.1.PowerSupplyPowerGoodFailed.Critical "60000")
if [ "$st" == "1" ]; then
	echo "Error: Failed to turn on ATX Power"
	exit 0
fi

# Soc power good monitoring
echo "Soc power good monitoring"
st=$(power_on_sequence_monitoring_log 60 s0-soc-pgood OpenBMC.0.1.AmpereCritical.Critical "Soc domain, power failure")
if [ "$st" == "1" ]; then
	echo "Error: Soc domain power failure"
	exit 0
fi

# PCP power good monitoring
echo "PCP power good monitoring"
st=$(power_on_sequence_monitoring_log 50 sys-pgood OpenBMC.0.1.AmpereCritical.Critical "PCP domain, power failure")
if [ "$st" == "1" ]; then
	echo "Error: PCP domain power failure"
fi

exit 0
