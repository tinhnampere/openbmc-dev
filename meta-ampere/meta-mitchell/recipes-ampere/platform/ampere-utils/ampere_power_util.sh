#!/bin/bash

# shellcheck disable=SC2046
# shellcheck source=/dev/null

source /usr/sbin/gpio-lib.sh

# Usage of this utility
function usage() {
	echo "usage: power-util mb [status|shutdown_ack|force_reset|soft_off|host_reboot_wa]";
}

power_status() {
	st=$(busctl get-property xyz.openbmc_project.State.Chassis /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis CurrentPowerState | cut -d"." -f6)
	if [ "$st" == "On\"" ]; then
		echo "on"
	else
		echo "off"
	fi
}

shutdown_ack() {
	if [ -f "/run/openbmc/host@0-softpoweroff" ]; then
		echo "Receive shutdown ACK triggered after softportoff the host."
		touch /run/openbmc/host@0-softpoweroff-shutdown-ack
	else
		echo "Receive shutdown ACK triggered"
		sleep 3
		systemctl start obmc-chassis-poweroff@0.target
	fi
}

bind_aspeed_smc_driver() {
	# Switch the Host SPI-NOR to BMC
	gpio_name_set spi0-program-sel 1
	sleep 1
	echo "Bind the ASpeed SMC driver"
	echo 1e630000.spi > /sys/bus/platform/drivers/spi-aspeed-smc/bind
	# Check the HNOR partition available
	HOST_MTD=$(< /proc/mtd grep "hnor" | sed -n 's/^\(.*\):.*/\1/p')
	if [ -z "$HOST_MTD" ]; then
		echo 1e630000.spi > /sys/bus/platform/drivers/spi-aspeed-smc/unbind
		sleep 1
		echo "Bind the ASpeed SMC driver again"
		echo 1e630000.spi > /sys/bus/platform/drivers/spi-aspeed-smc/bind
	fi
}

unbind_aspeed_smc_driver() {
	# Switch the Host SPI-NOR to BMC
	gpio_name_set spi0-program-sel 1
	# Check the HNOR partition available
	HOST_MTD=$(< /proc/mtd grep "hnor" | sed -n 's/^\(.*\):.*/\1/p')
	if [ -z "$HOST_MTD" ]; then
		# If the HNOR partition is not available, then bind and unbind driver
		echo "Bind/Unbind the ASpeed SMC driver"
		echo 1e630000.spi > /sys/bus/platform/drivers/spi-aspeed-smc/bind
		sleep 1
		echo 1e630000.spi > /sys/bus/platform/drivers/spi-aspeed-smc/unbind
	else
		# If the HNOR partition is available, then unbind driver
		echo "Unbind the ASpeed SMC driver"
		echo 1e630000.spi > /sys/bus/platform/drivers/spi-aspeed-smc/unbind
	fi

	# Switch the Host SPI-NOR to HOST
	gpio_name_set spi0-program-sel 0
	sleep 0.5
}

soft_off() {
	# Trigger shutdown_req
	touch /run/openbmc/host@0-softpoweroff
	gpio_name_set host0-shd-req-n 0
	sleep 0.05
	gpio_name_set host0-shd-req-n 1

	# Wait for shutdown_ack from the host in 30 seconds
	cnt=30
	while [ $cnt -gt 0 ];
	do
		# Wait for SHUTDOWN_ACK and create the host@0-softpoweroff-shutdown-ack
		if [ -f "/run/openbmc/host@0-softpoweroff-shutdown-ack" ]; then
			break
		fi
		sleep 1
		cnt=$((cnt - 1))
	done

	# Softpoweroff is successed
	sleep 2
	rm -rf /run/openbmc/host@0-softpoweroff
	if [ -f "/run/openbmc/host@0-softpoweroff-shutdown-ack" ]; then
		rm -rf /run/openbmc/host@0-softpoweroff-shutdown-ack
	fi
	echo 0
}

force_reset() {
	if [ -f "/run/openbmc/host@0-softpoweroff" ]; then
		# In graceful host reset, after trigger os shutdown,
		# the phosphor-state-manager will call force-warm-reset
		# in this case the force_reset should wait for shutdown_ack from host
		cnt=30
		while [ $cnt -gt 0 ];
		do
			if [ -f "/run/openbmc/host@0-softpoweroff-shutdown-ack" ]; then
				break
			fi
			echo "Waiting for shutdown-ack count down $cnt"
			sleep 1
			cnt=$((cnt - 1))
		done
		# The host OS is failed to shutdown
		if [ $cnt == 0 ]; then
			echo "Shutdown-ack time out after 30s."
			exit 0
		fi
	fi
	rm -f /run/openbmc/host@0-on
	unbind_aspeed_smc_driver
	echo "Triggering sysreset pin"
	gpio_name_set host0-sysreset-n 0
	sleep 1
	gpio_name_set host0-sysreset-n 1
}

bert_file="/usr/share/pldm/bert/bert_trigger"

host_reboot_wa() {
    if [ -f "$bert_file" ]; then
       bert_trigger=$(cat "$bert_file")
       if [ "$bert_trigger" == "1" ]; then
          echo "BERT TRIGGER"
          bind_aspeed_smc_driver
       fi
    fi

    busctl set-property xyz.openbmc_project.State.Chassis \
        /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis \
        RequestedPowerTransition s "xyz.openbmc_project.State.Chassis.Transition.Off"

    while ( true )
    do
        if systemctl status obmc-power-off@0.target | grep "Active: active"; then
            break;
        fi
        sleep 2
    done
    echo "The power is already Off."

    if [ "$bert_trigger" == "1" ]; then
       # Sleep 5 seconds for RAS BERT process completed
       sleep 5
       unbind_aspeed_smc_driver
    fi

    busctl set-property xyz.openbmc_project.State.Host \
        /xyz/openbmc_project/state/host0 xyz.openbmc_project.State.Host \
        RequestedHostTransition s "xyz.openbmc_project.State.Host.Transition.On"
}

if [ ! -d "/run/openbmc/" ]; then
	mkdir -p "/run/openbmc/"
fi

if [ "$2" == "shutdown_ack" ]; then
	shutdown_ack
elif [ "$2" == "status" ]; then
	power_status
elif [ "$2" == "force_reset" ]; then
	force_reset
elif [ "$2" == "host_reboot_wa" ]; then
	host_reboot_wa
elif [ "$2" == "soft_off" ]; then
	ret=$(soft_off)
	if [ "$ret" == 0 ]; then
		echo "The host is already softoff"
	else
		echo "Failed to softoff the host"
	fi
	exit "$ret";
else
	echo "Invalid parameter2=$2"
	usage;
fi

exit 0;
