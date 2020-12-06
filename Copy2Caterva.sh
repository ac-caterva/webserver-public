#!/bin/bash

# Kopiere Scripte zur Caterva

# Parameter -v verbose

if [ $# -gt 0 ] && [ $1 = "-v" ]  # Mindestens ein Parameter UND Parameter_1 ist -v
then 
    set -x
fi

# Kopiere Scripte zur Analyse auf die Caterva
echo "%START% - Kopiere Scripte zur Analyse auf die Caterva"
cd /home/pi/Git-Clones/webserver-public/var_caterva/scripts/analysis
scp -o StrictHostKeyChecking=no *.sh admin@caterva:bin
echo "%END%   - Kopiere Scripte zur Analyse auf die Caterva"
 
