#!/bin/bash
# shellcheck disable=SC2046
# shellcheck source=/dev/null

source /usr/sbin/ampere_ras_sensors.sh

filename="/var/log/ras_event"
cper_text="/tmp/cper.txt"
cper_bin="/tmp/cper.bin"
cper_json="/tmp/cper.json"

SENSOR_TYPE_OEM=0xF0
PAYLOAD_TYPE=0x00
MEM_ERROR_TYPE_PARITY=8
ERROR_TYPE_ID_MCU=1
SUBTYPE_ID_PARITY=9

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

function parse_section_type()
{
	ret=$(jq '.sectionDescriptors | .[] | .sectionType | .type' "${cper_json}")
	
	echo "${ret}"
}

function parse_type_id()
{
	ret=$(jq '.sections | .[] | .vendorSpecificInfo | .typeId' "${cper_json}")
	
	echo "${ret}"
}

function parse_type_id_amp()
{
	ret=$(jq '.sections | .[] | .typeId' "${cper_json}")
	
	echo "${ret}"
}

function parse_subtype_id()
{
	ret=$(jq '.sections | .[] | .vendorSpecificInfo | .subTypeId' "${cper_json}")
	
	echo "${ret}"
}

function parse_subtype_id_amp()
{
	ret=$(jq '.sections | .[] | .subTypeId' "${cper_json}")
	
	echo "${ret}"
}

function parse_mem_error_type()
{
	ret=$(jq '.sections | .[] | .memoryErrorType | .value' "${cper_json}")
	
	echo "${ret}"
}

log_err_to_sel_err()
{

	evtdata1=$((SENSOR_TYPE_OEM | $1))
	evtdata2=$2
	evtdata3=0
	evtdata4=0
	evtdata5=0
	evtdata6=0
	section_type=$(parse_section_type)
	if [ "${section_type}" == "\"ARM\"" ];then
		type_id=$(parse_type_id)
		subtype_id=$(parse_subtype_id)
		val_hex=$(printf "%04x" "${type_id}")
		evtdata3="$(echo "${val_hex}" | cut -c 2-2)"
		evtdata3=$((PAYLOAD_TYPE | evtdata3))
		evtdata4="$(echo "${val_hex}" | cut -c 3-4)"
		val_hex=$(printf "%04x" "${subtype_id}")
		evtdata5="$(echo "${val_hex}" | cut -c 1-2)"
		evtdata6="$(echo "${val_hex}" | cut -c 3-4)"
	elif [ "${section_type}" == "\"Platform Memory\"" ]; then
		mem_err_type=$(parse_mem_error_type)
		if [ "${mem_err_type}" == "${MEM_ERROR_TYPE_PARITY}" ]; then
			evtdata3=$((PAYLOAD_TYPE | 0))
			evtdata4="${ERROR_TYPE_ID_MCU}"
			evtdata5=0
			evtdata6="${SUBTYPE_ID_PARITY}"
		else
			evtdata3=0
			evtdata4=0
			evtdata5=0
			evtdata6=0
		fi
	elif [ "${section_type}" == "\"Ampere Specific\"" ]; then
		type_id_amp=$(parse_type_id_amp)
		subtype_id_amp=$(parse_subtype_id_amp)
		val_hex=$(printf "%04x" "${type_id_amp}")
		evtdata3="$(echo "${val_hex}" | cut -c 2-2)"
		evtdata3=$((PAYLOAD_TYPE | evtdata3))
		evtdata4="$(echo "${val_hex}" | cut -c 3-4)"
		val_hex=$(printf "%04x" "${subtype_id_amp}")
		evtdata5="$(echo "${val_hex}" | cut -c 1-2)"
		evtdata6="$(echo "${val_hex}" | cut -c 3-4)"

	fi
	#convert to decimal
	evtdata3=$((16#"${evtdata3}"))
	evtdata4=$((16#"${evtdata4}"))
	evtdata5=$((16#"${evtdata5}"))
	evtdata6=$((16#"${evtdata6}"))
	
	# OEM data bytes
	#   oem id: 3 bytes [0x3a 0xcd 0x00]
	#   event data: 6 bytes
	#   sel type: 4 byte [0x00 0x00 0x00 0xC0]
	busctl call xyz.openbmc_project.Logging.IPMI \
		/xyz/openbmc_project/Logging/IPMI \
		xyz.openbmc_project.Logging.IPMI IpmiSelAddOem \
		sayy "" 12 \
		0x3a 0xcd 0x00 \
		"${evtdata1}" "${evtdata2}" \
		"${evtdata3}" "${evtdata4}" \
		"${evtdata5}" "${evtdata6}" \
		0x00 0x00 0x00 0xC0
}

function convert_cper_json()
{
	cper=$1

	echo "${cper}" > "${cper_text}"
	cper-convert to-bin "${cper_text}" --out "${cper_bin}"
	cper-convert to-json "${cper_bin}" --out "${cper_json}"
}

while read -r line; do
	#	'MESSAGE','TID','EVENT_ID','PRIORITY','SEVERITY','EVENT_DATA'
	IFS=' ' read -r -a arr <<< "$line"
	IFS=',' read -r -a info <<< "${arr[1]}"

	sensor_id="${info[2]}"
	if [ "${info[1]}" == "1" ] ; then
		socket_id=0
	else
		socket_id=1
	fi
	
	sensor_name="UNKNOWN"
	registry="OpenBMC.0.1.AmpereCritical.Critical"
	if [ -n "${RAS_SENSOR[$sensor_id]}" ]; then
			sensor_name="${RAS_SENSOR[$sensor_id]}"
			registry="${RAS_REGISTRIES[$sensor_id]}"
	fi

	log_ampere_oem_redfish_event \
		"${sensor_name}" 4 "${info[3]}" "${registry}" \
		"$(get_redfish_registry_args "${sensor_id}")"

	cper=$(echo "${info[5]} " | cut -c 9-)
	# Log CPER data to journalog
	echo "CPER DATA: ${cper}" | systemd-cat
	# Convert cper data to json-format
	convert_cper_json "${cper}"
	# Log SEL
	log_err_to_sel_err "${socket_id}" "${sensor_id}"

	sed -i "/$line/d" $filename
	usleep 300000
done < "$filename"

systemctl reload rsyslog 2> /dev/null || true

exit 0;
