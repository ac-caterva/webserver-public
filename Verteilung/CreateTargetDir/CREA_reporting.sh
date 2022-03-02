#!/bin/bash
DIR=/var/caterva/caterva-reporting
DIR_USER=pi
DIR_GROUP=pi
DIR_RIGHTS=755

if ( [ -d $DIR ] ) ; then
    [ $(stat -c '%U' $DIR) != $DIR_USER ]   && sudo chown $DIR_USER $DIR
    [ $(stat -c '%G' $DIR) != $DIR_GROUP ]  && sudo chgrp $DIR_GROUP $DIR
    [ $(stat -c '%a' $DIR) != $DIR_RIGHTS ] && sudo chmod $DIR_RIGHTS $DIR
else
    sudo mkdir $DIR
    sudo chown $DIR_USER:$DIR_GROUP $DIR
    sudo chmod $DIR_RIGHTS $DIR
fi

if ( [ -d $DIR ] ) ; then
    [ $(stat -c '%U' $DIR) == $DIR_USER ]   && SUCCESS_COUNTER=`expr $SUCCESS_COUNTER + 1`
    [ $(stat -c '%G' $DIR) == $DIR_GROUP ]  && SUCCESS_COUNTER=`expr $SUCCESS_COUNTER + 1`
    [ $(stat -c '%a' $DIR) == $DIR_RIGHTS ] && SUCCESS_COUNTER=`expr $SUCCESS_COUNTER + 1`
    if [ ${SUCCESS_COUNTER} -eq 3 ] ; then
        echo "SUCCESS"
    else
        echo "NO_SUCCESS"    
    fi    
else
    echo "NO_SUCCESS"   
fi    