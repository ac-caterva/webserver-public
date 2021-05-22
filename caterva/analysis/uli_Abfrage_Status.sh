#!/bin/bash 
#v1 Neuerstellung Script muss unter /home/admin/bin/ der Silverbox kopiert und dann ausgeführt werden 
#v2 Variablen mit Klammern, 'top' hinzugefuegt Prozessliste Auslastung
#v3 Log Datei wird auf die Pi kopiert
#   Ausgabe mit Markdown - Header 2 und Monospaced Text
#   Variable _LOGFILE_
#   sleep0.3 => sleep 0.3
#v4 Erweiterung automatischer Zaehlerkonfigurations (incl. emulierte) webserver Issues 19

echo -e "\033[1;36m Script zum Abfragen des Systemzustandes eines Caterva Speichersystems!\033[0m"

_DATUM_=$(date +"%Y-%m-%d_%H-%M")
_LOGDIR_=/var/log
_LOGFILENAME_=Abfrage_${_DATUM_}.md
_LOGFILE_=${_LOGDIR_}/${_LOGFILENAME_}

echo -e "\033[1;36m Output wird in einer Textdatei abgespeichert unter ${_LOGFILE_}.\033[0m"
touch ${_LOGFILE_}

echo " " | tee -a ${_LOGFILE_}
echo -e "## Abfrage Datum" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
date | tee -a ${_LOGFILE_} 
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Abfrage SD-Karten Speicherplatz" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
df -h | tee -a ${_LOGFILE_}
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Abfrage Prozesse und Last" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
top -b -n 1 | tee -a ${_LOGFILE_}
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Abfrage aktuell anstehender Alarme" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
swarmBcGetAlarms <<< j 2>&1 | tee -a ${_LOGFILE_}
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Abfrage konfigurierte Kontroller Status und Zaehlerkonfiguration" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
swarmBcStatus <<< j 2>&1 | tee -a ${_LOGFILE_} 
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Abfrage automatische Zaehlerkonfiguration (incl. emulierte)" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
tail -n 23 /home/swarm-device/business-controller/resources/config/serial.properties <<< j 2>&1 | tee -a ${_LOGFILE_} 
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Abfrage aktueller SoC Ladezustand Speicher" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
swarmBcCheckSoC <<< j 2>&1 | tee -a ${_LOGFILE_}
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Abfrage Businesslogic File" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
cat /home/admin/registry/businessLogic | tee -a ${_LOGFILE_}
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Abfrage aktueller laufende Businesslogic" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
cat /home/swarm-device/business-controller/resources/config/control.properties | grep ^businesslogic | tee -a ${_LOGFILE_}
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Abfrage aktueller Batteriemodule nur bei Gen2Sony moeglich!" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
if ! [ -f /home/admin/registry/out/gen2 ]; then
	echo "Device is not a gen2!" | tee -a ${_LOGFILE_}
else
	(echo "mod";sleep 0.3;echo "exit";) | netcat localhost 1338 | tee -a ${_LOGFILE_}
	echo " " | tee -a ${_LOGFILE_}
fi
echo -e "\`\`\`" >> ${_LOGFILE_}

