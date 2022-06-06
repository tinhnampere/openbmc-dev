#!/bin/bash

# This script monitors fan, over-temperature, PSU, CPU/SCP failure and update fault LED status

# shellcheck disable=SC2004
# shellcheck disable=SC2046
# shellcheck source=/dev/null

# common variables
	platform=$(uname -a | cut -d' ' -f2)
	fan_sensor_path='/xyz/openbmc_project/inventory/system/chassis/Mt_Jade/.*/'
	inventory_service_name='xyz.openbmc_project.Inventory.Manager'

	warning_fault_flag='/tmp/fault_warning'
	error_fault_flag='/tmp/fault_err'
	overtemp_fault_flag='/tmp/fault_overtemp'
	fault_RAS_UE_flag='/tmp/fault_RAS_UE'

	blink_rate=100000

	fault="false"

	on="true"
	off="false"

	gpio_fault="false"

	retry=5
	wait_sec=30

	host_is_on="false"

	host_state_service='xyz.openbmc_project.State.Host'
	host_state_path='/xyz/openbmc_project/state/host0'
	host_state_interface='xyz.openbmc_project.State.Host'

	delay_check_host=60

# fan variables
	fan_failed="false"
	fan_interface='xyz.openbmc_project.State.Decorator.OperationalStatus'

# PSU variables
	psu_failed="false"
	psu_bus=6
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
	led_service='xyz.openbmc_project.LED.GroupManager'
	led_fault_path='/xyz/openbmc_project/led/groups/system_fault'
	led_fault_interface='xyz.openbmc_project.Led.Group'
	fault_led_status=$off

# functions declaration
check_fan_control_ready() {
	local cnt=0
	local tmp

	while [ $cnt -le $retry ]
	do
		tmp=$(systemctl status phosphor-fan-control-init@0.service | grep Process | cut -d'/' -f5 | cut -d')' -f0)
		if [  "$tmp" == "SUCCESS" ]; then
			break
		fi
		cnt=$(( cnt + 1 ))
		echo "Retry $cnt: fan control not ready"
		sleep $wait_sec
	done
}

get_fan_list() {
	if [ "$platform" == "mtjade" ]; then
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

turn_on_off_fault_led() {	
	busctl set-property $led_service $led_fault_path $led_fault_interface Asserted b "$1" >> /dev/null
}

check_psu_failed() {
	local psu0_presence
	local psu1_presence
	local psu0_value
	local psu1_value

	psu0_presence=$(gpioget $(gpiofind PSU1_PRESENT))
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

	psu1_presence=$(gpioget $(gpiofind PSU2_PRESENT))
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

check_fault() {
	if [[ "$fan_failed" == "true" ]] || [[ "$psu_failed" == "true" ]] \
									|| [[ "$gpio_fault" == "true" ]] \
									|| [[ "$RAS_UE_occured" == "true" ]] \
									|| [[ "$overtemp_occured" == "true" ]]; then
		fault="true"
	else
		fault="false"
	fi
}

control_fault_led() {
	if [ "$fault" == "true" ]; then
		if [ "$fault_led_status" == $off ]; then
			turn_on_off_fault_led $on
			fault_led_status=$on
		fi
	else
		if [ "$fault_led_status" == $on ]; then
			turn_on_off_fault_led $off
			fault_led_status=$off
		fi
	fi
}

blink_fault_led() {
	if [ "$fault_led_status" == $off ]; then
		turn_on_off_fault_led $on
		usleep $blink_rate
		turn_on_off_fault_led $off
	else
		turn_on_off_fault_led $off
		usleep $blink_rate
		turn_on_off_fault_led $on
	fi	
}

check_gpio_fault() {
	if [[ -f $error_fault_flag ]]; then
		gpio_fault="true"
	else
		if [ -f $warning_fault_flag ]; then
			blink_fault_led
			rm $warning_fault_flag
		fi
		gpio_fault="false"
	fi
}

check_RAS_UE_occured() {
	if [[ -f $fault_RAS_UE_flag ]]; then
		echo "RAS UE error occured, turn on fault LED"
		RAS_UE_occured="true"
	else
		RAS_UE_occured="false"
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

# daemon start
check_host_status $delay_check_host

if [ "$host_is_on" == "true" ]; then
	check_fan_control_ready
fi

get_fan_list

while true
do
	check_gpio_fault
	check_fan_failed
	check_overtemp_occured
	check_RAS_UE_occured

	# Monitors PSU presence
	check_psu_failed

	check_fault
	control_fault_led
	sleep 2
done

exit 1
