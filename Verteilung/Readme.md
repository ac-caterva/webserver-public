# Beschreibung des Mechanismus der automatischen Verteilung der Daten auf der Pi

- Es werden nur Dateien verteilt.
- Verzeichnniss muessen vom `CreateTargetDirScript` erstellt werden - Eigentuemer und Berechtigungen setzten
- Alle Dateien, die verteilt werden sollen muessen in der Datei `Copy2Pi.config` eingetragen sein.

Nur wenn die Quelldatei von der Zieldatei abweicht wird das `PreUpdateScript` ausgefuehrt.
Nur wenn das PreUpdateScript erfolgreich beendet wird, kann die Datei kopiert werden und das `UpdateScript` wird ausgefuehrt.
Das `PostUpdateScript` wird immer ausgefuehrt, wenn die Quelldatei von der Zieldatei abweicht. Also auch, wenn das `PreUpdateScript` nicht erfolgreich war und somit die Quelldatei nicht auf die Zeildatei kopiert wurde.

## Spezifikation der Implementierung 

Lesen einer Zeile der Copy2Pi.config

- das CreateTargetDirScript ausfuehren. Verzeichnisse nur anlegen, wenn sie noch nicht existieren.
- Pruefen, ob die Datei kopiert werden muss <br>
`rsync -n -i --checksum <SourceFile> <TargetFile>`<br>
Moegliche Ausgaben des Kommados `rsync -n -i --checksum source/foo target/bar`

  - keine Ausgabe         # Datei ist identisch
  - `>f+++++++++ foo`     # Datei existiert nicht
  - `>fc.T...... foo`     # Datei hat Unterschiede<br>

  Dateiname der Quelldatei mit Unterschieden ergibt sich wie folgt:<br>
  `FILENAME=`rsync -n -i --checksum \<Quelledatei> \<Zieldatei> | cut -d" " -f2``

  Wenn `$FILENAME` dem `basename $SourceFile` entspricht, dann

  - das PreUpdateScript ausfuehren und wenn es erfolgreich war dann
    - wenn 'COPY_WITH_RSYNC' auf YES steht mit 
      `rsync <Quelledatei> <Zieldatei>`die Datei kopieren.
    - das UpdateScript starten<br>
      Wenn 'COPY_WITH_RSYNC' auf NO steht dann muss das UpdateScript die Datei kopieren
  - das PostUpdateScript starten

## Parameter der Konfigurationsdatei

Dateiname: `Config/Copy2Pi.config`

- SourceFile - relativer Pfad/Dateiname<br>
  z.B. `pi/usr_loca_bin/eth0_start_192_168_0_50.sh`
- TargetFile - absoluter Pfad/Dateiname<br>
  z.B. `/usr/local/bin/eth0_start_192_168_0_50.sh`
- CreateTargetDirScript - relativer Pfad/Dateiname des Scriptes<br>
  Das Script muss bei Erfolg ein 'echo SUCCESS' ansonsten 'echo NO_SUCCESS' ausgeben.
  Wenn kein Script benoetigt wird, dann NONE eintragen
- PreUpdateScript - relativer Pfad/Dateiname des Scriptes<br>
  Hier muessen laufenden Prozesse, die mit der zu kopierenden Datei zu tun haben, gestoppt werden.
  Das Script muss bei Erfolg ein 'echo SUCCESS' ansonsten 'echo NO_SUCCESS' ausgeben.
  Wenn kein Script benoetigt wird, dann NONE eintragen
- UpdateScript - relativer Pfad/Dateiname des Scriptes<br>
  Wenn CopyWithRsync = NO, dann muss dieses Script die Datei kopieren. Trifft bei Datein zu, die nicht dem User pi gehoeren. `rsync` hat dann keine Rechte um zu kopieren. Der Check mit `rsync` laeuft problemlos, da das Verzeichnis in der die Datei angelegt/geaendert werden soll, meistens von allen gelesen werden darf. Daher ist in diesem Script die Datei mit `sudo cp ....` zu kopieren. Nicht vergessen die entsprechenden Eigentuemer (user:group) und Berechtigungen zu setzen.<br>
  Alle anderen update relevante Taetigkeiten.
  Wenn kein Script benoetigt wird, dann NONE eintragen
- PostUpdateScript - relativer Pfad/Dateiname des Scriptes<br>
  Hier muessen die Prozesse, die mit dem PreUpdateScript gestoppt wurden, wieder gestartet werden.
  Wenn kein Script benoetigt wird, dann NONE eintragen.
  Das Script kann bei Erfolg ein 'echo SUCCESS' ansonsten 'echo NO_SUCCESS' ausgeben.
- CopyWithRsync - YES oder NO
  - YES: Die Datei wird mit rsync kopiert
  - NO: Die Datei muss mit den UpdateScripte kopiert werden

Alle Scripte muessen ausfuehrabr sein.

## Verteilung starten

Die Verteilung wird gestartet mit dem Aufruf `/home/pi/Git-Clones/webserver/Copy2PiVerteilung.sh`
Protokoll steht in der Datei `/var/caterva/logs/Copy2PiVerteilung.log`

