#!/bin/bash

fault_gpio_err_flag='/tmp/fault_err'

systemctl stop ampere_check_fault_gpio_start_S0_host@0.service
systemctl stop ampere_check_fault_gpio_start_S1_host@0.service

if [ -f "$fault_gpio_err_flag" ]; then
	rm $fault_gpio_err_flag
fi

exit 0
