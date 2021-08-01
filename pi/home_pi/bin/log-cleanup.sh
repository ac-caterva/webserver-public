#!/bin/bash

if [ ! -f /home/pi/bin/log-rotate ]; then
    touch /home/pi/bin/log-rotate 
fi

/usr/sbin/logrotate -f -s /home/pi/bin/log-rotate /home/pi/bin/log-cleanup.conf
