#!/bin/bash

# Parameter: keine

# v1.0: Alle Graphiken fuer alle invoiceLog Dateien erstellen

ls /var/caterva/logs/invoiceLog.*.csv | while read CSV_FILENAME
  do
    DATE=`echo $CSV_FILENAME | awk '
		BEGIN { FS = "." }
		{ print $2 }'`
    /var/www/caterva-phyton/scripts/Graphik.sh $DATE
  done
