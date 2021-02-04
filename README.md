# webserver-public

Bitte keine Aenderungen an diesem Repository vor nehmen. Das Repo wird automatisch aktualisiert.


## Einmalige Taetigkeiten zum Umstellen auf das public Repo

Dazu das webserver-public Repo auf der pi clonen 

```
pi@raspberrypi:~ $ cd Git-Clones/
pi@raspberrypi:~/Git-Clones $ git clone https://github.com/ac-caterva/webserver-public.git
```
## Update auf der Pi starten

Der Update besteht immer aus 2 Schritten:
1. Die neueste Version vom Github laden
1. Die Daten verteilen


### Die neueste Version vom Github laden
```
pi@raspberrypi:~ $ cd Git-Clones/webserver-public/
pi@raspberrypi:~/Git-Clones/webserver-public $ ./GetChangesFromGitHub.sh 
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
 
### Die Daten verteilen

&#9889; Das webserver Repo wird hierbei von der pi geloescht. &#9889; <br>
&#9889; In Zukunft wird das Update nur noch ueber das public repo verfuegbar sein.&#9889; 

```
pi@raspberrypi:~/Git-Clones/webserver-public $ ./Copy2PiVerteilung.sh 
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

## Protokolldatei

Alle Aktionen und Fehler werden in die Datei `/var/caterva/logs/Copy2PiVerteilung.log` protokolliert.

## Probleme ?

&#10067; Bei Problemen bitte in diesem [Repo](https://github.com/ac-caterva/webserver-public/issues/new/choose) oder im [private webserver Repo](https://github.com/ac-caterva/webserver/issues/new/choose) ein Issue eroeffnen. &#10067;

