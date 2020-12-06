#!/bin/bash

# Kopiere Repository nach /var/www - neue Version

# Parameter -v verbose

if [ $# -gt 0 ] && [ $1 = "-v" ]  # Mindestens ein Parameter UND Parameter_1 ist -v
then 
    tar_opt=cvf
else 
    tar_opt=cf
fi

# # Kopiere Scripte des Webservers
# echo "%START% - Kopiere Scripte des Webservers /var/www"
# cd /home/pi/Git-Clones/webserver/var_www
# tar ${tar_opt} - caterva caterva-phyton | ( cd /var/www ; tar xf - )

# sudo chgrp www-data /var/www/caterva-phyton/scripts/*
# sudo chmod 754 /var/www/caterva-phyton/scripts/*

# sudo chgrp www-data /var/www/caterva/*.php /var/www/caterva/*.png /var/www/caterva/*.html
# chmod 660 /var/www/caterva/*.php /var/www/caterva/*.png
# echo "%END% - Kopiere Scripte des Webservers" ; echo ""


# Kopiere Scripte um Daten von der Caterva zu kopieren
echo "%START% - Kopiere Scripte um Daten von der Caterva zu kopieren /var/caterva"
cd /home/pi/Git-Clones/webserver/var_caterva
tar ${tar_opt} - . | ( cd /var/caterva ; tar xf -)
chmod 754 /var/caterva/scripts/*.sh
chmod 754 /var/caterva/scripts/fhem/*.py
echo "%END% - Kopiere Scripte um Daten von der Caterva zu kopieren" ; echo ""

# Kopiere FHEM Dateien
echo "%START% - Kopiere FHEM Dateien /opt/fhem"

sudo systemctl stop fhem

## Sichere /opt/fhem/FHEM/00_Private.cfg
if [ -f /opt/fhem/FHEM/00_Private.cfg ] 
then
    sudo mv /opt/fhem/FHEM/00_Private.cfg /opt/fhem/FHEM/00_Private.cfg.save
fi

## kopiere mittels einpacken als tar und entpacken
cd /home/pi/Git-Clones/webserver/opt_fhem
tar ${tar_opt} - . | ( cd /opt/fhem ; sudo tar xf -)

## Restauriere /opt/fhem/FHEM/00_Private.cfg
if [ -f /opt/fhem/FHEM/00_Private.cfg.save ]
then	
    sudo mv /opt/fhem/FHEM/00_Private.cfg.save /opt/fhem/FHEM/00_Private.cfg 
fi  

## setzte Berechtigungen
sudo chown fhem:dialout /opt/fhem
sudo chown -R fhem:dialout /opt/fhem/fhem.cfg /opt/fhem/FHEM /opt/fhem/www
sudo chmod 664 /opt/fhem/log/ESS*.log

sudo systemctl start fhem
echo "%END% - Kopiere FHEM Dateien" ; echo ""


 
