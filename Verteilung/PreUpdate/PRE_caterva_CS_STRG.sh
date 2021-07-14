#!/bin/bash
#
# 
REPO_BASE_DIR=/home/pi/Git-Clones/webserver


CS_STRG_STOP_FILE=/tmp/CS_SteuerungStop
FILE_NO_DELETE_STOP_FILE=/tmp/NO_DEL_CS_SteuerungStop

function StopFileExists ()
{    
    FILE_EXISTS=`ssh admin@caterva ls $CS_STRG_STOP_FILE 1>/dev/null 2>&1 ; echo $?`
}

function NotDeleteStopFileAfterUpdate ()
{
    ssh admin@caterva touch $FILE_NO_DELETE_STOP_FILE
}

function CreateStopFile ()
{
    ssh admin@caterva touch $CS_STRG_STOP_FILE
}

###########################
# Main
###########################


StopFileExists 
case $FILE_EXISTS in
    0 )
        NotDeleteStopFileAfterUpdate 
        echo SUCCESS;;
    2 ) 
        CreateStopFile 
        sleep 90 
        echo SUCCESS ;;
    * ) 
        echo NO_SUCCESS ;;
esac  