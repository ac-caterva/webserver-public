#!/bin/bash
sudo cp \
 /home/pi/Git-Clones/webserver/pi/usr_local_bin/eth0_start_192_168_0_50.sh \
 /usr/local/bin/eth0_start_192_168_0_50.sh
sudo chown root:root /usr/local/bin/eth0_start_192_168_0_50.sh
sudo chmod 755 /usr/local/bin/eth0_start_192_168_0_50.sh
exit
