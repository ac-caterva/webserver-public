#!/bin/bash
# Testscript fur Optimierung Schaltschwellen
# kein Eingriff ins System shutdown etc
# große Testintervalle kleine Last?
# v6 maxpv 100 enn der SOC bei 90 ist es zwischen 13:00 und 13:59 uhr ist und die Module 4 Prozent auseinder sind mit pvstrom laden auf 100 %
# v7 Prozesse agetty killen, Alarme alle 10 Minuten, batterie alle 10 Minuten, bmm restart  
# v8 auch maxpv100 wenn Modul auf 9 springt
# v9 Ausgaben in log erweitert und korrket timestamp logfile
# v10 Beschreibung erweitert, Reset BMM, Ladefunktion per Variabel schaltbar
# v11 log in /var/log https://github.com/ac-caterva/Spielwiese/issues/3
# v12 Problem in 4 Prozent Unterschied https://github.com/ac-caterva/webserver/issues/38
# v13 nicht klar wann _SOCDCSPRUNG_ gesetzt wurde (eventuell Neustart batterylog.csv) zusaetzlicher Logeintrag mit timestamp
# v14 Konfigfile /home/admin/bin/CS_Steuerung.txt integriert
# v15 Anpassung func_maxPV_unterschied wenn Module mehr als 15 Prozent auseinader kein autoladen, Ladeleistung wir zu stark runtergeregelt von caterva
# v16 Werte aus Konfigfile auf Sinnhaftigkeit pruefen
# v17 Link auf Logfile und le und ge auf lt un gt geaendert Werte angepasst
# v18 alle exit duch func_exit ersetzte, func_Stopfile_exist fuer Starter oder FHEM hinzugefuegt
# v19 Vergleichsoperator in func_Daten_holen von "e" auf "eq" korrigiert
# v20 2 func_maxPV Bedingung von 89 auf ${_SOCHYSTERESE_} gestellt, CS_Steuerung.cfg (persoenliche Konfig) und txt (default Konfig) gesplittet 
# v21 Fehler Konfig wird alle 10 Minuten eingelesen, fasches File angegeben
# v22 Datum bei Logfiles wieder rausgenommen, fuer Logrotaed webserver issues 33

_LOGFILE_=/var/log/CS_Steuerung.log
# Logfilelink loeschen falls vorhaden und neu anlegen
if [ -L /home/admin/bin/CS_Steuerung.log ] ; then
	rm -f /home/admin/bin/CS_Steuerung.log
fi	
ln -s /var/log/CS_Steuerung.log /home/admin/bin/CS_Steuerung.log
_CS_STRG_INVOICELOG=/tmp/CS_Strg_invoiceLog.csv
_CS_STRG_BATTERYLOG=/tmp/CS_Strg_batteryLog.csv

echo "Mit dem Befehl cat CS_Steuerung_Hilfe.txt lesen" | tee -a ${_LOGFILE_}
echo "ES wird der Duchschnitt der letzten 60 Sekundne gebildet, dieser Wert wird dann mit den in Variablen gesetzten Werten verglichen." | tee -a ${_LOGFILE_}
echo "Variable ab wann eingespeichert wird _SCHWELLEOBEN_" | tee -a ${_LOGFILE_}
echo "Variable ab wann ausgespeichert wird _SCHWELLEUNTEN_" | tee -a ${_LOGFILE_}
echo "Bei jedem Start wird ein Logfile unter /var/log/CS_Steuerung_YYYY-mm-dd_HH-MM.txt angelegt mit Start Datum/Uhrzeit." | tee -a ${_LOGFILE_}
echo "Wenn BO laeuft wird abgebrochen um Wechselwirkunken zu vermeiden." | tee -a ${_LOGFILE_}
echo "SOC Hysterese nach oben wenn einmal 90 erreicht wirde erst unter 87 wieder eingespeichert." | tee -a ${_LOGFILE_}
echo "Bei Sony-Anlagen wird wenn der SOC bei 90 ist es zwischen 13:00 und 13:59 uhr ist und die Module 4 Prozent auseinder sind mit pvstrom laden auf 100 %," | tee -a ${_LOGFILE_} 
echo "oder wenn Module auf 10 % springen. Diese automatische laden muss mit der Variable _AUTOLADEN_=ja im Script gesetzt werden!" | tee -a ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

