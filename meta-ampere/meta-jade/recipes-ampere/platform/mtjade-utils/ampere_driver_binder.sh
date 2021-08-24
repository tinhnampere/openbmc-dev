#!/bin/bash
source /usr/sbin/drivers-conf.sh

cnt=60
while [ ! -f "/run/openbmc/host@0-on" ];
do
    cnt=$((cnt - 1))
    if [ $cnt == 0 ]; then
        exit 0;
    fi
    # sleep 0.5 second
    usleep 500000
done

echo "/run/openbmc/host@0-on is created"
# get length of an array
arraylength=${#DRIVER_NAMEs[@]}

usleep $DELAY_BEFORE_BIND
# use for loop to read all values and indexes
for (( i=0; i<${arraylength}; i++ ));
do
    bindFile="${DRIVER_PATHs[$i]}bind"
    driverDir="${DRIVER_PATHs[$i]}${DRIVER_NAMEs[$i]}"
    if [ -d $driverDir ]; then
        echo "Driver ${DRIVER_NAMEs[$i]} is already bound."
        continue;
    fi
    echo ${DRIVER_NAMEs[$i]} > $bindFile
done

exit 0
