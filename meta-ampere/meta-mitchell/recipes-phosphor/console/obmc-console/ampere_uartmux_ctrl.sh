#!/bin/bash
#

if [ $# -lt 2 ]; then
	exit 1
fi

function set_gpio_active_low() {
	if [ $# -ne 2 ]; then
		echo "set_gpio_active_low: need both GPIO# and initial level";
		return;
	fi

	if [ ! -d /sys/class/gpio/gpio"$1" ]; then
		echo "$1" > /sys/class/gpio/export
	fi
	echo "$2" > /sys/class/gpio/gpio"$1"/direction
}

# 2 gpiochip: chip0 = 816,chip1 = 780,
GPIO_BASE=$(cat /sys/class/gpio/gpio*/base | head -n 1)

# GPIO_UART1_MODE0 = 16; /* GPIO18C0 */
# GPIO_UART1_MODE1 = 17; /* GPIO18C1 */
# GPIO_UART2_MODE0 = 18; /* GPIO18C2 */
# GPIO_UART2_MODE1 = 19; /* GPIO18C3 */
# GPIO_UART3_MODE0 = 20; /* GPIO18C4 */
# GPIO_UART3_MODE1 = 21; /* GPIO18C5 */
# GPIO_UART4_MODE0 = 22; /* GPIO18C6 */
# GPIO_UART4_MODE1 = 23; /* GPIO18C7 */

case "$1" in
	1) GPIO_UARTx_MODE0=16
		 GPIO_UARTx_MODE1=17
		 # CPU0 UART0 connects to BMC UART1
		 CONSOLE_PORT=0
	;;
	2) GPIO_UARTx_MODE0=18
		 GPIO_UARTx_MODE1=19
		 # CPU0 UART1 connects to BMC UART2
		 CONSOLE_PORT=1
	;;
	3) GPIO_UARTx_MODE0=20
		 GPIO_UARTx_MODE1=21
		 # CPU0 UART4 connects to BMC UART3
		 CONSOLE_PORT=2
	;;
	4) GPIO_UARTx_MODE0=22
		 GPIO_UARTx_MODE1=23
		 # CPU1 UART1 connects to BMC UART4
		 CONSOLE_PORT=3
	;;
	*) echo "Invalid UART port selection"
		 exit 1
	;;
esac

# Only switch the MUX when there is no active connection. This means we only
# switch the MUX before the first session starts and after the last session
# closes. We do this by querying number of connected sessions to the socket
# of requested console port.
# Example format:  Accepted: 1; Connected: 1;
CONNECTED=$(systemctl --no-pager status obmc-console-ttyS${CONSOLE_PORT}-ssh.socket | grep -w Connected | cut -d ':' -f 3 | tr -d ' ;')
if [ ! "$CONNECTED" -le 1 ]; then
	exit 0
fi

echo "Ampere UART MUX CTRL UART port $1 to mode $2"

case "$2" in
	# To HDR
	1) set_gpio_active_low $((GPIO_BASE + GPIO_UARTx_MODE0)) high
			set_gpio_active_low $((GPIO_BASE + GPIO_UARTx_MODE1)) low
			exit 0
	;;
	# To BMC
	2) set_gpio_active_low $((GPIO_BASE + GPIO_UARTx_MODE0)) low
			set_gpio_active_low $((GPIO_BASE + GPIO_UARTx_MODE1)) high
			exit 0
	;;
	*) echo "Invalid UART mode selection"
			exit 1
	;;
esac
