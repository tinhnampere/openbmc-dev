#!/bin/bash
# Initialize variables
boot_stage=0x00
boot_status=0x00
boot_code=0x0000
uefi_code=0x00000000
uefi_log=0

function update_boot_progress()
{
	bootprog=$1

	busctl set-property xyz.openbmc_project.State.Host \
		/xyz/openbmc_project/state/host0 \
		xyz.openbmc_project.State.Boot.Progress \
		BootProgress s \
		"xyz.openbmc_project.State.Boot.Progress.ProgressStages.$bootprog"
}

function get_boot_stage_string()
{
	bootstage=$1
	dimminfo=$2

	case $bootstage in

		0x90)
			boot_stage_str="SECpro"
			;;

		0x91)
			boot_stage_str="Mpro"
			;;

		0x92)
			boot_stage_str="ATF BL1"
			;;

		0x93)
			boot_stage_str="ATF BL2"
			;;

		0x94)
			boot_stage_str="DDR initialization"
			;;

		0x96)
			boot_stage_str="DDR training Failure (DIMM_INFO=${dimminfo})"
			;;

		0x97)
			boot_stage_str="ATF BL31"
			;;

		0x98)
			boot_stage_str="ATF BL32"
			;;

	esac

	echo "$boot_stage_str"
}

function get_boot_status_string()
{
	bootstage=$1
	bootvalue=$2
	bootcode="0x$(echo "$bootvalue" | cut -c 7-8)"
	percentage="$(echo "$bootvalue" | cut -c 5-6)"

	case $bootstage in

		0x90)
			if [[ "${bootcode}" == "0x00" ]]; then
				boot_stage_str="SECpro booting"
			elif [[ "${bootcode}" == "0x01" ]]; then
				boot_stage_str="SECpro completed"
			fi
			;;

		0x91)
			if [[ "${bootcode}" == "0x00" ]]; then
				boot_stage_str="Mpro booting"
			elif [[ "${bootcode}" == "0x01" ]]; then
				boot_stage_str="Mpro completed"
			fi
			;;

		0x92)
			if [[ "${bootcode}" == "0x00" ]]; then
				boot_stage_str="ATF BL1 booting"
			elif [[ "${bootcode}" == "0x01" ]]; then
				boot_stage_str="ATF BL1 completed"
			fi
			;;

		0x93)
			if [[ "${bootcode}" == "0x00" ]]; then
				boot_stage_str="ATF BL2 booting"
			elif [[ "${bootcode}" == "0x01" ]]; then
				boot_stage_str="ATF BL2 completed"
			fi
			;;

		0x94)
			if [[ "${bootcode}" == "0x00" ]]; then
				boot_stage_str="DDR initialization started"
			elif [[ "${bootcode}" == "0x01" ]]; then
				boot_stage_str="DDR initialization completed"
			fi
			;;

		0x95)
			if [[ "${bootcode}" == "0x00" ]]; then
				boot_stage_str="DDR training progress started"
			elif [[ "${bootcode}" == "0x01" ]]; then
				boot_stage_str="DDR training progress Percentage (${percentage}%)"
			elif [[ "${bootcode}" == "0x02" ]]; then
				boot_stage_str="DDR training progress completed"
			fi
			;;

		0x97)
			if [[ "${bootcode}" == "0x00" ]]; then
				boot_stage_str="ATF BL31 booting"
			elif [[ "${bootcode}" == "0x01" ]]; then
				boot_stage_str="ATF BL31 completed"
			fi
			;;

		0x98)
			if [[ "${bootcode}" == "0x00" ]]; then
				boot_stage_str="ATF BL32 booting"
			elif [[ "${bootcode}" == "0x01" ]]; then
				boot_stage_str="ATF BL32 completed"
			fi
			;;

		0x99)
			if [[ "${uefi_log}" == "0" ]]; then
				boot_stage_str="ATF BL33(UEFI) booting"
			elif [[ "${uefi_log}" == "1" ]] && [[ "${bootvalue}" == "050D0000" ]]; then
				boot_stage_str="ATF BL33(UEFI) completed"
			fi
			;;

	esac

	echo "$boot_stage_str"
}

function set_boot_progress()
{
	bootstage=$1
	bootcode=$2

	case $bootstage in

		0x92)
			update_boot_progress "PrimaryProcInit"
			;;

		0x94)
			update_boot_progress "MemoryInit"
			;;

		0x99)
			if [[ "$bootcode" =~ 0x0201* ]]; then
				update_boot_progress "PCIInit"
			elif [[ "$bootcode" =~ 0x0202* ]]; then
				update_boot_progress "SystemInitComplete"
			fi
			;;

	esac
}

function log_redfish_biosboot_ok_event()
{
	logger-systemd --journald << EOF
MESSAGE=
PRIORITY=2
SEVERITY=
REDFISH_MESSAGE_ID=OpenBMC.0.1.BIOSBoot.OK
REDFISH_MESSAGE_ARGS="UEFI firmware booting done"
EOF
}

