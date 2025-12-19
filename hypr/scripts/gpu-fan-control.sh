#!/bin/bash

HWMON=$(ls -d /sys/class/drm/card1/device/hwmon/hwmon*)

while true; do
    temp=$(cat "$HWMON/temp1_input")
    temp=$((temp / 1000))

    if [ $temp -lt 45 ]; then
        pwm=77
    elif [ $temp -lt 55 ]; then
        pwm=102
    elif [ $temp -lt 65 ]; then
        pwm=153
    elif [ $temp -lt 75 ]; then
        pwm=204
    else
        pwm=255
    fi

    echo 1 > "$HWMON/pwm1_enable"
    echo "$pwm" > "$HWMON/pwm1"

    sleep 3
done

