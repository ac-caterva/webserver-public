# webserver-public

Erst mal ein paar ganz wichtige Infos fuer diejenigen, die sich mit Github auskennen: <br>
&#9889; 1. Bitte keine Aenderungen an diesem Repository vor nehmen. Das Repo wird automatisch aktualisiert.&#9889; <br>
&#9889; 2. Das webserver Repo wird bei der Umstellung auf das publich Repo von der pi geloescht. &#9889; <br>
&#9889; 3. In Zukunft wird das Update nur noch ueber das public repo verfuegbar sein.&#9889; 

**Nun zur Doku fuer alle:**

Ihr koennt euch - wie in den folgenden Abschnitten beschrieben -  selbst die aktuellste Version unserer SW auf der Pi installieren. Dazu muesst ihr einmalig das Repo clonen.  Ab dann koennt ihr immer mal wieder nachsehen ob es einen neue Verison gibt und diese dann auf der Pi verteilen.

## Einmalige Taetigkeiten zum clonen (herunterladen) des Repo

Bitte gebt als Benutzer pi auf der Pi die folgenden Kommandos ein:

```bash
cd /home/pi/Git-Clones/
git clone git://github.com/ac-caterva/webserver-public.git
```

Damite erstellt ihr eine lokale Kopie des Repos auf der Pi.

## Update auf der Pi starten

Der Update besteht immer aus 2 Schritten:
1. Die neueste Version vom Github laden
1. Die Daten auf die Pi und die Caterva verteilen

### 1. Die neueste Version vom Github laden

Dazu auf der Pi die folgenden Kommandos eingeben:

```bash
cd /home/pi/Git-Clones/webserver-public/
./GetChangesFromGitHub.sh 
```

Ausgabe des Kommandos:
 
Da ihr eben erste gecloned habt sieht die Meldung jetzt wie folgt aus:

```bash
Von https://github.com/ac-caterva/webserver-public
 * branch            HEAD       -> FETCH_HEAD
Bereits aktuell.
pi@raspberrypi:~/Git-Clones/webserver-public $
```

Sollte es inzwischen Aenderungen am Repo gegeben haben, dann sieht die Ausgabe so aehnlich aus wie hier:

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

### 2. Die Daten verteilen

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

So das wars. Eure Pi und die Caterva sind jetzt auf dem neuesten Stand.

## Protokolldatei

Alle Aktionen und Fehler werden in die Dateien `/var/caterva/logs/Copy2PiVerteilung.log` und `/var/caterva/logs/Copy2CatervaVerteilung.log` protokolliert.

## Probleme / Fragen

Bei Problemen oder Fragen bitte ein Issue anlegen: https://github.com/ac-caterva/webserver-public/issues/new/choose <br>

Wer sich mit dem Github nicht anfreunden will/kann, darf seine Probleme auch gerne im [Discord](https://discord.com/channels/592654792212348928/672912964210262028) melden. 

# Unterstützung

Die initiale Konfiguration der Pi, die Verteilung der SD Karten und die Erstellung der notwendigen Scripte ist mein Beitrag zu unserem gemeinsamen Ziel unsere Speicher weiterhin sinnvoll zu nutzen. Wer auf freiwilliger Basis eine Anerkennung geben will, kann dies hier tun https://paypal.me/pools/c/8xm58ob2st 
