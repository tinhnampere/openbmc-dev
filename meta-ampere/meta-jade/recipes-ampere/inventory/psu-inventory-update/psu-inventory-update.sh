#!/bin/bash

# Description: This script will update the Dbus object base on
#              The PSU FRU content
#
# This script support the Ampere platform with FRU PSU support on
# I2C6 (PSU0 - 0x50; PSU1 - 0x51)
#
# Syntax: psu-inventory-update.sh [psu-num]
# where: psu-num is the psu number (0 or 1)
#
# Author: Chanh Nguyen <chnguyen@amperecomputing.com>

i2c_chan=6
INVENTORY_SERVICE='xyz.openbmc_project.Inventory.Manager'
INVENTORY_OBJECT='/xyz/openbmc_project/inventory'
INVENTORY_PATH='xyz.openbmc_project.Inventory.Manager'
OBJECT_PATH="/system/chassis/motherboard/powersupply$1"
IVENTORY_IFACE="xyz.openbmc_project.Inventory.Item"
DRIVER_PATH="/sys/bus/i2c/drivers/pmbus/"

pmbus_read() {

  # Syntax: pmbus_read $1 $2 $3 $4
  # Where:  $1 is I2C Channel
  #         $2 is I2C Address
  #         $3 is Data Address
  #         $4 is Data Length

  len=$4

  while [ $len -gt 0 ]
  do

    # The I2C block data reading just support the max length is 32 bytes
    if [ $len -lt 32 ]; then
      data_tmp=$(i2cget -f -y $1 $2 $3 i $len)
      data+=$(echo ${data_tmp} | sed -e "s/$len\: //")
    else
      data_tmp=$(i2cget -f -y $1 $2 $3 i 32)
      data+=$(echo ${data_tmp} | sed -e "s/32\: //")
    fi

    if [[ -z "$data" ]]; then
      echo "i2c$1 device $2 command $3 error" >&2
      exit 1
    fi

    len=$(( $len - 32 ))
    data+=' '
  done

  arry=$(echo ${data} | sed -e "s/$4\: //" | sed -e "s/\0x00//g" | sed -e "s/\0xff//g" | sed -e "s/\0x7f//g" | sed -e "s/\0x0f//g" | sed -e "s/\0x14//g")

  string=''
  for d in ${arry}
  do
    hex=$(echo $d | sed -e "s/0\x//")
    string+=$(echo -e "\x${hex}");
  done

  # Return a result string
  echo $string
}

update_inventory() {
  if [ -z "$6" ]; then
      busctl call \
      ${INVENTORY_SERVICE} \
      ${INVENTORY_OBJECT} \
      ${INVENTORY_PATH} \
      Notify a{oa{sa{sv}}} 1 \
      ${OBJECT_PATH} 1 $2 $3 \
      $4 $5 ""
  else
      busctl call \
      ${INVENTORY_SERVICE} \
      ${INVENTORY_OBJECT} \
      ${INVENTORY_PATH} \
      Notify a{oa{sa{sv}}} 1 \
      ${OBJECT_PATH} 1 $2 $3 \
      $4 $5 $6
  fi
}


if [ $# -eq 0 ]; then
  echo 'No PSU device is given' >&2
  exit 1
fi

if [ $1 -eq 0 ]; then
  i2c_addr=0x50
  driver_name="${i2c_chan}-0058"
elif [ $1 -eq 1 ]; then
  i2c_addr=0x51
  driver_name="${i2c_chan}-0059"
else
  echo "ERROR: The PSU $1 device is not correctly"
  exit 1
fi

# Check if the powersupply object dbus exist
error=$( busctl introspect ${INVENTORY_SERVICE} ${INVENTORY_OBJECT}${OBJECT_PATH} )
if [[ $? -ne 0 ]]; then
  echo "ERROR: Not Found ${INVENTORY_OBJECT}${OBJECT_PATH}"
  exit 1
fi

# Check if the powersupply present
if [ -e ${DRIVER_PATH}${driver_name} ]; then
  result=$( pmbus_read $i2c_chan $i2c_addr 0x24 12)
  update_inventory $1 "xyz.openbmc_project.Inventory.Decorator.Asset" 1 "Manufacturer" "s" $result

  result=$( pmbus_read $i2c_chan $i2c_addr 0x31 36)
  update_inventory $1 "xyz.openbmc_project.Inventory.Decorator.Asset" 1 "Model" "s" $result

  result=$( pmbus_read $i2c_chan $i2c_addr 0x56 16)
  update_inventory $1 "xyz.openbmc_project.Inventory.Decorator.Asset" 1 "PartNumber" "s" $result

  result=$( pmbus_read $i2c_chan $i2c_addr 0x78 14)
  update_inventory $1 "xyz.openbmc_project.Inventory.Decorator.Asset" 1 "SerialNumber" "s" $result
else
  echo "WARNING: The powersupply$1 is not present"
  update_inventory $1 "xyz.openbmc_project.Inventory.Decorator.Asset" 1 "Manufacturer" "s" ""
  update_inventory $1 "xyz.openbmc_project.Inventory.Decorator.Asset" 1 "Model" "s" ""
  update_inventory $1 "xyz.openbmc_project.Inventory.Decorator.Asset" 1 "PartNumber" "s" ""
  update_inventory $1 "xyz.openbmc_project.Inventory.Decorator.Asset" 1 "SerialNumber" "s" ""
fi

