#!/bin/bash
DIR=/home/admin/foo 
DIR_USER=fhem
DIR_GROUP=dialout
DIR_RIGHTS=654

if ( [ -d $DIR ] ) ; then
    [ $(stat -c '%U' $DIR) != $DIR_USER ]   && sudo chown $DIR_USER $DIR
    [ $(stat -c '%G' $DIR) != $DIR_GROUP ]  && sudo chgrp $DIR_GROUP $DIR
    [ $(stat -c '%a' $DIR) != $DIR_RIGHTS ] && sudo chmod $DIR_RIGHTS $DIR
else
    sudo mkdir $DIR
    sudo chown $DIR_USER:$DIR_GROUP $DIR
    sudo chmod $DIR_RIGHTS $DIR
fi
