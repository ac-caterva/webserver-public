#!/bin/bash
#
# 
REPO_BASE_DIR=/home/pi/Git-Clones/webserver


CS_STRG_STOP_FILE=/tmp/CS_SteuerungStop
FILE_NO_DELETE_STOP_FILE=/tmp/NO_DEL_CS_SteuerungStop

function NotDeleteStopFileAfterUpdateExists ()
{    
    FILE_EXISTS=`ssh -n admin@caterva ls $FILE_NO_DELETE_STOP_FILE 1>/dev/null 2>&1 ; echo $?`
}


function DeleteStopFile ()
{
    ssh -n admin@caterva rm $CS_STRG_STOP_FILE
}


function DeleteNotDeleteStopFileAfterUpdate ()
{
    ssh -n admin@caterva rm $FILE_NO_DELETE_STOP_FILE
}

###########################
# Main
###########################


NotDeleteStopFileAfterUpdateExists 
case $FILE_EXISTS in
    0 )
        DeleteNotDeleteStopFileAfterUpdate 
        echo SUCCESS;;
    2 ) 
        DeleteStopFile 
        echo SUCCESS;;
    * )
        echo NO_SUCCESS;;    
esac  