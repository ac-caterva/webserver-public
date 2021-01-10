#!/bin/bash

# Kopiere Scripte zur Caterva

# Parameter -v verbose


if [ $# -gt 0 ] && [ $1 = "-v" ] ; then # Mindestens ein Parameter UND Parameter_1 ist -v
    set -x
fi

echo "%START% - Kopiere Scripte auf die Caterva"

echo "Scripte zur Analyse"
cd /home/pi/Git-Clones/webserver-public/caterva/analysis
scp -o StrictHostKeyChecking=no *.sh admin@caterva:bin
 
# echo "BusinessOptimumStarter !!!!!!!"
# cd /home/pi/Git-Clones/webserver-public/caterva/BusinessOptimum/
# scp -o StrictHostKeyChecking=no BusinessOptimumStarter.sh admin@caterva:bin
# echo "BusinessOptimum VA1 Scripte !!!!!!!"
# cd /home/pi/Git-Clones/webserver-public/caterva/BusinessOptimum/VA1
# scp -o StrictHostKeyChecking=no * admin@caterva:bin
# echo "BusinessOptimum VA2 Scripte !!!!!!!"
# cd /home/pi/Git-Clones/webserver-public/caterva/BusinessOptimum/VA2
# scp -o StrictHostKeyChecking=no * admin@caterva:bin

echo "%END%   - Kopiere Scripte zur Analyse auf die Caterva"