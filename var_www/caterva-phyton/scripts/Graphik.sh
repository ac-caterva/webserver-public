#!/bin/bash

# Parameter: - -d Datum im Format JJJJ-MM-DD
#            - -h heute

# V2.0: Neue Parameter fuer Datumseingabe und heute
#       Wenn heute uebergeben wurde, dann generiere die txt und
#       png Datei immer wieder neu.

# V1.0: Wenn die Datei invoiceLog fuer ein gegebenes Datum existiert:
#        1. Pruefe, ob es schon eine TXT Datei gibt, falls nicht starte das Phyton Script 
#        um die Textdatei zu erzeugen.
#        2. Pruefe, ob es das Bild zu den Daten schon gibt, falls nicht starte das Phyton
#        Script um das Bild zu erzeugen.
#        3. Kopiere das Bild ins Webserver Verzeichnis

Heute=0

[ $# -eq 0 ] || [ $# -gt 2 ] && echo "Falsche Parameter" 


[ $1 = -h ] && {
    Datum=`date +%F`
    Heute=1 
}
[ $1 = -d ] && {
    Datum=$2
}


[ -f /var/caterva/logs/invoiceLog.${Datum}.csv ] || {
    echo "Datei /var/caterva/logs/invoiceLog.${Datum}.csv  existiert nicht"
    exit
}

echo "1"

if [ $Heute -eq 1 ]
then
# Generiere Textdatei und Graphik immer
    /var/www/caterva-phyton/scripts/SocVonDatum_invoice2txt.py ${Datum}
    /var/www/caterva-phyton/scripts/SocVonDatum_txt2png.py ${Datum}
else 
    if [ ! -f /var/caterva/data/SoC-${Datum}.png ]
    then
        if [ ! -f /var/caterva/data/SoC-${Datum}.txt ]
        then
            # Textdatei muss erzeugt werden
            /var/www/caterva-phyton/scripts/SocVonDatum_invoice2txt.py ${Datum}
        fi
        # Graphik muss erzeugt werden
        /var/www/caterva-phyton/scripts/SocVonDatum_txt2png.py ${Datum}
    fi    
fi

exit 0