########################################
# Konfigwerte ueber File auslesen beim Starten des Scripts und alle 10 Minuten falls es geaendert wird 
# Pruefen ob Files /home/admin/bin/CS_Steuerung.cfg existiert, wenn ja die Werte verwenden ansonsten Defaultwerte verwenden.
function func_Konfig_einlesen() 
{
if [ -f /home/admin/bin/CS_Steuerung.cfg ] ; then
	if [ ! "$(head -n 1 /home/admin/bin/CS_Steuerung.cfg)" == "${_KONFIG_}" ] ; then
		_SOCMAX_=$(head -n 1 /home/admin/bin/CS_Steuerung.cfg | cut -d ";" -f1)
		printf -v _SOCMAX_ %.0f $_SOCMAX_
		if ( [ $_SOCMAX_ -lt 50 ] || [ $_SOCMAX_ -gt 90 ] )
		then
			echo "Wert bis zu welchem Speicherstand geladen werden soll nicht aktzeptiert muss zwischen 50-90 liegen ist ${_SOCMAX_}!" | tee -a ${_LOGFILE_}
			echo "Default Konfig verwendet CS_Steuerung.txt" | tee -a ${_LOGFILE_}
			func_Konfig_einlesen_default
			return
 		fi
 		_SOCHYSTERESE_=$(head -n 1 /home/admin/bin/CS_Steuerung.cfg | cut -d ";" -f2)
		printf -v _SOCHYSTERESE_ %.0f $_SOCHYSTERESE_
		if ( [ $_SOCHYSTERESE_ -lt 20 ] || [ $_SOCHYSTERESE_ -ge $_SOCMAX_ ] )
		then
			echo "Ladehysteresewert muss groeßer 20 sein und unter Speicherladestand. Wert ist ${_SOCHYSTERESE_}!"  | tee -a ${_LOGFILE_}
			echo "Default Konfig verwendet CS_Steuerung.txt" | tee -a ${_LOGFILE_}
			func_Konfig_einlesen_default
			return
		fi
		_SCHWELLEOBEN_=$(head -n 1 /home/admin/bin/CS_Steuerung.cfg | cut -d ";" -f3)
		printf -v _SCHWELLEOBEN_ %.0f $_SCHWELLEOBEN_
		if ( [ $_SCHWELLEOBEN_ -lt 500 ] || [ $_SCHWELLEOBEN_ -gt 6000 ] )
		then
			echo "Schwelle ab wann eingespeichert wird muss zwischen 500 und 6000 Watt liegen ist ${_SCHWELLEOBEN_}! "  | tee -a ${_LOGFILE_}
			echo "Default Konfig verwendet CS_Steuerung.txt" | tee -a ${_LOGFILE_}
			func_Konfig_einlesen_default
			return
		fi
		_SCHWELLEUNTEN_=$(head -n 1 /home/admin/bin/CS_Steuerung.cfg | cut -d ";" -f4)
		printf -v _SCHWELLEUNTEN_ %.0f $_SCHWELLEUNTEN_
		if ( [ $_SCHWELLEUNTEN_ -lt -6000 ] || [ $_SCHWELLEUNTEN_ -gt -500 ] )
		then
			echo "Schwelle ab wann ausgespeichert wird muss zwischen -500 und -6000 Watt liegen ist ${_SCHWELLEUNTEN_}! " | tee -a ${_LOGFILE_}  
			echo "Default Konfig verwendet CS_Steuerung.txt" | tee -a ${_LOGFILE_}
			func_Konfig_einlesen_default
			return
		fi
		_AUTOLADEN_=$(head -n 1 /home/admin/bin/CS_Steuerung.cfg | cut -d ";" -f5)
		case $_AUTOLADEN_ in
			ja) 
		;;
			nein) 
		;;
			*) 
			echo " Autoladen darf nur ja oder nein sein, ist ${_AUTOLADEN_}! " | tee -a ${_LOGFILE_}
			echo "Default Konfig verwendet CS_Steuerung.txt" | tee -a ${_LOGFILE_}
			func_Konfig_einlesen_default
			return
		 ;;
		esac
		echo "Parameter aus Konfigfile gelesen:" | tee -a ${_LOGFILE_}
		echo "SOC Maximalwert eingestellt ${_SOCMAX_}" | tee -a ${_LOGFILE_}
		echo "SOC Hysterese eingestellt ${_SOCHYSTERESE_}" | tee -a ${_LOGFILE_}
		echo "Leistungsgrenze einspeichern ${_SCHWELLEOBEN_}" | tee -a ${_LOGFILE_}
		echo "Leistungsgrenze ausspeichern ${_SCHWELLEUNTEN_}" | tee -a ${_LOGFILE_}
		echo "Automatischen laden aktiviert: ${_AUTOLADEN_}" | tee -a ${_LOGFILE_}
		_KONFIG_=$(head -n 1 /home/admin/bin/CS_Steuerung.cfg)
	fi
