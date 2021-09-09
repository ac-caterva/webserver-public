#!/bin/bash

if [ ! -f /home/admin/bin/CS_log-cleanup ]; then
    touch /home/admin/bin/CS_log-cleanup 
fi

/usr/sbin/logrotate -f -s /home/admin/bin/CS_log-cleanup /home/admin/bin/CS_log-cleanup.conf