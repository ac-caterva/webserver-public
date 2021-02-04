# Dokumentation Business Optimum

## Funktionsweise des Business Optimum(BO)

## Funktionsweise des Business Optimum Starter(BOS)

Der Business Optimuem Starter sorgt dafuer, dass der BO nur genau einmal auf einer Anlage laeuft. Dazu ist der BOS in die crontab des Benutzwers admin eingetragen, so dass bei jedem reboot der BOS gestartet wird. Der BOS startete dann den BO und sobald der BO sich beendet wird nach 5 Sekunden vom BOS ein neuer BO gestartet.

Syntax:

- starten: `BusinessOptimumStarter.sh start`
- stoppen: `BusinessOptimumStarter.sh stop`
- status:  `BusinessOptimumStarter.sh status`

Log Datei vom BOS:
- `/var/log/BusinessOptimumStarter.log`

Ausgabeumleitung der Fehler des BO:
- `/var/log/BusinessOptimum.out`

Die aktuelle PID des BOS und BO stehen in den Dateien `/tmp/BusinessOptimum.pid` und `/tmp/BusinessOptimumStarter.pid`.

Nachdem BOS auf der Caterva eingerichtet ist, gibt es keinen Grund den BOS zu stoppen oder zu starten. Sollte dies trotzdem notwendig sein, dann kann das BOS Script nachdem es manuell gestoppt wurde auch manuell gestartet werden. Das Starten auf der Kommandozeile der Pi sollte dann mit `nohup BusinessOptimumStarter.sh start &` gemacht werden.

## BOS/BO aus FHEM stoppen

BOS laesst sich durch Anlegen der Datei /tmp/BusinessOptimumStarterStop stoppen.
Allerdings wird die Datei erst erkannt, wenn der laufende BO Prozess gestoppt wurde. Daher kann BOS nur gestoppt werden mit:

```
touch /tmp/BusinessOptimumStarterStop
touch /tmp/BusinessOptimumStop
```

⚡ Die Reihenfolge der Kommandos ist wichtig ⚡

Damit beendet sich der BO Prozess, BOS (der VaterProzess) laeuft weiter und erkennt, dass er sich beenden soll.

## BOS/BO aus FHEM starten

Dazu muss die Caterva gebootet werden.Das Starten von BOS ist mittels Script oder Datei aus FHEM nicht moeglich.

## Einrichten des Business Optimum

### Standalone

### mit Business Optimum Starter

Installation:

- BusinessOptimumStarter.sh nach /home/admin/bin kopieren
- als admin auf der caterva `crontab -e` starten
- und folgenden Eintrag machen

```
# BusinessOptimumStarter nach reboot starten
@reboot /home/admin/bin/BusinessOptimumStarter.sh start
```

Danach die Caterva rebooten mit
```
sudo shutdown -r now
```

Business Optimum Starter wird beim booten gestartet und 
sorgt dann dafuer, dass BO immer laeuft. Wenn du erst 
einmal ohne reboot der Caterva BOS und BO testen willst, 
dann  mit

```
BusinessOptimumStarter.sh start &
```

den BOS starten. Sieh dir die weiter oben genannetn log Dateien von BO und BOS an um zu pruefen ob BOS und BO laufen.

## Betreiben des Business Optimum

### Standalone

❌  Hier sollte etwas zu den Einstellmoeglichkeiten im FHEM stehen oder auf die entsprechende Seite verwiesen werden

### mit Business Optimum Starter

Es gibt keinen Unterschied zum Standalone Betrieb des BO.
