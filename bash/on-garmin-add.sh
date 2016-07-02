#!/bin/bash

# set script directory
DIRPATH='/home/pi/pi-python-garmin-strava'

# allow the garmin time to mount
printf "\n----\n" >> $DIRPATH/logs/bash.txt
echo $(date) >> $DIRPATH/logs/bash.txt

COUNTER=0;
while [  $COUNTER -lt 10 ]; do

    echo Connection attempt $COUNTER >> $DIRPATH/logs/bash.txt
    let COUNTER=COUNTER+1

    if df -h | grep -q "/media/usb0"
    then
        echo "Device found" >> $DIRPATH/logs/bash.txt
        break
    else
        echo "Device not found" >> $DIRPATH/logs/bash.txt
        sleep 5
    fi
done

# go
source $DIRPATH/env/bin/activate
$DIRPATH/env/bin/python $DIRPATH/upload.py $DIRPATH
deactivate

echo Complete >> $DIRPATH/logs/bash.txt
printf "\n----\n" >> $DIRPATH/logs/bash.txt