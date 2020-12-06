#!/bin/bash
# Script für Linux-pc unter $HOME/bin/ kopieren und ausführbar machen chmod 700 PFAD/SCRIPTDATEI
#v1 Neuerstellung aus uli_invoice_monat_v6.sh
#v2 Zaehler ergänzt / wenn keine gen2 Anlage ESS Charge/Discarge vertauscht, Files muessen nicht mehr entpackt werden

echo "Script zum auslesen der invoiceLog.csv Ermittlung der Zählerstände und Wirkungsgrad Berechnung."
echo "Nur ab dem gestrigen Tag moeglich, nur innerhalb eines Monats möglich!"
echo "Für nur einen Tag Startag und Stoptag identisch eingeben."

read -p "Starttag des Monats vom Plot angeben 1 bis 31 eingeben
Startag eingeben:" _STARTTAG_
if [ -z "${_STARTTAG_}" ] 
        then 
        _STARTTAG_=1 
fi

read -p "Stoptag des Monats vom Plot angeben 1 bis 31 eingeben
Stoptag eingeben:" _STOPTAG_
if [ -z "${_STOPTAG_}" ]
        then
        _STOPTAG_=31
fi

read -p "Welcher Monat soll geplottet werden 1 bis 12 eingeben
Monat eingeben:" _MONAT_
if [ -z "${_MONAT_}" ]
        then
        echo "Kein Monat eingegeben"
        exit 
fi

read -p "Welches Jahr soll geplottet werden Jahr eingeben
Jahr eingeben:" _JAHR_
if [ -z "${_JAHR_}" ]
        then
        echo "Kein Jahr eingegeben"
        exit 
fi

mkdir /tmp/invoicetmp
cd /tmp/invoicetmp
_COUNT_=${_STARTTAG_}
_STARTTAG_=${_STARTTAG_}
_STOPTAG_=${_STOPTAG_}
_MONAT_=${_MONAT_}
_JAHR_=${_JAHR_}
_MONAT_=`printf "%2.2d" ${_MONAT_}`

_STARTTAG2_=`printf "%2.2d" ${_STARTTAG_}` 
_STOPTAG2_=`printf "%2.2d" ${_STOPTAG_}`
if [ ! -f /var/log/invoiceLog.csv.${_JAHR_}-${_MONAT_}-${_STARTTAG2_}.gz ]
        then
        echo "Starttag nicht vorhanden!! ${_JAHR_}-${_MONAT_}-${_STARTTAG2_}"
        rm -rf /tmp/invoicetmp/
        exit
fi

if [ ! -f /var/log/invoiceLog.csv.${_JAHR_}-${_MONAT_}-${_STOPTAG2_}.gz ]
        then
        echo "Stoptag nicht vorhanden!! ${_JAHR_}-${_MONAT_}-${_STOPTAG2_}"
        rm -rf /tmp/invoicetmp/
        exit
fi
_PLOTHEAD_=$(zcat /var/log/invoiceLog.csv.${_JAHR_}-${_MONAT_}-${_STARTTAG2_}.gz | head -1)
_PLOTTAIL_=$(zcat /var/log/invoiceLog.csv.${_JAHR_}-${_MONAT_}-${_STOPTAG2_}.gz | tail -1)
echo ${_PLOTHEAD_} >> plothead.csv
echo ${_PLOTTAIL_} >> plottail.csv

_SoC_=$(awk -F ";" '{print $16}' plottail.csv)

while (( ${_COUNT_} <= ${_STOPTAG_} ))
do
        _COUNT2_=`printf "%2.2d" ${_COUNT_}`
        _PLOTWIRK_=$(zgrep -m 1 ";${_SoC_};" /var/log/invoiceLog.csv.${_JAHR_}-${_MONAT_}-${_COUNT2_}.gz)
        echo ${_PLOTWIRK_} > plotwirk.csv
        if [[ -z "$(find /tmp/invoicetmp/ -size 1 -iname "plotwirk.csv")" ]]
                then
                _COUNT_=${_STOPTAG_}
        fi
        ((_COUNT_++))
done

