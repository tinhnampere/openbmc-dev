#!/bin/bash

DELAY_BEFORE_BIND=5000000
# Each driver include driver name and driver path
declare -a DRIVER_NAMEs=("1e78a0c0.i2c-bus:smpro@4f:hwmon"
                         "1e78a0c0.i2c-bus:smpro@4e:hwmon"
                         "1e78a0c0.i2c-bus:smpro@4f:errmon"
                         "1e78a0c0.i2c-bus:smpro@4e:errmon"
                         "1e78a0c0.i2c-bus:smpro@4f:misc"
                         "1e78a0c0.i2c-bus:smpro@4e:misc"
                        )
# Driver path should include / at the end
declare -a DRIVER_PATHs=("/sys/bus/platform/drivers/smpro-hwmon/"
                         "/sys/bus/platform/drivers/smpro-hwmon/"
                         "/sys/bus/platform/drivers/smpro-errmon/"
                         "/sys/bus/platform/drivers/smpro-errmon/"
                         "/sys/bus/platform/drivers/smpro-misc/"
                         "/sys/bus/platform/drivers/smpro-misc/"
                        )

# get length of an array
arraylength=${#DRIVER_NAMEs[@]}

usleep $DELAY_BEFORE_BIND
# use for loop to read all values and indexes
for (( i=0; i<"${arraylength}"; i++ ));
do
	bindFile="${DRIVER_PATHs[$i]}bind"
	driverDir="${DRIVER_PATHs[$i]}${DRIVER_NAMEs[$i]}"
	if [ -d "$driverDir" ]; then
		echo "Driver ${DRIVER_NAMEs[$i]} is already bound."
		continue;
	fi
	echo "${DRIVER_NAMEs[$i]}" > "$bindFile"
done

exit 0
