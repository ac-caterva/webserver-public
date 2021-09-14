# Aktivieren der CS Steuerung auf der Caterva

Alle Schritte sind im Github beschrieben. Du findest die Anleitung [hier](https://github.com/ac-caterva/webserver-public#cs-steuerung-aktivieren).

# Ein paar grundlegende Befehle/Infos

Es ist nicht mehr noetig Befehle einzugeben um die Protokolldatei anzusehen oder Aenderungen an der Konfiguration vorzunehmen. Manuel hat die CS Steuerung ins FHEM integriert. Du kannst mittels FHEM die Konfiguration der CS Steuerung aendern und du kannst dir die letzten Zeilen der Protokolldatei anzeigen lassen. Wie das funktioniert findest du [hier](https://github.com/meschnigm/fhem#readme)

Veränderungen an der Konfiguration werden alle 10 Minuten geprüft und übernommen -immer zur vollen Stunde, um 10 nach, um 20 nach, um halb und zo weiter.
Die Veränderung wird im Logfile ausgegeben/dokumentiert.
