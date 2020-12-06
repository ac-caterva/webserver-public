# Kurzanleitung FHEM 
![Tablet_UI_Seite3](Bilder/Tablet_UI_Seite3.JPG) 

**FHEM** steht für „**F**reundliche **H**ausautomation und **E**nergie-**M**essung“ und ist die neue Weboberfläche für den eigenverantwortlichen hausdienlichen Betrieb. siehe Kapitel II aus der Roadmap im Ordner Protokolle.

## Motivation

Seitdem wir keinen Zugriff mehr auf das Caterva-App haben, fehlt uns die Übersicht was das Gerät überhaupt macht, auch fehlt die  Zentralstelle in Pullach, die nach dem Speicher sieht. 

Technisch ist es dem Team zwischenzeitlich gelungen, einige Speicher wieder in Betrieb zu nehmen. Um die Speicher eigenverantwortlich hausdienlich in Betrieb zu nehmen ist eine graphische Oberfläche erfoderlich. Auch ist der Zugriff auf eventuell anstehende Fehler wünschenswert.
Genau diese Oberfläche ist in FHEM realisiert.

## Was ist FHEM

FHEM (TM) ist ein in Perl geschriebener, GPL lizensierter Server für die Heimautomatisierung. 
In FHEM können von den unterschiedlichsten Geräten im Haushalt Daten angezeigt und Steuerungsaufgaben programmiert werden.

## Funktionsumfang

Auf der Weboberfläche können die...  

