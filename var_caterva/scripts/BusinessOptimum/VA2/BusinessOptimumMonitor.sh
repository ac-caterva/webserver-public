#!/bin/bash
### BEGIN INFO
# Provides: Different Monitoring Functions for Process BusinessOptimum
# Monitor if BusinessOptimum is still active - disabled
# Copy BusinessOptimum.log to pi-FHEM - /opt/fhem/log
#
#
#Empfohlener Eintrag in /etc/crontab
# sudo nano /etc/crontab
# Monitor BusinessOptimum every 5 min
# */5 * * * *  admin /home/admin/bin/BusinessOptimumMonitor.sh
# 
# Siegfried Quinger - 2021-01-03_19:00
### END INFO



# Copy BusinessOptimum.log to Pi
tail -n 500 /home/admin/bin/BusinessOptimum.log  > /tmp/BusinessOptimum.log
sshpass -p pi scp -o StrictHostKeyChecking=no /tmp/BusinessOptimum.log fhem@192.168.0.50:/opt/fhem/log/BusinessOptimum.log


# Restart BusinessOptimum, if no longer active
# if [ $(ps aux | grep -c "[B]usinessOptimum.sh") = 0 ];
# then
#   nohup /home/admin/bin/BusinessOptimum.sh & 
# fi
