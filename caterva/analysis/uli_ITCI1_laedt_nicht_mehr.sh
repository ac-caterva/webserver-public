#!/bin/bash 
#v1 Neuerstellung

# Um das Script stuendlich laufen zu lassen folgende Kommandos ausfuehren:
#
#   sudo touch  /etc/cron.hourly/uli_ITCI1_laedt_nicht_mehr
#   sudo nano /etc/cron.hourly/uli_ITCI1_laedt_nicht_mehr
## Folgende Zeilen in das Scripte eintragen:
#   #!/bin/bash 
#   /home/admin/bin/uli_ITCI1_laedt_nicht_mehr.sh
#   
## Editor beenden und Datei speichern
#   sudo chown root:root /etc/cron.hourly/uli_ITCI1_laedt_nicht_mehr
#   sudo chmod 755 /etc/cron.hourly/uli_ITCI1_laedt_nicht_mehr



#Script schreibt die Jahreswerte in die SwDER/ITCI1 wenn diese 0 sind.

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

fi

