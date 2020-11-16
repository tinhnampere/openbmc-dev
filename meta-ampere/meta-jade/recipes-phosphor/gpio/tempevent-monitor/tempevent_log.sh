#!/bin/bash

# Log Redfish event for hightemp and overtemp events
# Syntax: tempevent_log.sh [event] [action]
# Where: [event] is "Hightemp" or "Overtemp"
#.       [action] is "Start" or "Stop"
# Author: Chanh Nguyen <chnguyen@amperecomputing.com>

LOGGER_PATH="/usr/bin/logger-systemd"
sev="Critical"
redfish_mess_arg_2=""

if [ $# -eq 0 ]; then
	echo 'No argument is given' >&2
	exit 1
fi


if [ "$2" != "" ]; then
	redfish_mess_arg_2=$2
fi

# Check if the LOGGER_PATH
if [ ! -e ${LOGGER_PATH} ]; then
	echo "Error: Not found ${LOGGER_PATH}"
	exit 1
fi

if [ "$1" != "Overtemp" ]; then
	evt="OpenBMC.0.1.AmpereCritical.Critical"
	redfish_mess_arg_1="${1} event"
else
	evt="OpenBMC.0.1.CPUThermalTrip.Critical"
	redfish_mess_arg_1=0
fi

logger-systemd --journald << EOF
MESSAGE=
PRIORITY=2
SEVERITY=${sev}
REDFISH_MESSAGE_ID=${evt}
REDFISH_MESSAGE_ARGS=${redfish_mess_arg_1},${redfish_mess_arg_2}
EOF

