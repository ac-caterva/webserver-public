#!/bin/bash
#
# 
FILE_NAME=/home/admin/bin/CS_Steuerung_Hilfe.txt
FILE_RIGHTS=444

ssh admin@caterva chmod $FILE_RIGHTS $FILE_NAME

REAL_FILE_RIGHTS=`ssh admin@caterva stat -c '%a' $FILE_NAME`

case $REAL_FILE_RIGHTS in
    $FILE_RIGHTS ) 
        echo SUCCESS;;
    * )
        echo NO_SUCCESS;;
esac        