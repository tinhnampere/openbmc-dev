#!/bin/bash

RAS_SENSOR=(
    ["191"]="CORE CE"
    ["192"]="CORE UE"
    ["193"]="MCU CE"
    ["194"]="MCU UE"
    ["195"]="PCIE CE"
    ["196"]="PCIE UE"
    ["197"]="SOC CE"
    ["198"]="SOC UE"
)

RAS_REGISTRIES=(
    ["191"]="OpenBMC.0.1.CPUError"
    ["192"]="OpenBMC.0.1.CPUError"
    ["193"]="OpenBMC.0.1.MemoryECCCorrectable"
    ["194"]="OpenBMC.0.1.MemoryECCUncorrectable"
    ["195"]="OpenBMC.0.1.PCIeCorrectableInternal"
    ["196"]="OpenBMC.0.1.PCIeFatalUncorrectableInternal"
    ["197"]="OpenBMC.0.1.AmpereCritical.Critical"
    ["198"]="OpenBMC.0.1.AmpereCritical.Critical"
)

function get_redfish_registry_args()
{
    sensor_id=$1
    registry="${RAS_REGISTRIES[$sensor_id]}"
    if [ "$registry" == "OpenBMC.0.1.CPUError" ]; then
        echo "${RAS_SENSOR[$sensor_id]}"
    elif [ "$registry" == "OpenBMC.0.1.MemoryECCCorrectable" ]; then
        # socket, channel, dim, rank
        echo "0xff,0xff,0xff,0xff"
    elif [ "$registry" == "OpenBMC.0.1.MemoryECCUncorrectable" ]; then
        # socket, channel, dim, rank
        echo "0xff,0xff,0xff,0xff"
    elif [ "$registry" == "OpenBMC.0.1.PCIeCorrectableInternal" ]; then
        # bus, device, function
        echo "0xff,0xff,0xff"
    elif [ "$registry" == "OpenBMC.0.1.PCIeFatalUncorrectableInternal" ]; then
            # bus, device, function
        echo "0xff,0xff,0xff"
    elif [ "$registry" == "OpenBMC.0.1.AmpereCritical.Critical" ]; then
        echo "${RAS_SENSOR[$sensor_id]},ERROR"
    fi
}