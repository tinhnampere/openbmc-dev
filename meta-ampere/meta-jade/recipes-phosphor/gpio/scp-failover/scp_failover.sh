#!/bin/bash

# Handle the SCP Failover feature in which:
# - If the BMC receives the SCP_AUTH_FAILURE signal from Socket0,
#   attempts to boot from the failover boot EEPROM.
# - If the second boot fails, treats this as a permanent boot failure
#   and logs an event in SEL.
# Author: Chanh Nguyen <chnguyen@amperecomputing.com>

source /usr/sbin/gpio-lib.sh
source /usr/sbin/gpio-defs.sh

LOGGER_PATH="/usr/bin/logger-systemd"

I2C_BACKUP_SEL=$(gpio_get_val $BMC_I2C_BACKUP_SEL)

if [[ $? -ne 0 ]]; then
	echo "ERROR: GPIO I2C_BACKUP_SEL used"
	exit 1
fi

# Check the I2C_BACKUP_SEL
if [ ${I2C_BACKUP_SEL} == "1" ]; then
	# If it is HIGH, set it LOW. Then reset the Host to boot from
	# the failover Boot EEPROM.
	echo "Failover event: switch HOST boot from Failover-EEPROM"
	gpio_configure_output $BMC_I2C_BACKUP_SEL 0

	# Do nothing. As Host is fail to work, phosphor-state-manager will
	# put the Host to quesce state and automatically restart the Host
else
	# If it is LOW, log an Redfish event using logger-systemd
	logger-systemd --journald << EOF
MESSAGE=
PRIORITY=2
SEVERITY=Critical
REDFISH_MESSAGE_ID=OpenBMC.0.1.GeneralFirmwareSecurityViolation.Critical
REDFISH_MESSAGE_ARGS=SCP Authentication failure
EOF
	echo "scp-failover: switch Host back to boot from main Boot EEPROM"
	gpio_configure_output $BMC_I2C_BACKUP_SEL 1

	# Turn OFF Host to avoid it reboots continuously
	busctl set-property \
		xyz.openbmc_project.State.Host /xyz/openbmc_project/state/host0 \
		xyz.openbmc_project.State.Host RequestedHostTransition \
		s xyz.openbmc_project.State.Host.Transition.Off
fi
