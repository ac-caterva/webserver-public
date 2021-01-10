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
... Anzeige ob alle relevanten Netzwerkgeräte verfügbar sind  
... Anzeige Prozessorlast der Caterva   (Load)  
... Herunterfahren bzw Restart des Business-Controllers (Caterva) - Herunterfahren empfielt sich vor dem Ausschalten der Sicherung.
... Bedienoberfläche für Business-Optimum - damit können Vorgaben gemacht werden um den Wirkungsgrad der Anlage zu erhöhen. (Beta-Phase)

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
 
seit Jan. 2021 gib es die möglichkeit das Software selbst zu aktualisieren - hierzu muss aber eine Einstellung vorgenommen werden.
Folgendes muss einmalig in die FHEM Eingabezeile kopieren danach ENTER drücken: <br><br>
```update add https://raw.githubusercontent.com/meschnigm/fhem/master/controls_webserver.txt``` 
<br><br>
Im linken Menübaum findt sich folgende Befehle: <br>
***updatecheck*** Damit wird angezeigt welche Files bei einem Update installiert werden.<br>
***update***      Damit wird ein Updateprozess gestartet - der Vorgang kann einige Minuten dauern da vorher auch ein Backup erstellt wird.<br>
***restart pi***  Nachdem der Prozess abgeschlossen ist muss ein Restart von FHEM durchgeführt werden.<br><br>
 
 ![update](Bilder/update.jpg) 
 
## Datenaktualisierung / Funktionsweise
Ein Skript kopiert alle minütlich die Daten auf den Raspberry um diese dort anzuzeigen. pro Minute wird ein Datenpunt angezeigt.

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
|![BusinessOptimum](Bilder/BusinessOptimum.JPG) | **Die Folgenden Seiten befinden sich aktuell im Beta-Status und sind ggf. noch nicht allgemein zugänglich.** Über dieses Menü können die Parameter für die BusinessOptimum Logik erstellt und zur Caterva übertragen werden. Diese Logik soll den Speicherschrank daran hindern bei geringer Leistung aktiv zu werden, da hier der Wirkungsgrad relativ ungünstig ist. Es kann also erreicht werden, dass erst ab 2500W eingespeichert wird und nur bei einem Verbrauch von 3000W ausgespeichert wird. Jeder kann die Parameter auf seine gegebenheiten anpassen. Die Werte in gelb entsprechen der aktuellen Einstellung - mit den Schiebereglern können die Werte verändert werden. Nur wenn gewisse Abhängikeiten eingehalten werden ist die Kofiguration lauffähig. Solle sich ein Regler automatisch verändern wird vom Programm eine soche Abhänigkeit eingehalten.
|![BusinessOptimum](Bilder/BusinessOptimum_0.JPG) |Im Menüpunkt "Standardeinstellungen" können durch anklicken auf Sommer bzw. Winter zwei Standardkonfigurationen eingespielt werden. Dies ist hilfreich falls die Parameter noch nicht initialiisert sind (???). Will man eigene Standardkonfigurationen abspeichern klickt man auf "Standardkonfiguration editieren".
|![BusinessOptimum](Bilder/BusinessOptimum_0.1.JPG) |Ganz unten in dem Dialog welcher sich daraufhin öffnet findet man "mySummerSetting" und "myWinterSetting" klickt man diese öffnen sich weitere Details.
|![BusinessOptimum](Bilder/BusinessOptimum_0.2.JPG) |Die eigentlichen Parameter lassen sich nach Klick auf DEF auch verändern. 
|![BusinessOptimum](Bilder/BusinessOptimum_1.JPG) |Im Menüpunkt "Einspeicherung" kann über zwei Regler der Einschaltpunkt und der Abschaltpunkt für das Einspeichern bestimmt werden. Wird die Schwelle für Einspeicherung beenden für eine Zeit unterschritten geht der Inverter in den Standby betrieb. Diese Zeit kann mit dem Parameter 5.1 eingestellt werden.
|![BusinessOptimum](Bilder/BusinessOptimum_2.JPG) |Im Menüpunkt "Ausspeicherung sofort" findet sich die Einstellung ab welcher Leistung eine Ausspeicherung ohne Zeitverzögerung beginnen soll. 
|![BusinessOptimum](Bilder/BusinessOptimum_3.JPG) |Im Menüpunkt "Ausspeicherung verzögert" findet sich die Einstellung ab welcher Leistung eine Ausspeicherung nach einer gewissen Verzögerung beginnen soll. Mit diesen beiden Parametern kann man gezielt auf einzelne Verbraucher reagieren.
|![BusinessOptimum](Bilder/BusinessOptimum_4.JPG) |Im Menüpunkt Ladeschwellen kann unter 4.1 der Maximale SoC eingestellt werden auf welchen der Speicher aufgeladen wird. Werte größer 90% lassen sich nicht einstellen da die Caterva interne Logik dies nicht zulässt. Ein erneutes Einspeichern wird erst gestartet wenn der Parameter 4.2 Soc-Charge unterschritten wird. Damit wird ein ständiges Nachladen verhindert. Der Parameter SoC-Discharge ist die Ladeschwelle auf die sich der Speicher entladen soll. Fällt der Speicher auf einen Ladezustand von SoC-min wird ein Notladeprogramm gestartet und der Speicher wird über das Versorgungsnetz auf SoC-Discharge aufgeladen.
|![BusinessOptimum](Bilder/BusinessOptimum_5.JPG) |Hier findet sich die bereits angesprochene Zeit bis zum Übergang in den Standby-Mode sowie die Zykluszeit der Business Optimim Routine. Längere Zeiten ergeben eine geringere Systemlast - reagieren dafür etwas träger.
|![BusinessOptimum](Bilder/BusinessOptimum_6.JPG) | klickt man auf "text" kann man sich das erzeugte Config File ansehen.
|![BusinessOptimum](Bilder/BusinessOptimum_7.JPG) | klickt man auf "schreiben" bzw. auf die Diskette wird das Config-File auf die Caterva kopiert. Aktuell muss hier die BusinessOptimum Logik manuell gestoppt und wieder gestertet werden. 


## Aktuelle Probleme

### Für Business-Optimum muß FHEM Dateinen auf die Caterva kopieren   
Sind die Rechteeinstellungen nicht korrekt gesetzt gelingt das kopieren der config nicht.  
Das Skript FHEM_Setup_Copy_per_Shell.sh welches dem Technikteam bekannt ist behebt das Problem. 


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