else
	echo "Kein Konfigile /home/admin/bin/CS_Steuerung.txt vohanden Defaultwerte verwenden." | tee -a ${_LOGFILE_}
	func_Konfig_einlesen_default
fi
}


########################################
# Konfigwerte default setzten da CS_Steuerung.cfg nicht vorhanden oder falsch Werte gesetzt 
function func_Konfig_einlesen_default() 
{
if [ -f /home/admin/bin/CS_Steuerung.txt ] ; then
	if [ ! "$(head -n 1 /home/admin/bin/CS_Steuerung.txt)" == "${_KONFIG_}" ] ; then
		_SOCMAX_=$(head -n 1 /home/admin/bin/CS_Steuerung.txt | cut -d ";" -f1)
		printf -v _SOCMAX_ %.0f $_SOCMAX_
		if ( [ $_SOCMAX_ -lt 50 ] || [ $_SOCMAX_ -gt 90 ] )
		then
			echo "Wert bis zu welchem Speicherstand geladen werden soll nicht aktzeptiert muss zwischen 50-90 liegen ist ${_SOCMAX_}! Abbruch"
			func_exit
		fi
 		_SOCHYSTERESE_=$(head -n 1 /home/admin/bin/CS_Steuerung.txt | cut -d ";" -f2)
		printf -v _SOCHYSTERESE_ %.0f $_SOCHYSTERESE_
		if ( [ $_SOCHYSTERESE_ -lt 20 ] || [ $_SOCHYSTERESE_ -ge $_SOCMAX_ ] )
		then
			echo "Ladehysteresewert muss groeßer 20 sein und unter Speicherladestand. Wert ist ${_SOCHYSTERESE_}! Abbruch"
			func_exit
		fi
		_SCHWELLEOBEN_=$(head -n 1 /home/admin/bin/CS_Steuerung.txt | cut -d ";" -f3)
		printf -v _SCHWELLEOBEN_ %.0f $_SCHWELLEOBEN_
		if ( [ $_SCHWELLEOBEN_ -lt 500 ] || [ $_SCHWELLEOBEN_ -gt 6000 ] )
		then
			echo "Schwelle ab wann eingespeichert wird muss zwischen 500 und 6000 Watt liegen ist ${_SCHWELLEOBEN_}! Abbruch"
			func_exit
		fi
		_SCHWELLEUNTEN_=$(head -n 1 /home/admin/bin/CS_Steuerung.txt | cut -d ";" -f4)
		printf -v _SCHWELLEUNTEN_ %.0f $_SCHWELLEUNTEN_
		if ( [ $_SCHWELLEUNTEN_ -lt -6000 ] || [ $_SCHWELLEUNTEN_ -gt -500 ] )
		then
			echo "Schwelle ab wann ausgespeichert wird muss zwischen -500 und -6000 Watt liegen ist ${_SCHWELLEUNTEN_}! Abbruch"
			func_exit
		fi
		_AUTOLADEN_=$(head -n 1 /home/admin/bin/CS_Steuerung.txt | cut -d ";" -f5)
		case $_AUTOLADEN_ in
			ja) 
		;;
			nein) 
		;;
			*) 
			echo " Autoladen darf nur ja oder nein sein, ist ${_AUTOLADEN_}! Abbruch"
			func_exit
		 ;;
		esac
		echo "Parameter aus Konfigfile gelesen:" | tee -a ${_LOGFILE_}
		echo "SOC Maximalwert eingestellt ${_SOCMAX_}" | tee -a ${_LOGFILE_}
		echo "SOC Hysterese eingestellt ${_SOCHYSTERESE_}" | tee -a ${_LOGFILE_}
		echo "Leistungsgrenze einspeichern ${_SCHWELLEOBEN_}" | tee -a ${_LOGFILE_}
		echo "Leistungsgrenze ausspeichern ${_SCHWELLEUNTEN_}" | tee -a ${_LOGFILE_}
		echo "Automatischen laden aktiviert: ${_AUTOLADEN_}" | tee -a ${_LOGFILE_}
		_KONFIG_=$(head -n 1 /home/admin/bin/CS_Steuerung.txt)
	fi
