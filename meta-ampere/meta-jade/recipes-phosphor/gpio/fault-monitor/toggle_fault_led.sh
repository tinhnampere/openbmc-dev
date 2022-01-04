#!/bin/sh
#
# Copyright (c) 2021 Ampere Computing LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Toggle the state of identify LED Group

socket=$1
isOn=$2

# Create /tmp/fault* file
if [ "$isOn" == "on" ]; then
	touch /tmp/fault"$socket"
else
	rm /tmp/fault"$socket"
fi

# Set Fault Led state
if [[ -f /tmp/fault0 ]] || [[ -f /tmp/fault1 ]]; then
	target='true'
else
	target='false'
fi

SERVICE="xyz.openbmc_project.LED.GroupManager"
INTERFACE="xyz.openbmc_project.Led.Group"
PROPERTY="Asserted"

# Get current state
object=$(busctl tree $SERVICE --list | grep system_fault)

# Set target state
busctl set-property $SERVICE "$object" $INTERFACE $PROPERTY b $target