... Leistungswerte ( Verbrauch / PV-Leistung / Leistung in bzw. aus dem Speicher / sowie der Netzbezug dargestellt werden.  
... Zählerstände ausgelesen werden  
... Weiterhin werden statistische Werte wie Tages/Monats/Jahresverbrauch berechnet  
... Fehlereinträge und Statusregister ausgelesen   

## Was brauche ich um FEHM zu benutzen?

FEHM ist auf den verteilten SD-Karten bereits installiert. Es genügt ein Internet-Browser um die Seite aufzurufen. 

## Wie kann ich FHEM öffnen?
Wie gesagt genügt ein einfacher Webbrowser (Safari/Firefox/Edge/Chrome ...)
![Login](Bilder/login.JPG) 


### Aufruf FHEM-Weboberfläche:
```sh
<IP-Raspberry>:8083
Benutzername: pi
Passwort: pi
```
  

Alternativ steht noch eine Ansicht zur Verfügung, die für Tablets optimiert ist.


### Aufruf Tablet-UI:
```sh
<IP-Raspberry>:8083/fhem/ftui/
Benutzername: pi
Passwort: pi
```
  
 ## Wie wird FHEM aktualisiert?
 
Die aktuellen FEHM Files sind in einem Github gespeichert - das Technikteam kann dein System aktualisieren.
Folgende Befehle sind dazu erfoderlich.

 ```bash
sudo systemctl stop fhem  
cd /home/pi/Git-Clones/webserver/
./GetChangesFromGitHub.sh 
./Copy2ApacheServer.sh 
sudo systemctl start fhem  
```
## Datenaktualisierung / Funktionsweise
Ein Skript kopiert alle 5 Minuten die Daten auf den Raspberry um diese dort anzuzeigen. pro Minute wird ein Datenpunt angezeigt.

## Wie kann ich FHEM starten und stoppen

FHEM startet automatisch mit dem Raspberry Pi. Normalerweise ist also nichts weiter zu tun.

### Terminal
Mit folgenden Terminal Kommandos kann man FHEM starten / stoppen / bzw. den Status abfragen <br>
`sudo systemctl start fhem`  
`sudo systemctl stop fhem`  
`sudo systemctl status fhem`  

### FHEM Eingabezeile
Mit folgendem Kommando für die FHEM-Eingabezeile kann man FHEM neu starten:  
`shutdown restart` 

## Screenshots Tablet-UI
|Bild|Beschreibung|
| :---:   |  :---     |
|![Tablet_UI_Seite1](Bilder/Tablet_UI_Seite1.JPG) | Links oben:  PV-Leistung und erzeugte Energie.<br>Rechts oben:  Leistungsverlauf Einspeicherung (gelb) und Ausspeicherung (grün) sowie Ladezustand in %.<br>Links unten:  Verlauf des Verbrauchs, dabei farblich dargestellt ob der Verbrauch über den PV-Direktverbrauch (gelb) das Stromnetz (rot) den Speicher (grün) bestritten wird. Zusätzlich wird auch die Energieaufnahme des Hauses in kWh dargestellt.<br>Rechts unten:  Verlauf der Leistungsaufnahme aus dem Netz (rot) sowie Netzeinspeisung (gelb).  
|![Tablet_UI_Seite2](Bilder/Tablet_UI_Seite2.JPG) | Identischer Inhalt wie Seite 1 - links unten. Zusätzlich werden einige statistische Daten wie Tagesverbrauch / Montasverbauch etc. angezeigt. (Diese Seite ist noch nicht vollständig implementiert.)
|![Tablet_UI_Seite3](Bilder/Tablet_UI_Seite3.JPG) | Diese Darstellung ist aus der Caterva-App bekannt. Zusätzlich ist hier noch Gesamtleistung der PV-Anlage sowie der Gesamtverbrauch dargestellt. Der linke Teil zeigt den Energiefluss des Tages - hierzu muss der Raspberry aber über Nacht durchgelaufen sein. 
|![Tablet_UI_Seite4](Bilder/Tablet_UI_Seite4.JPG) | Die Fehlereinträge des Stromspeichers werden alle 10 Minuten ausgelesen und angezeigt. 
|![TabletUI am Tablet](Bilder/TabletUI%20am%20Tablet.JPG) | Und hier auf einem Lenovo Smart Tab M10 mit dem Fully Kiosk Browser. Dieser Browser lässt sich im Fullscreen Mode betreiben und hat in der kostenpflichtigen Variante (6,95€) eine Bewegungserkennung und schaltet dann das Display an.

## Screenshots FHEM-WEB
|Bild|Beschreibung|
| :---:   |  :---     |
|![FHEM-WEB_1_Graphen](Bilder/FHEM_WEB_Seite1.JPG) |   Diese Seite zeigt identische Informationen wie Seite 1 des Tablet-Ui aber zusätzlich noch den Load Verlauf (Prozessorlast des Business Controllers) Hohe Systemauslastung führt bei einigen Anlagen zu Problemen. Eine hohe Systempast liegt bei werten zwischen 5-6 vor.
|![FHEM-WEB_2_Wertetabellen](Bilder/FHEM_WEB_Seite2.JPG) | Darstellung der Momentanleistung sowie der Zählerstände. 
|![FHEM-WEB_3_Fehlerspeicher](Bilder/FHEM_WEB_Seite3.JPG) | Alle 10 Minuten werden die Fehlerspeicher aktualisiert, in der FHEM Weboberfläche kann die Datenaktualisierung über einen Update-Knopf auch angestossen werden.
|![FHEM-WEB_4_Statusregister](Bilder/FHEM_WEB_Seite4.JPG) | Auf diser Seite können einige Statusregister der Caterva ausgelesen werden. Einige Kommandos sind nicht bei allen Generationen vorhanden. Nur bei der GEN2 lassen sich hier z.b. die Spannungen der einzelnen Akkus anzeigen.<br> Im Abschnitt Systembefehle können wie in der Beschreibung gezeigt weitere Systembefehle abgesetzt werden die derzeit nicht implementiert sind. Falls einzelne Register noch von Interesse sind können diese implementiert werden. <br> Drückt man auf eine der Registernamen werden die Inhalte angezeigt. Über den Update Button wird das Register neu eingelesen. Sollten die Befehle aus diesem Abschnitt nicht klappen bitte den Abschnitt "Aktuelle Probleme" lesen.
|![Modulspannung GEN2](Bilder/akku_uebersicht_1.png) | Bei der GEN2 können über "Statusregistern" --> "Status Batteriemodule (Gen2 only)" die Modulspannungen angezeigt werden.


## Aktuelle Probleme

### Fehlerspeicher/Statusregister können nicht ausgelesen werden. 
Um die Fehlerregister auslesen zu können, muss zunächst eine Einstellung auf der Silverbox vorgenommen werden.<br>
`ssh admin@caterva`<br>
`sudo nano /etc/rc.local`<br>
hier die Zeile 13 bis 15 auskommentieren also ein # einfügen.

`# iptables -A INPUT -p tcp --dport 1337 -i lo -j ACCEPT`<br>
`# iptables -A INPUT -p tcp --dport 1337 -i tun0 -j ACCEPT`<br>
`# iptables -A INPUT -p tcp --dport 1337 -j DROP `<br>

speichern mit str-o<br>
exit mit str-x<br>
Neustart mit <br>
`sudo reboot -h now`

### Die Daten werden alle 5 Minuten erzeugt, möchte man nicht so lange warten ...

Skript zur Erzeugung des ESS_Minutenwerte-yyyy-mm.log manuel starten:  

`/home/pi/Git-Clones/webserver/var_caterva/scripts/copy_log.sh`  

### Warning: the ECDSA host key for 'caterva' differs ....
Sollte folgende Warnung erscheinen... mit `yes` bestätigen <br>
`Warning: the ECDSA host key for 'caterva' differs from the key for the IP address '192.168.0.222'`  <br>
`Offending key for IP in /home/pi/.ssh/known_hosts:2` <br>
`Matching host key in /home/pi/.ssh/known_hosts:5` <br>
`Are you sure you want to continue connecting (yes/no)?`<br>

Abhilfe mit .... <br>
`mv ~/.ssh/known_hosts ~/.ssh/known_hosts.alt`  <br> 
`touch ~/.ssh/known_hosts`  <br>

danach das Skript manuell anstoßen und ggf. den neuen host mit "yes" bestätigen ...   <br>
`cd /home/pi/Git-Clones/webserver/var_caterva/scripts/`  <br>
`./copy_log.sh`  <br>

führt man <br>
`./copy_log.sh`<br> 
erneut aus sollte das logfile ohne Fehlermeldung erzeugt werden.<br>