else
	echo "Kein Konfigile /home/admin/bin/CS_Steuerung.txt vohanden Defaultwerte verwenden." | tee -a ${_LOGFILE_}
	_SOCMAX_=90
	_SOCHYSTERESE_=87
	_SCHWELLEOBEN_=3000
	_SCHWELLEUNTEN_=-1500
	_AUTOLADEN_=nein
	printf -v _SOCMAX_ %.0f $_SOCMAX_
	echo "SOC Maximalwert eingestellt ${_SOCMAX_}" | tee -a ${_LOGFILE_}
	printf -v _SOCHYSTERESE_ %.0f $_SOCHYSTERESE_
	echo "SOC Hysterese eingestellt ${_SOCHYSTERESE_}" | tee -a ${_LOGFILE_}
	printf -v _SCHWELLEOBEN_ %.0f $_SCHWELLEOBEN_
	echo "Leistungsgrenze einspeichern ${_SCHWELLEOBEN_}" | tee -a ${_LOGFILE_}
	printf -v _SCHWELLEUNTEN_ %.0f $_SCHWELLEUNTEN_
	echo "Leistungsgrenze ausspeichern ${_SCHWELLEUNTEN_}" | tee -a ${_LOGFILE_}
	echo "Automatischen laden aktiviert: ${_AUTOLADEN_}" | tee -a ${_LOGFILE_}
fi
}


#########################################
# Steuerung des Business Controllers: 
# Wenn die Datei /home/admin/registry/noPVBuffering vorhanden ist, dann 
# wird der Inverter nicht gestartet. Die Caterva speichert weder ein noch aus.
function func_touch_noPVBuffering()
{
	if [ ! -f /home/admin/registry/noPVBuffering ] ; then
    	echo "touch /home/admin/registry/noPVBuffering" | tee -a ${_LOGFILE_}
    	touch /home/admin/registry/noPVBuffering
	fi	
}
function func_rm_noPVBuffering()
{
	if [ -f /home/admin/registry/noPVBuffering ] ; then
    	echo "rm /home/admin/registry/noPVBuffering" | tee -a ${_LOGFILE_}
    	rm -f /home/admin/registry/noPVBuffering
	fi	
}

#########################################
# Steuerung des Business Controllers: 
# Der Inhalt der Datei /home/admin/registry/polMaxPV bestimmt bis zu 
# welchem SoC die Batterie Module geladen werden:
# Default der Caterva, wenn die Datei nicht existiert: 0.90 => 90%
function func_set_polMaxPV_90Pct()
{
    echo "0.90" > /home/admin/registry/polMaxPV
    echo "0.90 > /home/admin/registry/polMaxPV" | tee -a ${_LOGFILE_}  
}
function func_set_polMaxPV_100Pct()
{
    echo "1.00" > /home/admin/registry/polMaxPV	
    echo "1.00 > /home/admin/registry/polMaxPV" | tee -a ${_LOGFILE_}  
}

#########################################
# Alles was beim Beenden dieses Scriptes gemacht werden soll
function func_exit ()
{
    DATE=`date +"%a %F %T" `
    echo "Beende CS_Steuerung.sh: $DATE" | tee -a ${_LOGFILE_}

    func_cleanup_files
    exit 0
}

##############################################
# Dateien in Originalzustand bringen
# Schreibe /home/admin/registry/polMaxPV, loesche /home/admin/registry/noPVBuffering
function func_cleanup_files()
{
    func_set_polMaxPV_90Pct
    func_rm_noPVBuffering
}

