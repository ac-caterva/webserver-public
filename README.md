# webserver-public

Erst mal ein paar ganz wichtige Infos fuer diejenigen, die sich mit Github auskennen: <br>
&#9889; 1. Bitte keine Aenderungen an diesem Repository vor nehmen. Das Repo wird automatisch aktualisiert.&#9889; <br>
&#9889; 2. Das webserver Repo wird bei der Umstellung auf das publich Repo von der pi geloescht. &#9889; <br>
&#9889; 3. In Zukunft wird das Update nur noch ueber das public repo verfuegbar sein.&#9889; 

**Nun zur Doku fuer alle:**

Ihr koennt euch - wie in den folgenden Abschnitten beschrieben -  selbst die aktuellste Version unserer SW auf der Pi installieren. Dazu muesst ihr einmalig das Repo clonen und die Verteilung starten. Ab dann wird die Pi und die Caterva automatisch aktualisiert.

## Einmalige Taetigkeiten zum clonen (herunterladen) des Repo

Bitte gebt als Benutzer pi auf der Pi die folgenden Kommandos ein:

```bash
cd /home/pi/Git-Clones/
git clone git://github.com/ac-caterva/webserver-public.git
```

Damit erstellt ihr eine lokale Kopie des Repos auf der Pi.

Solltet ihr folgenden Fehlermeldung erhalten: `fatal: Zielpfad 'webserver-public' existiert bereits und ist kein leeres Verzeichnis.` Dann bitte mit dem Abschnitt **Repo auf den neuesten Stand bringen** weiter machen. Ansonsten geht es mit dem Abschnitt **Update auf der Pi starten** weiter.

### Repo auf den neuesten Stand bringen

Fuer alle, die das Repo bereits gecloned hatten. Ihr muesst statt dem clonen des Repos das Repo einmal manuell auf den aktuellen Stand bringen. 
Dazu auf der Pi die folgenden Kommandos eingeben:

```bash
cd /home/pi/Git-Clones/webserver-public/
./GetChangesFromGitHub.sh 
```

Ausgabe des Kommandos:

```bash
remote: Enumerating objects: 23, done.
remote: Counting objects: 100% (23/23), done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 12 (delta 7), reused 12 (delta 7), pack-reused 0
Entpacke Objekte: 100% (12/12), Fertig.
Von https://github.com/ac-caterva/webserver-public
 * branch            HEAD       -> FETCH_HEAD
Aktualisiere 982aaf4..7252d1f
Fast-forward
 Verteilung/Readme.md               |  2 +-
 caterva/BusinessOptimum/Readme.md  | 18 +++++++++++++++++-
 pi/var/caterva/scripts/copy_log.sh |  2 +-
 3 files changed, 19 insertions(+), 3 deletions(-)
```

## Update auf der Pi starten

Die Daten, die vom github geladen wurden muessen jetzt noch auf die Pi und die Caterva verteilt werden. Dazu bitte das folgende Kommando eingeben:

```bash
cd /home/pi/Git-Clones/webserver-public/   
./Copy2PiVerteilung.sh 
```

Die Ausgabe des Kommandos kann variieren, je nachdem was zu erledigen ist. Hier also ein Beispiel der Ausgabe:

```bash
=========================================================
2021-02-04_17:46:11: Update started
             REPO_BASEDIR: /home/pi/Git-Clones/webserver-public
=========================================================
2021-02-04_17:46:11: Start processing of file: pi/usr_local_bin/eth0_start_192_168_0_50.sh
File pi/usr_local_bin/eth0_start_192_168_0_50.sh is identical to /usr/local/bin/eth0_start_192_168_0_50.sh
2021-02-04_17:46:11: Finish processing of file: pi/usr_local_bin/eth0_start_192_168_0_50.sh
=========================================================
2021-02-04_17:46:12: Start processing of file: pi/var/caterva/scripts/copy_log.sh
File pi/var/caterva/scripts/copy_log.sh differs from /var/caterva/scripts/copy_log.sh
Starting pre-update
Starting rsync
Starting post-update
2021-02-04_17:46:42: Finish processing of file: pi/var/caterva/scripts/copy_log.sh
=========================================================
2021-02-04_17:46:42: Update finished
=========================================================
pi@raspberrypi:~/Git-Clones/webserver-public $ 
```

Dann noch die Verteilung auf die Caterva starten:

