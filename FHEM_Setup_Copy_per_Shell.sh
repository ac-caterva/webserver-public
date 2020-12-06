#!/bin/bash

# Diese Script sollte nur einmal gestartet werden.

if [ -f /home/pi/Git-Clones/.FHEM_Setup_Copy_per_Shell.did_run ]
then
    echo " Das Scripte wurde bereits ausgefuehrt"
    echo ""
    exit
fi

# User fhem in die Gruppe pi aufnehmen
sudo usermod -a -G pi fhem

# ssh Zugang fuer User fhem
sudo cp /home/pi/.ssh/config  	   /opt/fhem/.ssh/config
sudo cp /home/pi/.ssh/id_rsa       /opt/fhem/.ssh/id_rsa
sudo cp /home/pi/.ssh/known_hosts  /opt/fhem/.ssh/known_hosts

sync

sudo chmod 600 /opt/fhem/.ssh/config
sudo chmod 600 /opt/fhem/.ssh/id_rsa
sudo chown fhem:dialout /opt/fhem/.ssh/config /opt/fhem/.ssh/id_rsa /opt/fhem/.ssh/known_hosts

# Lock Verzeichnis anlegen
## mkdir /var/caterva/lock

# Berechtigungen auf den Verzeichnissen
sudo chmod 775 /var/caterva/data
sudo chmod 775 /var/caterva/logs
sudo chmod 664 /var/caterva/data/invoiceLog.diff.csv
sudo chmod 664 /var/caterva/logs/invoiceLog.csv
## sudo chmod 775 /var/caterva/lock

touch /home/pi/Git-Clones/.FHEM_Setup_Copy_per_Shell.did_run

echo ""
echo "Alles erledigt!"
echo ""

exit
