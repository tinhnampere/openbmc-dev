#!/bin/bash
# This script monitors fan, over-temperature, PSU, CPU/SCP failure and update fault LED status

# shellcheck disable=SC2004
# shellcheck source=/dev/null
source /usr/sbin/gpio-lib.sh

# common variables
	machine=$(uname -a | cut -d' ' -f2)
	fan_interface='xyz.openbmc_project.State.Decorator.OperationalStatus'

	on=1
	off=0

	retry=5
	wait_sec=30

    overtemp_fault_flag='/tmp/fault_overtemp'

# Host variables
	host_is_on="false"
	host_state_service='xyz.openbmc_project.State.Host'
	host_state_path='/xyz/openbmc_project/state/host0'
	host_state_interface='xyz.openbmc_project.State.Host'
	delay_check_host=60

# fan variables
	fan_failed="false"
	fan_sensor_path='/xyz/openbmc_project/inventory/system/board/Mt_Mitchell_MB/.*/'
	inventory_service_name='xyz.openbmc_project.Inventory.Manager'

# PSU variables
	psu_failed="false"
	psu_bus=2
	psu0_addr=0x58
	psu1_addr=0x59
	status_word_cmd=0x79
	# Following the PMBus Specification
	# Bit[1]: CML faults
	# Bit[2]: Over temperature faults
	# Bit[3]: Under voltage faults
	# Bit[4]: Over current faults
	# Bit[5]: Over voltage fault
	# Bit[10]: Fan faults
	psu_fault_bitmask=0x43e

# led variables
	fan_fault_led_status=$off
	psu_fault_led_status=$off
	led_bus=15
	led_addr=0x22
	led_port0_config=0x06
	led_port0_output=0x02

# functions declaration
check_fan_control_ready() {
	local cnt=0
	local tmp

	while [ $cnt -le $retry ]
	do
		tmp=$(systemctl is-active phosphor-fan-control@0.service)
		if [  "$tmp" == "active" ]; then
			break
		fi
		cnt=$(( cnt + 1 ))
		echo "Retry $cnt: fan control not ready"
		sleep $wait_sec
	done
}

get_fan_list() {
	if [ "$machine" == "mtmitchell" ]; then
		mapfile -t fan_list < <(busctl tree $inventory_service_name --list | grep "$fan_sensor_path")
	else
		echo "Error: Platform not support"
		exit 1
	fi
}

check_host_status() {
	local tmp

	tmp=$(busctl get-property $host_state_service $host_state_path $host_state_interface CurrentHostState | cut -d"." -f6)
	if [ "$tmp" == "Running\"" ]; then
		host_is_on="true"
	else
		host_is_on="false"
		sleep "$1"
	fi
}

check_fan_failed() {
	check_host_status 0
	if [ "$host_is_on" == "false" ]; then
		return
	fi

	local tmp

	for each in "${fan_list[@]}"
	do
		tmp=$(busctl get-property $inventory_service_name "$each" $fan_interface Functional | cut -d' ' -f2)
		if [ "$tmp" == "false" ]; then
			echo "Error: Fan $each failed"
			fan_failed="true"
			break
		fi
		fan_failed="false"
	done
}

turn_on_off_fan_fault_led() {
	# Control fan fault led via CPLD's I2C at slave address 0x22, I2C16.
	# Config port direction to output
	i2cset -f -y $led_bus $led_addr $led_port0_config 0

	# Get led value
	led_st=$(i2cget -f -y $led_bus $led_addr $led_port0_output)

	if [ "$1" == $on ]; then
		led_st=$(("$led_st" | 1))
	else
		led_st=$(("$led_st" & ~1))
	fi

	# Turn on/off fan fault led
	i2cset -f -y $led_bus $led_addr $led_port0_output $led_st
}