echo -e "## Abfrage aktueller Anlagenstatus!" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
(echo "SwDER/LLN0";sleep 0.3;echo "exit";) | netcat localhost 1337 | tee -a ${_LOGFILE_}
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Abfrage Gesammtspannung!" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
(echo "SwDER/ZINV1";sleep 0.3;echo "exit";) | netcat localhost 1337 | tee -a ${_LOGFILE_}
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Abfrage aktueller BMS Informationen!" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
(echo "SwDER/MBMS1";sleep 0.3;echo "exit";) | netcat localhost 1337 | tee -a ${_LOGFILE_}
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Abfrage aktueller Inverterstatus!" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
(echo "SwDER/CPOL1";sleep 0.3;echo "exit";) | netcat localhost 1337 | tee -a ${_LOGFILE_}
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Abfrage registry Verzeichnis" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
ls -l /home/admin/registry/ | tee -a ${_LOGFILE_}
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Inhalte Dateien anzeigen registfy Verzeichnis" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
find /home/admin/registry/ -maxdepth 1 -type f -print0 | xargs -0 file | grep -P text | cut -d: -f1 | while read -r f; do echo "$f"&&cat $f; done | tee -a ${_LOGFILE_}
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Abfrage registry/out Verzeichnis!" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
ls -l /home/admin/registry/out/ | tee -a ${_LOGFILE_}
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Inhalte Dateien anzeigen registry/out Verzeichnis!" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
find /home/admin/registry/out -maxdepth 1 -type f -print0 | xargs -0 file | grep -P text | cut -d: -f1 | while read -r f; do echo "$f"&&cat $f; done | tee -a ${_LOGFILE_}
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Anzeigen 200 Zeilen invoiceLog.csv!" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
tail -200 /var/log/invoiceLog.csv | tee -a ${_LOGFILE_}
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "## Anzeigen 200 Zeilen sysout.log!" | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
tail -200 /var/log/sysout.log | tee -a ${_LOGFILE_}
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo "Output wird in einer Textdatei abgespeichert unter ${_LOGFILE_}."
echo "Diese kann man mit einem Texteditor anschauen (vi, nano, etc.)"
echo " " 

echo -e "## Sichern der Daten im Verzeichnis /home/admin/registry " | tee -a ${_LOGFILE_}
echo -e "\n\`\`\`" >> ${_LOGFILE_}
(cd /home/admin ; tar cf /home/admin/registry.tar ./registry)
gzip /home/admin/registry.tar
echo -e "\`\`\`" >> ${_LOGFILE_}
echo " " | tee -a ${_LOGFILE_}

echo -e "\033[1;36m Log Datei wird auf die Pi kopiert (liegt auf der Pi unter /home/pi/${_LOGFILENAME_}!\033[0m"
sshpass -p pi scp -o StrictHostKeyChecking=no ${_LOGFILE_}    pi@192.168.0.50:
echo " " 

echo -e "\033[1;36m Backup der Registry Daten wird auf die Pi kopiert (liegt auf der Pi unter /home/pi/registry.tar.gz!\033[0m"
sshpass -p pi scp -o StrictHostKeyChecking=no /home/admin/registry.tar.gz    pi@192.168.0.50:
echo " " 

echo -e "\033[1;36m Kopiere invoiceLog Dateien (liegt auf der Pi unter /home/pi/invoiceLog.csv.YYYY-MM-DD.gz!\033[0m"
ls -tr /var/log/invoiceLog.csv.* | tail -5 | while read invoiceLogFilename
do
  echo $invoiceLogFilename
  sshpass -p pi scp -o StrictHostKeyChecking=no $invoiceLogFilename pi@192.168.0.50:
done
echo " " 

echo -e "\033[1;36m Kopiere sysout.log Dateien (liegt auf der Pi unter /home/pi/sysout.log!\033[0m"
ls -tr /var/log/sysout.log* | tail -5 | while read sysoutFilename
do
  echo $sysoutFilename
  sshpass -p pi scp -o StrictHostKeyChecking=no $sysoutFilename pi@192.168.0.50:
done

echo -e "## Reihenspannung der Sony Akkus(liegt auf der Pi unter /home/pi/bat3.log)" | tee -a ${_LOGFILE_}
echo -e "Es dauert etwas laenger bis die Daten gesammelt sind - bitte warten"
echo -e "\n\`\`\`" >> ${_LOGFILE_}
if ! [ -f /home/admin/registry/out/gen2 ]; then
	echo "Device is not a gen2!" | tee -a ${_LOGFILE_}
else
	for i in {30244..30259} {30369..30384} {30494..30509} {30619..30634} {30744..30759} {30869..30884} {30994..31009} {31119..31134} {31244..31259} {31369..31384}
  do (echo "reg ${i}"; sleep 0.3; echo "exit") | netcat localhost 1338; 
  done | grep ^3 > bat3.log
  sshpass -p pi scp -o StrictHostKeyChecking=no bat3.log pi@192.168.0.50:
	echo " " | tee -a ${_LOGFILE_}
fi
echo -e "\`\`\`" >> ${_LOGFILE_}

echo " " 
echo -e "\033[1;36m Alles erledigt\033[0m"
echo " " 