```bash
cd /home/pi/Git-Clones/webserver-public/ 
./Copy2CatervaVerteilung.sh
```

Die Ausgabe des Kommandos kann variieren, je nachdem was zu erledigen ist. Hier also ein Beispiel der Ausgabe:

```bash
=========================================================
2021-02-22_01:34:08: Update started
             REPO_BASEDIR: /home/pi/Git-Clones/webserver-public
=========================================================
2021-02-22_01:34:08: Start processing of file: caterva/analysis/uli_Abfrage_Status.sh
File caterva/analysis/uli_Abfrage_Status.sh differs from bin/uli_Abfrage_Status.sh
Starting rsync
2021-02-22_01:34:18: Finish processing of file: caterva/analysis/uli_Abfrage_Status.sh
=========================================================
2021-02-22_01:34:18: Start processing of file: caterva/analysis/uli_invoice_aktuell_online.sh
File caterva/analysis/uli_invoice_aktuell_online.sh differs from bin/uli_invoice_aktuell_online.sh
Starting rsync
2021-02-22_01:34:26: Finish processing of file: caterva/analysis/uli_invoice_aktuell_online.sh
=========================================================
2021-02-22_01:34:26: Start processing of file: caterva/analysis/uli_invoice_Wirkungsgrad_online.sh
File caterva/analysis/uli_invoice_Wirkungsgrad_online.sh differs from bin/uli_invoice_Wirkungsgrad_online.sh
Starting rsync
2021-02-22_01:34:32: Finish processing of file: caterva/analysis/uli_invoice_Wirkungsgrad_online.sh
=========================================================
2021-02-22_01:34:32: Start processing of file: caterva/analysis/BC_Check.sh
File caterva/analysis/BC_Check.sh differs from bin/BC_Check.sh
Starting rsync
2021-02-22_01:34:38: Finish processing of file: caterva/analysis/BC_Check.sh
=========================================================
2021-02-22_01:34:38: Update finished
=========================================================
```

So das wars. Eure Pi und die Caterva sind jetzt auf dem neuesten Stand. UND: Die Aktualisierung erfolgt ab sofort automatisch. Ihr braucht weiter nichts mehr zu tun.

## Protokolldatei

Alle Aktionen und Fehler werden in die Dateien `/var/caterva/logs/Copy2PiVerteilung.log` und `/var/caterva/logs/Copy2CatervaVerteilung.log` protokolliert.

