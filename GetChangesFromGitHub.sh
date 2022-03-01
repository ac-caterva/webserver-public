#!/bin/bash

# Aktualisiere das lokale Repository - neue Version

cd /home/pi/Git-Clones/webserver-public
git reset --hard
git pull git://github.com/ac-caterva/webserver-public.git
