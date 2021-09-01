#!bin/bash

for filename in /sys/class/hwmon/*/pwm*
do
  echo 255 > $filename
done;
