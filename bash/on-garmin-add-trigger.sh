#!/bin/bash

# split tasks:
# http://ubuntuforums.org/showthread.php?t=1648939

# set script directory
DIRPATH='/home/pi/pi-python-garmin-strava'

touch $DIRPATH/logs/bash.txt
chmod 777 $DIRPATH/logs/bash.txt

# go
echo $DIRPATH/bash/on-garmin-add.sh | at now