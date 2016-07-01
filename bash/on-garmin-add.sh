#!/bin/bash

# set script directory
DIRPATH='/home/pi/pi-python-garmin-strava'

# allow the garmin time to mount
printf "\n----\n" >> $DIRPATH/logs/bash.txt
echo $(date) >> $DIRPATH/logs/bash.txt

sleep 10

COUNTER=0;
while [  $COUNTER -lt 5 ]; do

    echo Attempt $COUNTER >> $DIRPATH/logs/bash.txt
    let COUNTER=COUNTER+1

    if df -h | grep -q "/media/usb0"
    then
        echo "Found" >> $DIRPATH/logs/bash.txt
        break
    else
        echo "Not found" >> $DIRPATH/logs/bash.txt
        sleep 10
    fi
done

# go
source $DIRPATH/env/bin/activate
$DIRPATH/env/bin/python $DIRPATH/upload.py $DIRPATH
deactivate

printf "\n----\n" >> $DIRPATH/logs/bash.txt