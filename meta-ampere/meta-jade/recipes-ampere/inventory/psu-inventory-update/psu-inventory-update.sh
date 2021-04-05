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

pmbus_read() {

  # Syntax: pmbus_read $1 $2 $3 $4
  # Where:  $1 is I2C Channel
  #         $2 is I2C Address
  #         $3 is Data Address
  #         $4 is Data Length

  add=$3
  len=$4

  # The I2C block data reading support read block by block with
  # the block size is 8 bytes

  add_base=$(( $add / 8 ))
  add_offset=$(( $add % 8 ))
  len=$(( $len + $add_offset ))

  while [ $len -gt 0 ]
  do
    # The I2C block data reading just support the max length is 32 bytes
    if [ $len -lt 32 ]; then
      data_tmp=$(i2cget -f -y $1 $2 $add_base i $len)
      data+=$(echo ${data_tmp} | sed -e "s/$len\: //")
    else
      data_tmp=$(i2cget -f -y $1 $2 $add_base i 32)
      data+=$(echo ${data_tmp} | sed -e "s/32\: //")
    fi

    if [[ $? -ne 0 ]]; then
      echo "ERROR: i2c$1 device $2 command $3 error. Also check if the PSU presence?"
      exit 1
    fi

    len=$(( $len - 32 ))
    data+=' '
    add_base=$(( $add_base + 1 ))
  done

  i=0
  string=''
  for d in ${data}
  do
    # Split the data, which was read as a redundancy data
    if [ $i -ge $add_offset ]; then
      hex=$(echo $d | sed -e "s/0\x//")
      string+=$(echo -e "\x${hex}");
    fi
    ((i++))
  done

  echo $string
}

update_inventory() {
  busctl call \
      ${INVENTORY_SERVICE} \
      ${INVENTORY_OBJECT} \
      ${INVENTORY_PATH} \
      Notify a{oa{sa{sv}}} 1 \
      ${OBJECT_PATH} 1 $2 $3 \
      $4 $5 $6
}


if [ $# -eq 0 ]; then
  echo 'No PSU device is given' >&2
  exit 1
fi

if [ $1 -eq 0 ]; then
  i2c_addr=0x50
elif [ $1 -eq 1 ]; then
  i2c_addr=0x51
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

result=$( pmbus_read $i2c_chan $i2c_addr 0x24 12)
update_inventory $1 "xyz.openbmc_project.Inventory.Decorator.Asset" 1 "Manufacturer" "s" $result

result=$( pmbus_read $i2c_chan $i2c_addr 0x31 36)
update_inventory $1 "xyz.openbmc_project.Inventory.Decorator.Asset" 1 "Model" "s" $result

result=$( pmbus_read $i2c_chan $i2c_addr 0x56 16)
update_inventory $1 "xyz.openbmc_project.Inventory.Decorator.Asset" 1 "PartNumber" "s" $result

result=$( pmbus_read $i2c_chan $i2c_addr 0x78 14)
update_inventory $1 "xyz.openbmc_project.Inventory.Decorator.Asset" 1 "SerialNumber" "s" $result
