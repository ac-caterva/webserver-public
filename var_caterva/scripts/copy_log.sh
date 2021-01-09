#!/bin/bash

# 1. Kopiere /var/log/invoiceLog.csv auf die Pi ins Verzeichnis /var/caterva/logs
#    Sortiere die Daten
# 2. Erzeuge eine Datei mit der Differenz zur zuletzt kopierten Datei
#    - beruecksichtige den Fall, dass es noch keine Datei fuer den Tag gibt
# 3. Benenne die kopierte Datei um, damit sie als Grundlage fuer die naechste
#    Bildung der Differenz als Vergleich zur Verfuegung steht.
# 4. Starte das Python Scripot um die Differenz ans FHEM Log anzuhaengen

LOCK_FILE=/tmp/copy_log.lock

##############################################
# func_exit
function func_exit ()
{
    rm $LOCK_FILE
    exit 0
}    



##############################################
# MAIN
##############################################


trap 'func_exit' 1 2 15

[ -f $LOCK_FILE ] && exit

echo $$ > $LOCK_FILE

DATE=`date +%F`    # Format 2020-12-31

# 1. Kopiere /var/log/invoiceLog.csv auf die Pi ins Verzeichnis /var/caterva/logs
scp admin@caterva:/var/log/invoiceLog.csv /var/caterva/logs/
sort /var/caterva/logs/invoiceLog.csv > /var/caterva/logs/invoiceLog.sorted.csv

# 2. Erzeuge eine Datei mit der Differenz zur zuletzt kopierten Datei
#    - beruecksichtige den Fall, dass es noch keine Datei fuer den Tag gibt
if [ -f /var/caterva/logs/invoiceLog.${DATE}.csv ] 
then
    # Erzeuge Datei mit den Differenzen seit der letzten Kopie
    comm -23 /var/caterva/logs/invoiceLog.sorted.csv /var/caterva/logs/invoiceLog.${DATE}.csv \
        > /var/caterva/data/invoiceLog.diff.csv
else
    # Neue Datei alles ist die Differenz       
    cp /var/caterva/logs/invoiceLog.sorted.csv /var/caterva/data/invoiceLog.diff.csv
fi

# 3. Benenne die kopierte Datei um, damit sie als Grundlage fuer die naechste
#    Bildung der Differenz als Vergleich zur Verfuegung steht.
mv /var/caterva/logs/invoiceLog.sorted.csv /var/caterva/logs/invoiceLog.${DATE}.csv

# 4. Starte das Python Scripot um die Differenz ans FHEM Log anzuhaengen
/var/caterva/scripts/fhem/appendInvoiceLog2fhem.py

func_exit