#########################################
# Anzeigen des Status der SONY Module mittels netcat zum swarm-battery-cmd
function func_display_sony_modules()
{
	(echo "mod";sleep 0.3;echo "exit";) | netcat localhost 1338 | sed -n '18p;25,39p;' | tee -a ${_LOGFILE_}	
}
#########################################
# Auslesen des SoC fuer alle SONY Module mittels netcat zum swarm-battery-cmd
function func_read_SoC_sony_modules()
{
	(echo "mod";sleep 0.3;echo "exit";) | netcat localhost 1338 | grep soc | awk -F " " '{print $4 " " $5 " " $6 " " $7 " " $8 " " $9 " " $10 " " $11 " " $12 " " $13}'	
}	

#########################################
# Daten fuer Steuerung aus /var/log/invoiceLog.csv und /var/log/batteryLog.csv 
# - _DURCHSHH_    : Durchschnittl. Verbrauch im Haushalt in Watt
# - _DURCHSPV_    : Durchschnittl. Leistung PV in Watt
# - _DURCHSPVHH_  : `Durchschnittl. Leistung PV` minus `Durchschnittl. Verbrauch im Haushalt`
# - _AKTTIME_     : Aktuelle Zeit
# - _PV_          : Aktuelle PV Leistung in Watt
# - _ENTLADENINV_ : Aktuelle Entladeleistung des Inverters(AC) in Watt
# - _LADENINV_    : Aktuelle Ladeleistung des Inverters(AC) in Watt
# - _INVSTATUS_   : Aktueller Status des Inverters 
# - _SOCDC_       : Aktueller SoC(DC) der Batteriemodule
# - _SOCDCSPRUNG_ : SoC(DC) kleiner oder gleich 10% ? yes/no
function func_Daten_holen ()
{
	tail -60 /var/log/invoiceLog.csv | grep -v a > $_CS_STRG_INVOICELOG
	tail -2 /var/log/batteryLog.csv | grep -v '^#' | tail -1 > $_CS_STRG_BATTERYLOG

	_DURCHSHH_=$(awk -F ";" 'BEGIN { lines=0; total=0 } { lines++; total+=$15 } END { print total/lines }' "$_CS_STRG_INVOICELOG" )
	printf -v _DURCHSHH_ %.0f $_DURCHSHH_
	_DURCHSPV_=$(awk -F ";" 'BEGIN { lines=0; total=0 } { lines++; total+=$14 } END { print total/lines }' "$_CS_STRG_INVOICELOG" )
	printf -v _DURCHSPV_ %.0f $_DURCHSPV_

	let "_DURCHSPVHH_=_DURCHSPV_-_DURCHSHH_"
	printf -v _DURCHSPVHH_ %.0f $_DURCHSPVHH_

	_AKTTIME_=$(tail -1 "$_CS_STRG_INVOICELOG" | awk -F ";" '{print $2}')
	_PV_=$(tail -1 "$_CS_STRG_INVOICELOG" | awk -F ";" '{print $14}')
	_ENTLADENINV_=$(tail -1 "$_CS_STRG_INVOICELOG" | awk -F ";" '{print $17}')
	_LADENINV_=$(tail -1 "$_CS_STRG_INVOICELOG" | awk -F ";" '{print $18}')

	_INVSTATUS_=$(cut -d ";" -f 25 $_CS_STRG_BATTERYLOG) 
	_SOCDC_=$(cut -d ";" -f6 $_CS_STRG_BATTERYLOG)
	printf -v _SOCDC_ %.0f $_SOCDC_

	if ([ ${_SOCDC_} -le 10 ] && [ ! ${_SOCDC_} -eq 0 ]) ; then
	        echo "${_AKTTIME_} _SOCDCSPRUNG_ wird gesetzt _SOCDC_ = ${_SOCDC_}" | tee -a ${_LOGFILE_} 
		_SOCDCSPRUNG_=yes
	fi
}

function func_setzten_einausspeichern ()
{
	if [ ${_DURCHSPVHH_} -gt ${_SCHWELLEOBEN_} -o  ${_DURCHSPVHH_} -lt ${_SCHWELLEUNTEN_} ] ; then
		echo "Normal Betrieb" | tee -a ${_LOGFILE_} 
		func_rm_noPVBuffering
	else
		echo "ein/ausspeichern blockiert" | tee -a ${_LOGFILE_}
		func_touch_noPVBuffering
	fi
} 

