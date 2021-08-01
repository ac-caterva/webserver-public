#!/bin/bash
#
# 
REPO_BASE_DIR=/home/pi/Git-Clones/webserver

# Install real crontab
cat $REPO_BASE_DIR/pi/crontabs/user_pi | crontab -u pi -

# make sure real crontab is installed
crontab -u pi -l > /tmp/contab_user_pi
SUM_INSTALLED=`sum /tmp/contab_user_pi` 
SUM_REPO=`sum $REPO_BASE_DIR/pi/crontabs/user_pi`

if [ "$SUM_INSTALLED" = "$SUM_REPO" ] ; then
    echo SUCCESS
else
    echo NO_SUCCESS
fi
