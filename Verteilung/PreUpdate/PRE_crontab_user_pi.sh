#!/bin/bash
#
# 
REPO_BASE_DIR=/home/pi/Git-Clones/webserver

# Install empty crontab
cat $REPO_BASE_DIR/pi/crontabs/user_pi_empty | crontab -u pi -

# sleep 30 Seconds to be sure no job is running
sleep 30

# make sure temp. crontab is installed
crontab -u pi -l > /tmp/contab_user_pi
SUM_INSTALLED=`sum /tmp/contab_user_pi` 
SUM_REPO=`sum $REPO_BASE_DIR/pi/crontabs/user_pi_empty`

if [ "$SUM_INSTALLED" = "$SUM_REPO" ] ; then
    echo SUCCESS
else
    echo NO_SUCCESS
fi