function func_log_aktuell ()
{
	if [ "${_AKTTIME_}" == "${_OLDAKTTIME_}" ] ; then
		_STOP_="stop Invoicelog laeuft nicht!"
		echo "Logfile steht" | tee -a ${_LOGFILE_}
	fi
	_OLDAKTTIME_=$_AKTTIME_
}


function func_Hysterese_Einspeichern ()
{
	if [ ${_DURCHSPVHH_} -gt ${_SCHWELLEOBEN_} ] ; then
		if [ ${_SOCDC_} -ge ${_SOCMAX_} ] ; then
			_SOCSTAT_=voll
			_STOP_="stop Einspeicher Hysterese"
		else 
			if [[ ${_SOCSTAT_} == "voll" ]] ; then 
				if [ ${_SOCDC_} -gt ${_SOCHYSTERESE_} ] ; then 		
					_STOP_="stop Einspeicher Hysterese"
				else
					_SOCSTAT_=normal
				fi
			fi	
		fi	
	fi
}


function func_maxPV_unterschied ()
{
	if [ "$(echo ${_AKTTIME_} | cut -d " " -f2 | cut -d : -f1)" == "13" -a "${_BMMTYPE_}" == "sony" -a ${_SOCDC_} -ge ${_SOCHYSTERESE_} ] ; then 
		_SOCMODULEALL_=$(func_read_SoC_sony_modules)	
		_SOCMODULEMAX_=890
		for i in ${_SOCMODULEALL_}
		do 
			if [ ${i} -ge ${_SOCMODULEMAX_} ] ; then 
				_SOCMODULEMAX_=$i
				printf -v _SOCMODULEMAX_ %.0f $_SOCMODULEMAX_			
			fi 
		done
		_SOCMODULEMIN_=1000
                for x in ${_SOCMODULEALL_}
                do
                        if [ ${x} -le ${_SOCMODULEMIN_} ] ; then
                                _SOCMODULEMIN_=$x
                                printf -v _SOCMODULEMIN_ %.0f $_SOCMODULEMIN_
                        fi
                done
		if [ $((${_SOCMODULEMAX_}-${_SOCMODULEMIN_})) -gt 40 ] ; then			
			if [ $((${_SOCMODULEMAX_}-${_SOCMODULEMIN_})) -lt 160 ] ; then
				echo "Aufladen auf 100 Prozent gestartet da Module mehr wie 4 Prozent Differenz haben Dauer 2 Std laden 1 Std Ruhe" | tee -a ${_LOGFILE_} 
				func_laden
			else
				echo "Module mehr wie 4 Prozent Differenz, aber laden nicht angestossen da Module mehr als 15 Prozent auseinander!!!" | tee -a ${_LOGFILE_}
			fi
		fi
	fi	
}

function func_maxPV_sprung ()
{
	if [ "$(echo ${_AKTTIME_} | cut -d " " -f2 | cut -d : -f1)" == "13" -a "${_BMMTYPE_}" == "sony" -a "${_SOCDCSPRUNG_}" == "yes" -a ${_SOCDC_} -ge ${_SOCHYSTERESE_} ] ; then 	
		echo "Aufladen auf 100 Prozent gestartet da Module auf 10 Prozent oder darunter waren." | tee -a ${_LOGFILE_}	 
		func_laden
		_SOCDCSPRUNG_=no	
	fi	
}