#Pruefen ob eine gen2 Anlage (Bei aelteren Anlagen ist charge / discharge der ESS vertauscht)
if [ -f /home/admin/registry/out/gen2 ]
        then
        _discargeESSwatt_=$(awk -F ";" '{print $17}' plottail.csv)
        _chargeESSwatt_=$(awk -F ";" '{print $18}' plottail.csv)
        _dischargeESScount_=$(($(awk -F ";" '{print $21}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $21}' plothead.csv | cut -d "." -f1)))
        _chargeESScount_=$(($(awk -F ";" '{print $22}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $22}' plothead.csv | cut -d "." -f1)))
        _dischargeESScountwirk_=$(($(awk -F ";" '{print $21}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $21}' plotwirk.csv | cut -d "." -f1)))
        _chargeESScountwirk_=$(($(awk -F ";" '{print $22}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $22}' plotwirk.csv | cut -d "." -f1)))
		_time_=$(($(awk -F ";" '{print $1}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $1}' plotwirk.csv | cut -d "." -f1)))
        else
        _discargeESSwatt_=$(awk -F ";" '{print $18}' plottail.csv)
        _chargeESSwatt_=$(awk -F ";" '{print $17}' plottail.csv)
        _dischargeESScount_=$(($(awk -F ";" '{print $22}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $22}' plothead.csv | cut -d "." -f1)))
        _chargeESScount_=$(($(awk -F ";" '{print $21}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $21}' plothead.csv | cut -d "." -f1)))
        _dischargeESScountwirk_=$(($(awk -F ";" '{print $22}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $22}' plotwirk.csv | cut -d "." -f1)))
        _chargeESScountwirk_=$(($(awk -F ";" '{print $21}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $21}' plotwirk.csv | cut -d "." -f1)))
		_time_=$(($(awk -F ";" '{print $1}' plottail.csv | cut -d "." -f1)-$(awk -F ";" '{print $1}' plotwirk.csv | cut -d "." -f1)))
fi

echo "---------------------------------------------------------------------------------------------------------------"
echo "Wirkungsgrad Einspeisung/Ausspeisung nur bezogen auf die ESS internen Zähler als Anhaltspunkt, für echten WG müssen die physikalischen Zähler verwendet werden!!!"
echo "Startzeit fuer Wirkungsgrad $(awk -F ";" '{print $2}' plotwirk.csv)   Ladezustand Speicher      $(awk -F ";" '{print $16}' plotwirk.csv) %"
echo "Endzeit                     $(awk -F ";" '{print $2}' plottail.csv)   Ladezustand Speicher      $(awk -F ";" '{print $16}' plottail.csv) %"
echo "---------------------------------------------------------------------------------------------------------------"
#echo "Deshalb wird im angegeben Zeitraum der erste Wert mit dem selben SoC gesucht!            $((${_dischargeESScountwirk_}/$((${_chargeESScountwirk_}/100)))) %"
echo "Wirkungsgrad 'angegebener Zeitraum erster Wert mit dem selben SoC'                       $((${_dischargeESScountwirk_}/$((${_chargeESScountwirk_}/100)))) %"
echo "Wirkungsgrad mit Grundlast von 1550Wh/Tag '(65Wh/Stunde)'                                $((${_dischargeESScountwirk_}/$(((${_chargeESScountwirk_}+((${_time_}/1000*65/60/60)))/100)))) %"
echo " "
echo "Zeitdauer                                                                                $((${_time_}/1000/60/60)) h"
echo "Grundlast                                                                                $((${_time_}/1000*65/60/60)) Wh"
echo "ESS counter level discharge in Wh / Zähler Entladen Batterie                             ${_dischargeESScountwirk_} Wh"
echo "ESS counter level charge in Wh / Zähler Laden Batterie                                   ${_chargeESScountwirk_} Wh"
echo " "
echo "ESS Laden und Grundlast                                                                  $(((${_chargeESScountwirk_})+(${_time_}/1000*65/60/60))) Wh"
echo "---------------------------------------------------------------------------------------------------------------"
echo " "
echo "Startzeit Zählerstände      $(awk -F ";" '{print $2}' plothead.csv)   Ladezustand Speicher      $(awk -F ";" '{print $16}' plothead.csv) %"
echo "Endzeit                     $(awk -F ";" '{print $2}' plottail.csv)   Ladezustand Speicher      $(awk -F ";" '{print $16}' plottail.csv) %"
echo "ESS counter level discharge in Wh / Zähler Entladen Batterie        ${_dischargeESScount_} Wh"
echo "ESS counter level charge in Wh / Zähler Laden Batterie              ${_chargeESScount_} Wh" 
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


        rm -rf /tmp/invoicetmp/
echo "ENDE"
