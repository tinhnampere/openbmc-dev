#!/bin/bash

cd /sys/kernel/config/usb_gadget

if [ ! -f "ecm" ]; then
    mkdir ecm
    cd ecm
    echo 0x1d6b > idVendor  # Linux foundation
    echo 0x0104 > idProduct # Multifunction composite gadget
    mkdir -p strings/0x409
    echo "Tinh-openbmc" > strings/0x409/manufacturer
    echo "test-ECM" > strings/0x409/product
    
    mkdir -p configs/c.1
    echo 100 > configs/c.1/MaxPower
    mkdir -p configs/c.1/strings/0x409
    echo "OpenBMC test ECM" > configs/c.1/strings/0x409/configuration
    
    mkdir -p functions/ecm.usb0 
    
    ln -s functions/ecm.usb0 configs/c.1
    
    echo 1e6a0000.usb-vhub:p1 > UDC
fi
exit 0
