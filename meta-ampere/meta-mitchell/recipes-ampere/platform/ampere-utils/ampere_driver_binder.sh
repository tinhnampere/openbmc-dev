#!/bin/bash

# Each driver include driver name and driver path
declare -a DRIVER_NAMEs=(
							"107-0070"
							"100-0071"
							"101-0071"
							"102-0071"
							"103-0071"
							"104-0071"
						)
# Driver path should include / at the end
declare -a DRIVER_PATHs=(
							"/sys/bus/i2c/drivers/pca954x/"
							"/sys/bus/i2c/drivers/pca954x/"
							"/sys/bus/i2c/drivers/pca954x/"
							"/sys/bus/i2c/drivers/pca954x/"
							"/sys/bus/i2c/drivers/pca954x/"
							"/sys/bus/i2c/drivers/pca954x/"
						)

# get length of an array
arraylength=${#DRIVER_NAMEs[@]}

# use for loop to read all values and indexes
for (( i=0; i<"${arraylength}"; i++ ));
do
	bindFile="${DRIVER_PATHs[$i]}bind"
	unbindFile="${DRIVER_PATHs[$i]}unbind"
	driverDir="${DRIVER_PATHs[$i]}${DRIVER_NAMEs[$i]}"
	if [ -d "$driverDir" ]; then
		echo "Driver ${DRIVER_NAMEs[$i]} is already bound."
	else
		echo "${DRIVER_NAMEs[$i]}" > "$bindFile"
	fi
done

exit 0
