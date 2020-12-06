#!/bin/bash

# Parameter: Anzahl Tage

# Loesche /var/log/invoiceLog.[YYYY-MM-DD].csv Dateien, welche aelter als 
# angegeben Tage alt sind.


# Caterva Logs
find /var/caterva/logs -name invoiceLog.\*.csv -mtime $1 -exec rm {} \;

# Webserver Dateien
find /var/caterva/data -name SoC-*.txt -mtime $1 -exec rm {} \;
find /var/caterva/data -name SoC-*.png -mtime $1 -exec rm {} \;

exit 0
