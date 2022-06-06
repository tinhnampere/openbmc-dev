#!/bin/bash

# This script monitors fan, over-temperature, PSU, CPU/SCP failure and update fault LED status

# common variables
	platform=$(uname -a | cut -d' ' -f2)
	fan_sensor_path='/xyz/openbmc_project/inventory/system/chassis/Mt_Jade/.*/'
	inventory_service_name='xyz.openbmc_project.Inventory.Manager'
	
	s0_fault_flag='/tmp/fault0'
	s1_fault_flag='/tmp/fault1'
	
	fault="false"
	
	on="true"
	off="false"
	
	gpio_fault="deasserted"

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

check_fault() {
	if [ "$fan_failed" == "true" ]; then
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

check_gpio_fault() {
	if [[ -f $s0_fault_flag ]] || [[ -f $s1_fault_flag ]]; then
		gpio_fault="asserted"
	else
		gpio_fault="deasserted"
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
	if [ "$gpio_fault" == "deasserted" ]; then
		check_fan_failed
		# TODO: add check for over_temp, Power, PSU
		
		# check_overtemp_failed
		
		# check_power_failed
		# check_PSU_failed
			
		check_fault
		control_fault_led
	fi
	sleep 2
done

exit 1

