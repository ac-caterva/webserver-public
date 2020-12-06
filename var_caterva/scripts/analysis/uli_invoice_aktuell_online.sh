#!/bin/bash 
#v1 Neuerstellung
#v2 Alarm eingefuegt loeschen Zwischenprodukte
#v3 Zaehlerstaende errechnet
#v4 Zählerstaende erweitert
#v5 ssh auf $HOMR mdex gestellt, SoC fuer Start und Ende, Wirkungsgrad
#v6 Wirkunksgrad auskommentiert verwirrt zu viele, loeschen ohne verbose, aufgehuebscht 
#v6 Zaehler ergänzt / wenn keine gen2 Anlage ESS Charge/Discarge vertauscht / kopieren rausgenommen nor noch tail head auf Orginaldatei
#v7 Wenn keine gen2 Anlage ESS Charge/Discarge vertauscht

echo -e "\033[0;32m Script zum anzeigen aktueller Werte und Tagesverbrauch.\033[0m"

mkdir /tmp/invoicetmp
cd /tmp/invoicetmp

tail -1 /var/log/invoiceLog.csv >> plottail.csv
head -1 /var/log/invoiceLog.csv >> plothead.csv

#Pruefen ob eine gen2 Anlage (Bei aelteren Anlagen ist charge / discharge der ESS vertauscht)
if [ -f /home/admin/registry/out/gen2 ]
        then
        _discargeESSwatt_=$(awk -F ";" '{print $17}' plottail.csv)
        _chargeESSwatt_=$(awk -F ";" '{print $18}' plottail.csv)
        _dischargeESScount_=$(($(awk -F ";" '{print $21}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $21}' plothead.csv | cut -d "." -f1)))
        _chargeESScount_=$(($(awk -F ";" '{print $22}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $22}' plothead.csv | cut -d "." -f1)))
        else
        _discargeESSwatt_=$(awk -F ";" '{print $18}' plottail.csv)
        _chargeESSwatt_=$(awk -F ";" '{print $17}' plottail.csv)
        _dischargeESScount_=$(($(awk -F ";" '{print $22}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $22}' plothead.csv | cut -d "." -f1)))
        _chargeESScount_=$(($(awk -F ";" '{print $21}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $21}' plothead.csv | cut -d "." -f1)))
fi

echo " "
echo -e "\033[0;32m Aktuelle Leisuntswerte                                       AKTELLE WERTE\033[0m"
echo "Grid -> Household in W / Stromnetz -> Haus                       $(awk -F ";" '{print $8}' plottail.csv) W"
echo "Battery -> Household in W / Batterie -> Haus                     $(awk -F ";" '{print $9}' plottail.csv) W"
echo "PV -> Household in W / PV -> Haus                                $(awk -F ";" '{print $10}' plottail.csv) W"
echo "PV -> Battery in W / PV -> Batterie                              $(awk -F ";" '{print $11}' plottail.csv) W"
echo "PV -> Grid in W / PV -> Stromnetz                                $(awk -F ";" '{print $12}' plottail.csv) W"
echo "PV power provision in W                                          $(awk -F ";" '{print $14}' plottail.csv) W"
echo "Household demand in W / Hausverbrauch                            $(awk -F ";" '{print $15}' plottail.csv) W"
echo "Neg. Inverter AC power in W / Entladung Speicher AC              ${_discargeESSwatt_} W"
echo "Pos. Inverter AC power in W / Ladung Speicher AC                 ${_chargeESSwatt_} W"
echo " "

echo -e "\033[0;32m Ladezustand Speicher Tagesbeginn und aktuell.\033[0m"
echo "Startzeit       $(awk -F ";" '{print $2}' plothead.csv)          Ladezustand Speicher     $(awk -F ";" '{print $16}' plothead.csv) %"
echo "Endzeit         $(awk -F ";" '{print $2}' plottail.csv)          Ladezustand Speicher     $(awk -F ";" '{print $16}' plottail.csv) %"
echo " "

echo -e "\033[0;32m Zählerstände des Aktellen Tages.\033[0m"
echo "ESS counter level discharge in Wh / Zähler Entladen Batterie     ${_dischargeESScount_} Wh"
echo "ESS counter level charge in Wh / Zähler Laden Batterie           ${_chargeESScount_} Wh" 
echo " "

#Zähler in Variablen um besser rechnen zu können
_HH_=$(($(awk -F ";" '{print $25}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $25}' plothead.csv | cut -d "." -f1)))
_ESS2HH_=$(($(awk -F ";" '{print $35}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $35}' plothead.csv | cut -d "." -f1)))
_PV_=$(($(awk -F ";" '{print $28}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $28}' plothead.csv | cut -d "." -f1)))
_PV2ESS_=$(($(awk -F ";" '{print $36}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $36}' plothead.csv | cut -d "." -f1)))
_GRIDPLUSESS2HH_=$(($(awk -F ";" '{print $32}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $32}' plothead.csv | cut -d "." -f1)))
_PV2ESSPLUSGRID_=$(($(awk -F ";" '{print $33}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $33}' plothead.csv | cut -d "." -f1)))
_PV2GRID_=$((${_PV2ESSPLUSGRID_}-${_PV2ESS_}))
_PV2HH_=$((${_PV_}-${_PV2ESSPLUSGRID_}))
_GRID2HH_=$((${_GRIDPLUSESS2HH_}-${_ESS2HH_}))

echo "HH counter level charge in Wh/Zähler Hausverbrauch                  ${_HH_} Wh"
echo "PBH counter level in Wh/Batterie --> Haus                           ${_ESS2HH_} Wh"
echo "PV counter level charge in Wh/PV Produktion                         ${_PV_} Wh"
echo "PPB counter level in Wh/PV --> Batterie                             ${_PV2ESS_} Wh"
echo "PV+HH counter level discharge in Wh/Modbus Netz + Batterie --> Haus ${_GRIDPLUSESS2HH_} Wh"
echo "PV+HH counter level charge in Wh/Modbus PV --> Batterie + Netz      ${_PV2ESSPLUSGRID_} Wh" 

echo "errechnet PV --> Netz                                               ${_PV2GRID_} Wh"
echo "errechnet PV --> Haus                                               ${_PV2HH_} Wh"
echo "errechnet Netz --> Haus                                             ${_GRID2HH_} Wh"


echo " "
echo -e "\033[0;31m Aktuell anstehende Alarme.\033[0m"
cat /tmp/alarm_messages

#Loeschen Ergebniss
#read -p "weiter mit Enter Ergenisse werden geloescht"
 rm -rf /tmp/invoicetmp/
echo "ENDE"