## CS Steuerung aktivieren

 Sollte euere Pi noch nicht automatisch aktualisert werden, dann muesst ihr zuerst die Schritte aus den Kapiteln 
  - [Einmalige Taetigkeiten zum clonen (herunterladen) des Repo](https://github.com/ac-caterva/webserver-public#einmalige-taetigkeiten-zum-clonen-herunterladen-des-repo)

  - [Update auf der Pi starten](https://github.com/ac-caterva/webserver-public#update-auf-der-pi-starten)

in diesem Dokument durchfuehren.

Wenn eure Pi automatisch aktualisiert wird, dann koennt ihr die CS Steuerung auf eurer Caterva aktivieren.

Dazu sind folgende Schritte notwendig:

1. Anmelden auf der Caterva
2. Zwei Kommandos auf der Caterva ausfuehren
3. Abmelden von der Caterva
4. CS Steuerung im FHEM integrieren

Solltet ihr unsicher sein, dann meldet euch bitte wie im Kapitel **[Probleme / Fragen](https://github.com/ac-caterva/webserver-public#probleme--fragen)** beschrieben und wir helfen gerne.

Hier nun die Schritte im Detail.

### 1. Anmelden auf der Caterva

Auf der Pi im LXTerminal folgendes Kommando eingeben:

`ssh admin@caterva`

Danach seid ihr auf der Caterva angemeldet. Das sollte etwa so aussehen:

```
pi@raspberrypi:~ $ ssh admin@caterva
 __  __ _                
|  \/  (_) ___ _ __ ___  
| |\/| | |/ __| '__/ _ \ 
| |  | | | (__| | | (_) |
|_|  |_|_|\___|_|  \___/ 
                         

Welcome to ARMBIAN Debian GNU/Linux 8 (jessie) 4.6.3-sunxi 
System load:   4.06             Up time:       1 day          Local users:   2            
Memory usage:  29 % of 997Mb    IP:            192.168.0.222 192.168.88.222 
CPU temp:      61°C           
Usage of /:    53% of 4.0G   


Business controller status:

 - Systemzeit: 09.09.2021 13:55:31
 - Release /home/admin/release/bin.zip (2019-03-18, 01:43:31) ist bereit zur Installation
 - Ein Release wurde bereits nach /home/swarm-device/business-controller installiert:
   - Built:   2019-03-06, 15:37:54
   - Version: stable
   - Author:  swarm @ Caterva GmbH
 - Gerät ist registriert für K000245 mit SN000245:
   - Maximale Haushaltsleistung: 25633 W (bzw. 8544 W / Phase)
   - Maximale PV-Leistung:       9900 W
   - Haushaltsverbrauch:         6473 kWh p.a.
   - Lastwiderstand:             nicht aktiviert
   - Zähler PV plus Haushalt:    ECS3     (DK8P1006)
   - Haushaltsverbrauch-Zähler:  none     (none)
   - Energiespeicher-Zähler:     none     (none)
   - PV-Zähler:                  SMA      (305148084)
   - Hausanschluss-Zähler:       none     (none)
   - Inselnetzoption:            NICHT installiert
   - Inbetriebnahme-Datum:       20.12.2018 12:42
   - ESS Typ:                    SiemensGen2
 - Business controller läuft (PID: 23841)


Watchdog status:

Watchdog found running

admin@2017-09-13-sdImage:~/bin$ 
```

### 2. Zwei Kommandos auf der Caterva ausfuehren

Die Berechtigung fuer die CS Steuerung setzen:

` chmod 775 CS_Steuerung.sh`

Das sieht dann wir folgt aus:

```
admin@2017-09-13-sdImage:~/bin$ chmod 775 CS_Steuerung.sh
admin@2017-09-13-sdImage:~/bin$ 
```

Damit die CS Steuerung automatisch bei jedem Neustart der Caterva gestartet wird muesst ihr folgendes Kommado ausfuehren:

`crontab CS_Steuerung_crontab`

Das sieht dann wie folgt aus:

```
admin@2017-09-13-sdImage:~/bin$ crontab CS_Steuerung_crontab
admin@2017-09-13-sdImage:~/bin$ 
```

### 3. Abmelden von der Caterva

Die Caterva muss einmal neu gestartet werden, damit die CS Steuerung gestartet wird. Dabei werdet ihr von der Caterva abgemeldet und landet wirder auf der Pi.

Dazu bitte das folgende Kommando eingeben:

`sudo shutdown -r now`

Das sieht dann wie folgt aus:

```
admin@2017-09-13-sdImage:~/bin$ sudo shutdown -r now
Connection to caterva closed by remote host.
Connection to caterva closed.
pi@raspberrypi:~ $ 
```

### 4. CS Steuerung im FHEM integrieren

Die CS Steuerung ist mit Standard Parametern eingestellt, die du nicht zwingend veraendern musst. Solltest du trotzdem die Parameter aendern wollen, dann hat Manuel dazu eine Oberflaeche im FHEM angelegt. Fuehre folgendes Kommando auf der Pi aus um die Oberflaeche fuer die CS Steuerung im FHEM zu aktivieren:

`FHEM_add_CS2Private.sh`

Das sieht dann wie folgt aus:

```
pi@raspberrypi:~ $ FHEM_add_CS2Private.sh 
CS_Steuerung wurde erfolgreich in FHEM integriert
pi@raspberrypi:~ $ 
```

 &#10024; <br>
 &#10024;  **So das war's.**<br>
 &#10024; <br>

 Wie diese Oberflaeche zu bedienen ist findest du - sowie alle FHEM Infos von Manuel - [hier](https://github.com/meschnigm/fhem#business-optimum-und-cs_steuerung)

## Probleme / Fragen

Bei Problemen oder Fragen bitte ein Issue anlegen: https://github.com/ac-caterva/webserver-public/issues/new/choose <br>

Wer sich mit dem Github nicht anfreunden will/kann, darf seine Probleme auch gerne im [Discord](https://discord.com/channels/592654792212348928/672912964210262028) melden. 

# Unterstützung

Die initiale Konfiguration der Pi, die Verteilung der SD Karten und die Erstellung der notwendigen Scripte ist mein Beitrag zu unserem gemeinsamen Ziel unsere Speicher weiterhin sinnvoll zu nutzen. Wer auf freiwilliger Basis eine Anerkennung geben will, kann dies hier tun [Paypal](https://www.paypal.com/paypalme/ChristianAnja)
