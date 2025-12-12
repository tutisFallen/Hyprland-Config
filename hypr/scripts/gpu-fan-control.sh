#!/bin/bash

while true; do
    temp=$(cat /sys/class/drm/card1/device/hwmon/hwmon*/temp1_input)
    temp=$((temp / 1000))

    if [ $temp -lt 45 ]; then
        pwm=77    # 30%
    elif [ $temp -lt 55 ]; then
        pwm=102   # 40%
    elif [ $temp -lt 65 ]; then
        pwm=153   # 60%
    elif [ $temp -lt 75 ]; then
        pwm=204   # 80%
    else
        pwm=255   # 100%
    fi

    echo "1" | sudo tee /sys/class/drm/card1/device/hwmon/hwmon*/pwm1_enable >/dev/null 2>&1
    echo "$pwm" | sudo tee /sys/class/drm/card1/device/hwmon/hwmon*/pwm1 >/dev/null 2>&1

    sleep 3
done
