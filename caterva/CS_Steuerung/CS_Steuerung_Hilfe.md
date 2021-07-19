# Ein paar grundlegende Befehle/Infos für CS_Steuerung

## Abfragen ob CS_Steuerung oder CS_SteuerungStarter laeuft:

```
/home/admin/bin/CS_SteuerungStarter.sh status
```

## CS_Steuerung bzw. CS_SteuerungStarter automatisch mit der Caterva starten lassen 

Als Benutzer admin auf der Caterva mit `crontab -e` den folgende Eintrag in der crontab machen, damit die Steuerung beim booten gestartet wird:

```
@reboot /home/admin/bin/CS_SteuerungStarter.sh start
```

## Einmalig CS_Steuerung_Starter starten

```
nohup /home/admin/bin/CS_SteuerungStarter.sh start &
```

## Individuelle Konfiguration fuer die CS_Steuerung anlegen

Wenn das CS_Steuerungs.cfg File im Verzeichnis /home/admin/bin liegt werden die Werte daraus genommen.
Dieses File ist fuer die "persoenlichen/individuellen" Einstellungen und wird nicht ueberschrieben, es darf veraednert werden.
Veränderungen werden alle 10 Minuten geprüft und übernommen. (immer wenn die Uhrzeit Minuten hinten 0 hat)

Anlegen der Datei fuer die individuelle Konfiguration:

```
cp /home/admin/bin/CS_Steuerung.txt /Home/admin/bin/CS_Steuerung.cfg
```

Verändern der individuellen Konfiguration:

```
vi CS_Steuerungs.cfg      enter     die Datei wird angezeigt 
i                                   es wird in den Einfügemodus gewechselt
mit den Pfeiltasten auf den zu ändernden Wert gehen und tippen, alte Werte löschen auf Syntax achten
strg + c                            der Einfügemodus wird beendet
:wq                                 die Datei abspeichern
Wenn man sich nicht sicher ist oder man die Datei nicht abspeichern möchte
strg + c                            der Einfügemodus wird beendet
:q!                                 die Datei wird geschlossen und nicht abgespeichert
```

Die Veränderung wird im Logfile ausgegeben/dokumentiert.
Wenn die Datei CS_Steuerungs.cfg nicht existiert, dann ird eine default Konfig geladen diese steht in der Datei `CS_Steuerung.txt` und darf nicht veraendert werden.
Falls diese Datei nicht vorhanden ist wird das Script abbrechen.

Die Veränderung kann man im Logfile ueberpruefen.
Anschauen Logfile:

```
cat /var/log/CS_Steuerung.log            enter
```

Live mitschauen was ins Logfile geschrieben wird:

```
tail -f /var/log/CS_Steuerung.log        enter
```

Anschauen individuelle Konfigurationsdatei:

```
cat CS_Steuerungs.cfg    enter       In der ersten Zeile stehen die Konfigurationen darunter was sie bedeuten.
```

## Beenden der CS_Steuerung und CS_SteuerungStarter

### Beenden CS_Steuerung

```
touch /tmp/CS_SteuerungStop
```

### Erneutes Starten CS_Steuerung

```
rm /tmp/CS_SteuerungStop
```

### Beenden CS_SteuerungStarter

Der CS_SteuerungStarter kann nur beendet werden wenn die CS_Steuerung beendet wurde.

```
touch /tmp/CS_SteuerungStop
touch /tmp/CS_SteuerungStarterStop
```

### Erneutes Starten CS_SteuerungStarter

Entweder mittels bereits zuvor erwaehntem Kommando

```
nohup /home/admin/bin/CS_SteuerungStarter.sh start &
```

oder falls der Eintrag in der crontab gemacht wurde mittel reboot der Caterva

```
sudo shutdown -r now
```
