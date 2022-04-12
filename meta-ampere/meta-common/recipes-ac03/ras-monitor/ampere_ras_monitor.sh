#!/bin/bash
# shellcheck disable=SC2046
# shellcheck source=/dev/null

source /usr/sbin/ampere_ras_sensors.sh

function log_ampere_oem_redfish_event()
{
	msg=$1
	priority=$2
	severity=$3
	msgID=$4
	msgArgs1=$5

logger-systemd --journald << EOF
MESSAGE=${msg}
PRIORITY=${priority}
SEVERITY=${severity}
REDFISH_MESSAGE_ID=${msgID}
REDFISH_MESSAGE_ARGS=${msgArgs1}
EOF
}

log_err_to_sel_err() {
	evtdata1=$((EVENT_DIR_ASSERTION | OEM_SENSOR_SPECIFIC))
	evtdata0="0xff"
	byte0="0xff"
	byte1="0xff"
	# OEM data bytes
	#   oem id: 3 bytes [0x3a 0xcd 0x00]
	#   sensor num: 1 bytes
	#   sensor type: 1 bytes
	#   data bytes: 4 bytes
	#   sel type: 4 byte [0x00 0x00 0x00 0xC0]
	busctl call xyz.openbmc_project.Logging.IPMI \
		/xyz/openbmc_project/Logging/IPMI \
		xyz.openbmc_project.Logging.IPMI IpmiSelAddOem \
		sayy "" 12 \
		0x3a 0xcd 0x00 \
		"$1" "$2" \
		"$evtdata1" "$evtdata0" "$byte1" "$byte0" \
		0x00 0x00 0x00 0xC0
}

filename="/var/log/ras_event"
EVENT_DIR_ASSERTION=0x00
OEM_SENSOR_SPECIFIC=0x70
SENSOR_TYPE_OEM=0x0F

while read -r line; do
	#	'MESSAGE','TID','EVENT_ID','PRIORITY','SEVERITY','EVENT_DATA'
	IFS=' ' read -r -a arr <<< "$line"
	IFS=',' read -r -a info <<< "${arr[1]}"

	sensor_id="${info[2]}"
	sensor_name="UNKNOWN"
	registry="OpenBMC.0.1.AmpereCritical.Critical"
	if [ -n "${RAS_SENSOR[$sensor_id]}" ]; then
			sensor_name="${RAS_SENSOR[$sensor_id]}"
			registry="${RAS_REGISTRIES[$sensor_id]}"
	fi

	log_ampere_oem_redfish_event \
		"${sensor_name}" 4 "${info[3]}" "${registry}" \
		"$(get_redfish_registry_args "${sensor_id}")"

	# SENSOR_NUM = EVENT_ID
	# SENSOR_TYPE = OEM
	log_err_to_sel_err "$SENSOR_TYPE_OEM" "${info[2]}"

	sed -i "/$line/d" $filename
	usleep 300000
done < "$filename"

systemctl reload rsyslog 2> /dev/null || true

exit 0;
