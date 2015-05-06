#!/bin/bash

# allow the garmin time to mount
sleep 10

# grab the path we've passed through
DIRPATH=$1;

# go
source $DIRPATH/env/bin/activate
$DIRPATH/env/bin/python $DIRPATH/upload.py $DIRPATH
deactivate