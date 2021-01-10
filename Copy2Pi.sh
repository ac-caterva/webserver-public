#!/bin/bash

# Kopiere Repository nach /usr/local/bin - neue Version
DO_ECHO=0


# Parameter -v verbose
if [ $# -gt 0 ] && [ $1 = "-v" ]; then  # Mindestens ein Parameter UND Parameter_1 ist -v
	DO_ECHO=1
fi


########################################################################
# Scripte 
###########
echo "%START% - Kopiere Scripte"

echo "Kopiere Scripte nach /usr/local/bin"
## eth0_start_192_168_0_50.sh
if [ $DO_ECHO -eq 1 ] ; then
	echo "Kopiere eth0_start_192_168_0_50.sh" 
fi
sudo cp /home/pi/Git-Clones/webserver-public/pi/usr_local_bin/eth0_start_192_168_0_50.sh /usr/local/bin
sudo chown root:root /usr/local/bin/eth0_start_192_168_0_50.sh
sudo chmod 755 /usr/local/bin/eth0_start_192_168_0_50.sh


echo "Kopiere Scripte nach /var/caterva/scripts"
# copy_log.sh
if [ $DO_ECHO -eq 1 ] ; then
	echo "Kopiere copy_log.sh" 
fi
cp /home/pi/Git-Clones/webserver-public/pi/var/caterva/scripts/copy_log.sh /var/caterva/scripts

echo "%END% - Kopiere Scripte" ; echo ""
########################################################################

echo "%START% - Installiere crontabs"
# Installiere die crontab fuer den Benutzer pi
if [ $DO_ECHO -eq 1 ] ; then
	echo "Installiere die crontab fuer den Benutzer pi" 
fi

cat /home/pi/Git-Clones/webserver-public/pi/crontabs/user_pi | crontab -

echo "%END% - Installiere crontabs"; echo ""
