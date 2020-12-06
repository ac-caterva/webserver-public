#!/bin/bash

# Kopiere Repository nach /usr/local/bin - neue Version

# Parameter -v verbose

if [ $# -gt 0 ] && [ $1 = "-v" ]  # Mindestens ein Parameter UND Parameter_1 ist -v
then 
	do_echo=1
else 
	do_echo=0
fi

# Kopiere Scripte nach /usr/local/bin"
echo "%START% - Kopiere Scripte nach /usr/local/bin"
## eth0_start_192_168_0_50.sh
if [ $do_echo -eq 1 ] 
then
	echo "Kopiere eth0_start_192_168_0_50.sh" 
fi

sudo cp /home/pi/Git-Clones/webserver-public/usr_local_bin/eth0_start_192_168_0_50.sh /usr/local/bin
sudo chown root:root /usr/local/bin/eth0_start_192_168_0_50.sh
sudo chmod 755 /usr/local/bin/eth0_start_192_168_0_50.sh

echo "%END% - Kopiere Scripte nach /usr/local/bin"; echo ""