turn_on_off_psu_fault_led() {
	# Control psu fault led via CPLD's I2C at slave address 0x22, I2C16.
	# Config port direction to output
	i2cset -f -y $led_bus $led_addr $led_port0_config 0

	# Get led value
	led_st=$(i2cget -f -y $led_bus $led_addr $led_port0_output)
	if [ "$1" == $on ]; then
		led_st=$(("$led_st" | 2))
	else
		led_st=$(("$led_st" & ~2))
	fi

	# Turn on/off psu fault led
	i2cset -f -y $led_bus $led_addr $led_port0_output $led_st
}

control_fan_fault_led() {
	if [ "$fan_failed" == "true" ]; then
		if [ "$fan_fault_led_status" == $off ]; then
			turn_on_off_fan_fault_led $on
			fan_fault_led_status=$on
		fi
	else
		if [ "$fan_fault_led_status" == $on ]; then
			turn_on_off_fan_fault_led $off
			fan_fault_led_status=$off
		fi
	fi
}

check_psu_failed() {
	local psu0_presence
	local psu1_presence
	local psu0_value
	local psu1_value

	psu0_presence=$(gpio_name_get presence-ps0)
	psu0_failed="true"
	if [ "$psu0_presence" == "0" ]; then
		# PSU0 presence, monitor the PSUs using pmbus, check the STATUS_WORD
		psu0_value=$(i2cget -f -y $psu_bus $psu0_addr $status_word_cmd w)
		psu0_bit_fault=$(($psu0_value & $psu_fault_bitmask))
		if [ "$psu0_bit_fault" != "0" ]; then
			echo "Error: PSU0 failed"
		else
			psu0_failed="false"
		fi
	else
		echo "Error: PSU0 is not presence"
	fi

	psu1_presence=$(gpio_name_get presence-ps1)
	psu1_failed="true"
	if [ "$psu1_presence" == "0" ]; then
		# PSU1 presence, monitor the PSUs using pmbus, check the STATUS_WORD
		psu1_value=$(i2cget -f -y $psu_bus $psu1_addr $status_word_cmd w)
		psu1_bit_fault=$(($psu1_value & $psu_fault_bitmask))
		if [ "$psu1_bit_fault" != "0" ]; then
			echo "Error: PSU1 failed"
		else
			psu1_failed="false"
		fi
	else
		echo "Error: PSU1 is not presence"
	fi

	if [ "$psu0_failed" == "true" ] || [ "$psu1_failed" == "true" ]; then
		psu_failed="true"
	else
		psu_failed="false"
	fi
}

control_psu_fault_led() {
	if [ "$psu_failed" == "true" ]; then
		if [ "$psu_fault_led_status" == $off ]; then
			turn_on_off_psu_fault_led $on
			psu_fault_led_status=$on
		fi
	else
		if [ "$psu_fault_led_status" == $on ]; then
			turn_on_off_psu_fault_led $off
			psu_fault_led_status=$off
		fi
	fi
}

check_overtemp_occured() {
    if [[ -f $overtemp_fault_flag ]]; then
        echo "Over temperature occured, turn on fault LED"
        overtemp_occured="true"
    else
        overtemp_occured="false"
    fi
}



check_fault() {
	if [[ "$fan_failed" == "true" ]] || [[ "$psu_failed" == "true" ]] \
                                    || [[ "$overtemp_occured" == "true" ]]; then
		fault="true"
	else
		fault="false"
	fi
}

# The System Fault Led turns on upon the system error, update the System Fault Led
# based on the Fan fault status and PSU fault status
control_sys_fault_led() {
	# Turn on/off the System Fault Led
	if [ "$fault" == "true" ]; then
		gpio_name_set led-fault $on
	else
		gpio_name_set led-fault $off
	fi
}

# daemon start
check_host_status $delay_check_host

if [ "$host_is_on" == "true" ]; then
	check_fan_control_ready
fi

get_fan_list

while true
do
	#  Monitors Fan speeds
	check_fan_failed
	# Monitors PSU presence
	check_psu_failed

	check_overtemp_occured
	# Check fault to update fail
	check_fault
	control_sys_fault_led

	control_fan_fault_led
	control_psu_fault_led

	sleep 2
done

exit 1
