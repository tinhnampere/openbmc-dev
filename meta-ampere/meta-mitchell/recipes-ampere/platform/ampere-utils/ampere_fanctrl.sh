#!/bin/bash

function stop_phosphor_fan_services() {
    systemctl stop phosphor-fan-control@0.service
    systemctl stop phosphor-fan-monitor@0.service
    systemctl stop phosphor-fan-presence-tach@0.service
}

function start_phosphor_fan_services() {
    systemctl start phosphor-fan-control@0.service
    systemctl start phosphor-fan-monitor@0.service
    systemctl start phosphor-fan-presence-tach@0.service
}

function read_speed() {
    if [ -f "/sys/class/hwmon/hwmon0/fan$1_input" ]; then
        cat "/sys/class/hwmon/hwmon0/fan$1_input"
    else
        echo "fan $1 doesn't exit"
    fi
}

function set_pwm() {
    if [ -d "/sys/devices/platform/pwm-fan$1/" ]; then
        # Convert Fan Duty cycle to PWM, adding 50 for rounding.
        fan_pwm=$(((($2 * 255) + 50) / 100))
        find /sys/devices/platform/pwm-fan"$1"/ -name "pwm1" -print0 | xargs -I {} sh -c "echo $fan_pwm > {}"
    else
        echo "cannot set the pwm $2 for fan$1"
    fi
}

function getstatus() {
    fan_ctl_stt=$(systemctl is-active phosphor-fan-control@0.service | grep inactive)
    fan_monitor_stt=$(systemctl is-active phosphor-fan-monitor@0.service | grep inactive)
    if [[ -z "$fan_ctl_stt" && -z "$fan_monitor_stt" ]]; then
        echo 0
    else
        echo 1
    fi
}

function setstatus() {
    if [ "$1" == 0 ]; then
        # Enable fan services
        start_phosphor_fan_services
    else
        # Disable fan services
        stop_phosphor_fan_services
    fi
}

function setspeed() {
    # Get fan_pwm value of the fan
    case "$1" in
    0) fan_pwm=7
    ;;
    1) fan_pwm=5
    ;;
    2) fan_pwm=4
    ;;
    3) fan_pwm=3
    ;;
    4) fan_pwm=1
    ;;
    5) fan_pwm=0
    ;;
    *) echo "fan $1 doesn't exit"
        exit 1
    ;;
    esac

    set_pwm "$fan_pwm" "$2"
}

function getspeed() {
    # Mapping fan number to fan_input and pwm-fan index
    case "$1" in
    0) fan_input_f=15
       fan_input_r=16
       fan_pwm=7
    ;;
    1) fan_input_f=11
       fan_input_r=12
       fan_pwm=5
    ;;
    2) fan_input_f=9
       fan_input_r=10
       fan_pwm=4
    ;;
    3) fan_input_f=7
       fan_input_r=8
       fan_pwm=3
    ;;
    4) fan_input_f=3
       fan_input_r=4
       fan_pwm=1
    ;;
    5) fan_input_f=1
       fan_input_r=2
       fan_pwm=0
    ;;
    *) echo "fan $1 doesn't exit"
        exit 1
    ;;
    esac

    # Get fan speed, each fan number has two values is front and rear
    fan_speed_f=$(read_speed "$fan_input_f")
    fan_speed_r=$(read_speed "$fan_input_r")
    pwm=$(find /sys/devices/platform/pwm-fan"$fan_pwm"/ -name "pwm1" -print0 | xargs -I {} sh -c "cat {}")
    # Convert fan PWM to Duty cycle, adding 127 for rounding.
    fan_duty=$(((("$pwm" * 100) + 127) / 255))

    echo "FAN$1_F, PWM: $pwm, Duty cycle: $fan_duty%, Speed(RPW): $fan_speed_f"
    echo "FAN$1_R, PWM: $pwm, Duty cycle: $fan_duty%, Speed(RPW): $fan_speed_r"
}

# Usage of this utility
function usage() {
    echo "Usage:"
    echo "  ampere_fanctrl.sh [getstatus] [setstatus <0|1>] [setspeed <fan> <duty>] [getspeed <fan>]"
    echo "  fan: 0-5"
    echo "  duty: 1-100"
}

if [ "$1" == "getstatus" ]; then
    getstatus
elif [ "$1" == "setstatus" ]; then
    setstatus "$2"
elif [ "$1" == "setspeed" ]; then
    stop_phosphor_fan_services
    setspeed "$2" "$3"
elif [ "$1" == "getspeed" ]; then
    getspeed "$2"
else
    usage
fi
