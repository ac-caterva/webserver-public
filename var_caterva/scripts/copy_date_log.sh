#!/bin/bash

# Paramater: Datum im Format: YYYY-MM-DD


# Kopiere /var/log/invoiceLog.csv.YYYY-MM-DD auf die Pi ins Verzeichnis 
# /var/caterva/logs. Entpacke die Datei und nenne sie invoiceLog.YYYY-MM-DD.csv

DATE=$1

scp admin@caterva:/var/log/invoiceLog.csv.${DATE}.gz /var/caterva/logs
gunzip /var/caterva/logs/invoiceLog.csv.${DATE}.gz
mv /var/caterva/logs/invoiceLog.csv.${DATE} /var/caterva/logs/invoiceLog.${DATE}.csv

exit 0