function log_redfish_bios_panic_event()
{
	boot_state_str=$(get_boot_stage_string "$1" "$2")

	logger-systemd --journald << EOF
MESSAGE=
PRIORITY=2
SEVERITY=
REDFISH_MESSAGE_ID=OpenBMC.0.1.BIOSFirmwarePanicReason.Warning
REDFISH_MESSAGE_ARGS=${boot_state_str}
EOF
}

function log_redfish_boot_event()
{
	boot_status_str=$(get_boot_status_string "$1" "$2")

	logger-systemd --journald << EOF
MESSAGE=
PRIORITY=2
SEVERITY=
REDFISH_MESSAGE_ID=OpenBMC.0.1.AmpereEvent.OK
REDFISH_MESSAGE_ARGS=${boot_status_str}
EOF
}

function parse_json_data()
{
	val=$(busctl --json=pretty get-property xyz.openbmc_project.PLDM \
		/xyz/openbmc_project/sensors/oem/S0_Boot_Stat \
		xyz.openbmc_project.Sensor.Value Value)
	tmp=$(echo "$val" | awk '/data/ {gsub("\"", "", $3); print $3}') 2>/dev/null
	tmp1=$(printf '%.0f' "$tmp") 2>/dev/null
	boot_value=$(printf '%.0x' "$tmp1") 2>/dev/null
	echo "$boot_value"
}

# Check if the Host is already booted or not. If the Host is already booted,
# do not log event to avoid redundant BIOSBoot.OK event
host_booted=1
cnt=0
boot_status_ready=0
declare -a stage_arr=("0x90" "0x91" "0x92" "0x93" "0x94" "0x95" "0x96" "0x97" "0x98")

while [ $cnt -lt 100 ];
do
	# Sleep 200ms
	usleep 200000
	if [ "${boot_status_ready}" == "0" ];
	then
		val=$(busctl tree | grep S0_Boot_Stat)
		if [ -z "${val}" ];
		then
			cnt=$((cnt + 1))
			continue
		else
			boot_status_ready=1
		fi
	fi
	boot_value=$(parse_json_data)
	#boot_value="95808001"
	if [ -z "${boot_value}" ];
	then
		cnt=$((cnt + 1))
		# When boot-progress is running but suddenly off or reboot,
		# the /sys interface is unavailable. Stop executing the script
		if [ "${host_booted}" == "0" ];
		then
			break
		else
			sleep 1
			continue
		fi
	fi
	cnt=0
	byte3=$(echo "$boot_value" | cut -c 1-2)
	byte2=$(echo "$boot_value" | cut -c 3-4)
	byte1_0=$(echo "$boot_value" | cut -c 5-8)
	byte1="0x$(echo "$boot_value" | cut -c 5-6)"
	byte0="0x$(echo "$boot_value" | cut -c 7-8)"

	# If no value on boot_stage or boot_status, exit the script
	if [[ -z "${byte3}" ]] || [[ -z "${byte2}" ]];
	then
		break
	fi
	# Check if any update from previous check
	if [ "${boot_stage}" == "0x${byte3}" ] && [ "${boot_status}" == "0x${byte2}" ] && [ "${boot_code}" == "0x${byte1_0}" ]; then
		continue
	fi

	host_booted=0

	# Update current boot progress
	boot_stage="0x${byte3}"
	boot_status="0x${byte2}"
	boot_code="0x${byte1_0}"
	#echo "Boot Progress = ${boot_stage} ${boot_status} ${boot_code}"

	# Handle UEFI stage
	uefi_boot=1
	for i in "${stage_arr[@]}"
	do
		if [ "${boot_stage}" == "${i}" ];
		then
			uefi_boot=0
			break
		fi
	done

	if [ "${uefi_boot}" == "1" ];
	then
		boot_stage="0x99"
		# Set boot progress to dbus
		set_boot_progress "$boot_stage" "$boot_value"

		# Log Boot Progress to ComputerSystem.BootProgress Redfish object.
		# T.B.D
	else
		# Log Redfish Event for bad Boot Progress status.
		if [[ "${boot_stage}" != "0x96" ]] && [[ "${boot_status}" == "0x81" ]];
		then
			# Log Redfish Event if failure.
			log_redfish_bios_panic_event "$boot_stage" "$boot_value"
		fi

		if [ "${boot_stage}" == "0x96" ];
		then
			# Dimm training failed, log errors
			dimm_fail_info="0x$(echo "$boot_value" | cut -c 3-8)"
			log_redfish_bios_panic_event "$boot_stage" "$dimm_fail_info"
		fi

		# Check and set boot progress to dbus
		if [[ "${boot_stage}" != "0x96" ]] && [[ "${boot_status}" == "0x80" ]];
		then
			set_boot_progress "$boot_stage" "$boot_value"
		fi
	fi

	# Log Redfish Event for good Boot Progress status.
	if [ "${boot_stage}" != "0x96" ] && [[ "${boot_status}" != "0x81" ]];
	then
		log_redfish_boot_event "$boot_stage" "$boot_value"
		uefi_log=1
	fi

	# Stop the service when UEFI boot completed
	if [[ "${uefi_boot}" == "1" ]] && [[ "${boot_value}" == "050D0000" ]];
	then
		update_boot_progress "OSStart"
		log_redfish_biosboot_ok_event
		break
	fi
done

