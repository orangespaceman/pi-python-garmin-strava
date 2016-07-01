#!/bin/bash

# allow the garmin time to mount
sleep 10

COUNTER=0;
while [  $COUNTER -lt 5 ]; do

    echo Attempt $COUNTER
    let COUNTER=COUNTER+1

    if df -h | grep -q "/media/usb0"
    then
        echo "DEVICE FOUND"
        break
    else
        echo "DEVICE NOT FOUND"
        sleep 10
    fi
done

# grab the path we've passed through
DIRPATH=$1;

# go
source $DIRPATH/env/bin/activate
$DIRPATH/env/bin/python $DIRPATH/upload.py $DIRPATH
deactivate