function func_laden ()
{
	func_rm_noPVBuffering
	func_set_polMaxPV_100Pct
	_ZAEHLER_=1
	while [ ${_ZAEHLER_} -le 120 ]
	do
		func_Daten_holen
		echo "${_AKTTIME_} Aktuell: PV vorhanden ${_PV_} Status Inv ${_INVSTATUS_}  SOCDC ${_SOCDC_} Laden WR ${_LADENINV_} ENTLADEN WR ${_ENTLADENINV_}" | tee -a ${_LOGFILE_}
		func_display_sony_modules
		sleep 60s
		echo "PV-Ladung auf 100 Prozent laeuft seit ${_ZAEHLER_} Minuten von max 120" | tee -a ${_LOGFILE_}
		((_ZAEHLER_++))
		if [ ${_SOCDC_} -ge 100 ] ; then
			echo "SoC von 100% erreicht" | tee -a ${_LOGFILE_}
			func_set_polMaxPV_90Pct
		fi
	done
	echo "2 Stunden Laden beendet. Erreichter SoC-DC: ${_SOCDC_} " | tee -a ${_LOGFILE_}
	func_set_polMaxPV_90Pct
	func_display_sony_modules
	echo "1 Stunde Akkus ruhen lassen" | tee -a ${_LOGFILE_}
	sleep 3600	
	func_display_sony_modules
	echo "Restart bmm, dann 5 Minute Pause, SoC vergleichen gibt es eine Veränderung! " | tee -a ${_LOGFILE_}
	source /home/admin/bin/modules/bc/resetBMM
	swarmBcResetBmm 2 &> /dev/null   <<< j

	sleep 30
	func_display_sony_modules
	sleep 30
	func_display_sony_modules
	sleep 30
	func_display_sony_modules
	sleep 30
	func_display_sony_modules
	sleep 30
	func_display_sony_modules
	sleep 30
	func_display_sony_modules
	sleep 30
	func_display_sony_modules
	sleep 30
	func_display_sony_modules
	sleep 30
	func_display_sony_modules
	sleep 30
	func_display_sony_modules
	echo "Wieder Normalbetrieb" | tee -a ${_LOGFILE_}
}

function func_10Minuten_Abfragen ()
{
	if [ "$(echo ${_AKTTIME_} | cut -d " " -f2 | cut -d : -f2 | cut -c2)" == "0" -a "${_BMMTYPE_}" == "sony" ] ; then
		echo "Ausgabe Batteriemodule alle 10 Minuten!"
		func_display_sony_modules
		echo "Ausgabe Alarmemodule alle 10 Minuten!"
		cat /tmp/alarm_messages | tee -a ${_LOGFILE_}
		func_Konfig_einlesen
	fi	
}

#########################################
# Pruefen ob Stopfile existiert fuer CS_SteuerungStarter
function func_Stopfile_exist ()
{
	if ( [ -f /tmp/CS_SteuerungStop ] ) ; then
		echo "CS_Steuerung.sh ist wegen Stopfile /tmp/CS_SteuerungStop File beendet worden!" | tee -a ${_LOGFILE_}
		func_exit
	fi
}


#########################################
#MAIN
#########################################

trap 'func_exit' 1 2 15

# Einmalige Aktionen beim Start
# Killen agetty 
sudo pkill -SIGTERM agetty
# Abbrechen wenn BO laeuft unbekannte Wechselwirkungen
if [ ! $(ps aux | grep -c "[B]usinessOptimum.sh") = 0 ] ; then
	echo "BusinessOptimum.sh laeuft auf dieser Anlage, das ist nicht erprobt es wird abgebrochen!!!" | tee -a ${_LOGFILE_}
	func_exit
fi
# Konfig einlesen aus File oder default
func_Konfig_einlesen
_SOCDCSPRUNG_=no
_BMMTYPE_=$(cat /home/admin/registry/out/bmmType)

func_cleanup_files

while true
do
	func_Stopfile_exist
	func_Daten_holen
	func_log_aktuell
	echo "${_AKTTIME_} Durchschnitt: hh ${_DURCHSHH_} PV ${_DURCHSPV_} PVHH ${_DURCHSPVHH_} Aktuell: Status Inv ${_INVSTATUS_}  SOCDC ${_SOCDC_} Laden WR ${_LADENINV_} ENTLADEN WR ${_ENTLADENINV_}" | tee -a ${_LOGFILE_} 
	func_Hysterese_Einspeichern
	if [[ "${_STOP_}" == "stop"* ]] ; then 
		echo ${_STOP_} | tee -a ${_LOGFILE_}
		func_touch_noPVBuffering
	else
		func_setzten_einausspeichern
	fi
	if [[ "${_AUTOLADEN_}" == "ja" ]] ; then
		func_maxPV_unterschied
		func_maxPV_sprung
	fi
	_STOP_="leer"
	func_10Minuten_Abfragen
	sleep 58.6
done

