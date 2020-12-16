#!/bin/bash
#
#
# Aktualisiere das lokale Repository
/home/pi/Git-Clones/webserver-public/GetChangesFromGitHub.sh

# Kopiere Daten auf den Apache Server (inkl. FHEM)
/home/pi/Git-Clones/webserver-public/Copy2ApacheServer.sh

# Kopiere Daten auf die Pi
/home/pi/Git-Clones/webserver-public/Copy2Pi.sh

# Kopiere Daten auf den Business Controller der Caterva
/home/pi/Git-Clones/webserver-public/Copy2Caterva.sh
