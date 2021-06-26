UK
Testen verändern der Schaltschwellen

Habe auf die Spielwiese mal was zum testen gestellt.
Oben im Script stehen ein paar Infos.
Sicher noch viel Optimierungsbedarf, aber das man mal ein Gefühl bekommt auf was es ankommt.
Schwellwerte kann man im Script über die Variablen anpassen.

![Bildschirmfoto vom 2021-04-05 09-58-15](https://user-images.githubusercontent.com/60625731/113552790-f338a000-95f6-11eb-9e95-d39fb83abbfe.png)


Ist inzwischen im Webserver Repository gelandet.
# Ein paar grundlegende Befehle/Infos:
Wenn das CS_Steuerungs.txt File im Verzeichnis /home/admin/bin liegt werden die Werte daraus genommen.
Ist es nicht vorhanden werden default Werte genommen.
Veränderungen werden alle 10 Minuten geprüft und übernommen. (immer wenn die Uhrzeit Minuten hinten 0 hat)
Die Veränderung wird im Logfile ausgegeben/dokumentiert.
Anschauen Logfile:
cat /var/log/CS_Steuerung_      2 mal Tabulator Taste drücken dann werden alle vorhanden Logfiles angezeit das aktuellste auwählen.
cat /var/log/CS_Steuerung_2021-06-08_13-35.txt     enter

Live mitschauen was ins Logfile geschrieben wird:
tail -f /var/log/CS_Steuerung_      2 mal Tabulator Taste drücken dann werden alle vorhanden Logfiles angezeit das aktuellste auwählen.
tail -f /var/log/CS_Steuerung_2021-06-08_13-35.txt   enter

Anschauen Konfigfile:
cat CS_Steuerungs.txt    enter       In der ersten Zeile stehen die Konfigurationen darunter was sie bedeuten.

Verändern Konfigurationsfile:
vi CS_Steuerungs.txt      enter     das File wird angezeigt 
i                                   es wird in den Einfügemodus gewechselt
mit den Pfeiltasten auf den zu ändernden Wert gehen und tippen, alte Werte löschen auf Syntax achten
strg + c                            der Einfügemodus wird beendet
:wq                                 das File abspeichern
Wenn man sich nicht sicher ist oder man das File nicht abspeichern möchte
strg + c                            der Einfügemodus wird beendet
:q!                                 das File wird geschlossen und nicht abgespeichert

Die Veränderung kann dann wie oben beschrieben überprüft werden.
