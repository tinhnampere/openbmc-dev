#!/bin/bash

# global variables
    fan_status_file='/tmp/fan_status_data'
    failed_fan="false"
    failed_fan_flag='/tmp/fan_failed'
    fan_status_changed_list=()
    fan_status_raw=()

    # maintain a failure fan list
    failed_fan_list=()
    read_fan_status_file="cat $fan_status_file"

print_array() {
    local -n array=$1

    for each in "${array[@]}"
    do
        echo "$each"
    done
}

which_platform() {
    local tmp

    tmp=$(uname -a | cut -d' ' -f2)
    echo "$tmp"
}

# remove element in array and rearrange the element order
rm_element_arr() {
    eval "$1=( \"\${$1[@]:0:$2}\" \"\${$1[@]:$(($2+1))}\" )"
}

init_env() {
    touch "$fan_status_file"
    dbus-monitor --system "type='signal',sender='xyz.openbmc_project.Inventory.Manager',member='PropertiesChanged', \
                       arg0namespace='xyz.openbmc_project.State.Decorator.OperationalStatus'" > "$fan_status_file" &
}

get_fan_status_raw() {
    local tmp 
    
    tmp=$(which_platform)
    if [ "$tmp" == "mtjade" ]; then
        mapfile -t fan_status_raw < <($read_fan_status_file | grep -i fan | cut -d' ' -f8 | cut -d'=' -f2 | cut -c1-58)
    else
        mapfile -t fan_status_raw < <($read_fan_status_file | grep -i fan | cut -d' ' -f8 | cut -d'=' -f2 | cut -c1-63)
    fi
}

# This function gets the list of all fans which their status changed
get_fan_status_changed_list() {
    get_fan_status_raw
    if [ ${#fan_status_raw[@]} -eq 0 ]; then
        fan_status_changed_list=()
        return
    fi

    local tmp=''
    local i=0

    for each in "${fan_status_raw[@]}"
    do
        if [ "$tmp" != "$each" ]; then
            fan_status_changed_list[i]=$each
            i=$((i+1))
            tmp=$each
        fi
    done
}

# $1: array_name, $2: element_position
rm_element_in_array() {
    local -n arr=$1
    local tmp
    tmp="$(printf '%d\n' "$2" 2>/dev/null)"
    
    rm_element_arr arr "$tmp"
}

# $1: array_name, $2: element_name
append_element_to_array() {
    local -n arr=$1
    local len=${#arr[@]}

    arr[$len]=$2
}

read_fan_status() {
    local tmp

    tmp=$($read_fan_status_file | grep -I "$1" -A 6 | grep -I Functional -A 1 | grep -I variant | tail -n 1 | cut -d' ' -f24)
    echo "$tmp"
}

# $1: array_name, $2: element_name
# return index of element, otherwise return -1 if not found any
find_element_in_arr() {
    local -n array=$1

    for (( i=0; i<${#array[@]}; i++ ));
    do
        if [ "${array[$i]}" == "$2" ]; then
            echo "$i"
        fi
    done

    echo -1
}

update_failed_fan_list() {
    local tmp
    local pos
    local fan_name
    
    for each in "${fan_status_changed_list[@]}" 
    do
        pos=$(find_element_in_arr failed_fan_list "$each")
        tmp=$(read_fan_status "$each")
        fan_name=${each##*"/"}
        if [ "$tmp" == "false" ]; then
            echo "Warning: Fan $each failed"
            # OpenBMC.0.1.AmpereWarning requires 2 arguments
            ampere_add_redfishevent.sh OpenBMC.0.1.AmpereWarning "$fan_name,returned failure"
            if [ "$pos" == "-1" ]; then
                append_element_to_array failed_fan_list "$each"
            fi
        else
            echo "Notice: Fan $each OK"
            # OpenBMC.0.1.AmpereEvent requires 1 argument
            ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.OK "$fan_name returned to OK"
            if [ "$pos" != "-1" ]; then
                rm_element_in_array failed_fan_list "$pos"
            fi
        fi
    done
}

is_failed_fan_list_empty() {
    if [ ${#failed_fan_list[@]} -eq 0 ]; then
        failed_fan="false"
    else
        failed_fan="true"
        echo "Failed fan list:"
        print_array failed_fan_list
    fi
}

set_failed_fan_flag() {
    is_failed_fan_list_empty
    if [ "$failed_fan" == "true" ]; then
        if [[ ! -f $failed_fan_flag ]]; then        
            touch "$failed_fan_flag"
        fi
    else
        if [[ -f $failed_fan_flag ]]; then
            rm "$failed_fan_flag"
        fi
    fi
}

# daemon start
init_env

while true
do
    get_fan_status_changed_list
    # just start over the loop if there is no fan changes status
    if [ ${#fan_status_changed_list[@]} -ne 0 ]; then
        echo "Notice: fan(s) change status"
        update_failed_fan_list
        set_failed_fan_flag
    fi

    # clean fan status file and start over
    echo > $fan_status_file
    sleep 2
done

exit 1
