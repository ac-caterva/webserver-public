#!/bin/bash 
# v1 Neuerstellung
# v2 /etc/ccrontab statt crontab.hourly
#    Protokollieren, wann Werte gesetzt wurden
#    log cleanup mittels CS_log-cleanup.conf

# Um das Script stuendlich laufen zu lassen 
# bitte folgenden Eintrag in die /etc/crintab machen:
#
#		# jede Stunde um xx:10 das Script ausfuehren
#		10 * * * * admin /home/admin/bin/uli_ITCI1_laedt_nicht_mehr.sh



# Script schreibt die Jahreswerte in die SwDER/ITCI1 wenn diese 0 sind.

LOG_FILE=/var/log/ITCI1.log

_ABFRAGE_=$((echo "SwDER/ITCI1.E_HH_PA.setMag.f";sleep 0.3;echo "exit";) | netcat localhost 1337 | grep SwDER/ITCI1 | awk -F" " '{print $4}')

if [ "${_ABFRAGE_}" == "0.0" ]; then
	_HH_=$(cat /home/admin/registry/out/hhPerYear)
	_PV_=$(cat /home/admin/registry/out/pvPerYear)
	_BH_=$(cat /home/admin/registry/out/bhPerYear)
	_PB_=$(cat /home/admin/registry/out/pbPerYear)

	(echo "SwDER/ITCI1.E_HH_PA.setMag.f=${_HH_}";sleep 0.3;echo "exit";) | netcat localhost 1337 
    (echo "SwDER/ITCI1.E_PV_PA.setMag.f=${_PV_}";sleep 0.3;echo "exit";) | netcat localhost 1337
    (echo "SwDER/ITCI1.E_BH_PA.setMag.f=${_BH_}";sleep 0.3;echo "exit";) | netcat localhost 1337
    (echo "SwDER/ITCI1.E_PB_PA.setMag.f=${_PB_}";sleep 0.3;echo "exit";) | netcat localhost 1337

	_DATE=`date` 
	echo -n $_DATE >> $LOG_FILE
	echo -n ": Werte wurden gesetzt fuer HH, PV, BH, PB :" >> $LOG_FILE
	echo $_HH_ $_PV_ $_BH_ $_PB_ >> $LOG_FILE

fi

