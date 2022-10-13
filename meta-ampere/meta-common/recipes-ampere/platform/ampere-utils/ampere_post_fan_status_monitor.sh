#!/bin/bash
# shellcheck disable=SC2009

PID=$(ps | grep -i "dbus-monitor --system type='signal',sender='xyz.openbmc_project.Inventory.Manager',member='PropertiesChanged'" | head -n 1 | cut -d' ' -f2)

kill -9 "$PID"
