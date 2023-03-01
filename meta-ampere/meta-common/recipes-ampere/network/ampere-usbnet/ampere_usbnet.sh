#!/bin/bash

cd /sys/kernel/config/usb_gadget

if [ ! -f "ncm" ]; then
    mkdir ncm
    cd ncm
    echo 0x1d6b > idVendor  # Linux foundation
    echo 0x0104 > idProduct # Multifunction composite gadget
    mkdir -p strings/0x409
    echo "Tinh-openbmc" > strings/0x409/manufacturer
    echo "test-NCM" > strings/0x409/product
    
    mkdir -p configs/c.1
    echo 100 > configs/c.1/MaxPower
    mkdir -p configs/c.1/strings/0x409
    echo "OpenBMC test NCM" > configs/c.1/strings/0x409/configuration
    
    mkdir -p functions/ncm.usb0 
    
    ln -s functions/ncm.usb0 configs/c.1
    
    echo 1e6a0000.usb-vhub:p1 > UDC
fi
exit 0
