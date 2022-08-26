#!/bin/bash

# Check current Host status. Do nothing when the Host is currently ON
st=$(busctl get-property xyz.openbmc_project.State.Host \
	/xyz/openbmc_project/state/host0 xyz.openbmc_project.State.Host \
	CurrentHostState | cut -d"." -f6)
if [ "$st" == "Running\"" ]; then
	exit 0
fi

# Five seconds after start ampere-host-on-host-check@.service is enough
# to finish triggering PSON.
# TODO:
# Create one ampere-power-on@.target check point to indentify that the PSON
# is already triggered to replace this timming solution.
sleep 5
echo "Try to bind driver after power on if does not"
if command -v ampere_power_on_driver_binder.sh;
then
	ampere_power_on_driver_binder.sh
fi

# Time out checking for Host ON is 60s
cnt=55
while [ "$cnt" -gt 0 ];
do
	cnt=$((cnt - 1))
	st=$(busctl call xyz.openbmc_project.State.HostCondition.Gpio \
		/xyz/openbmc_project/Gpios/host0 org.freedesktop.DBus.Properties \
		Get ss xyz.openbmc_project.Condition.HostFirmware \
		CurrentFirmwareCondition | cut -d"." -f6)
	if [ "$st" == "Running\"" ]; then
		echo "Try to bind driver after host on if does not"
		if command -v ampere_driver_binder.sh;
		then
			ampere_driver_binder.sh
		fi
		exit 0
	fi
	sleep 1
done

if command -v ampere_post_check_fault_gpio.sh;
then
	ampere_post_check_fault_gpio.sh
fi

exit 1
