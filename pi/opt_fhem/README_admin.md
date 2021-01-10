### FHEM-Admin

FHEM zeichnet sich nicht gerade durch eine intuitive Benutzeroberfläche aus.
Deswegen ist in der Variante die verteilt wird, alles versteckt was nicht erfoderlich ist. Der Funktionsumfang ist eingeschränkt um versehentliche Änderungen zu vermeiden.

Für manche könnte es aber interessant sein, weitere Geräte hinzuzufügen. (Wechselrichter, Wärmepumpen, Poolsteuerungen, eAutos etc.)
Hierzu ist einfach ein anderer Port bei der Anmeldung, sowie eine andere User/Paswort Kombination erfoderlich.

### Zweite Login-Variante - Port 8085 statt 8083

```sh
<IP-Raspberry>:8085
Benutzername: admin
Passwort: admin_fhem
```

In dieser Variante sind alle FHEM-Systemeinstellungen und Einstellungsdetails sichtbar und es können beliebige Änderungen vorgenommen werden. Wer tiefer einsteigen will sollte sich gleich die Einstiegslektüre ganz unten vornehmen. Für jemanden der sich nur kurz orientieren will bzw. eine kleine Änderung vornehmen will könnten folgende Zeilen helfen.

### Erweitertes Menü

einige zur Programmierung nützliche Menüelemente sind in der 8083 ausgeblendet gewesen.
![FHEM_ADMIN_Menue](Bilder/fhem_admin_1.JPG) 

#### Commandref
Um neue Geräte hinzuzufügen startet man z.B. in der Commandref (https://fhem.de/commandref_DE.html#)
Hier findet man etliche Geräte für die bereits eigene Module entwickelt wurden.

Beispiel: Wer einen SMA-Wechselrichters hinzufügen möchte findet in der Commandref sicher schnell das Modul "SMAInverter"
Hier sucht man die Zeile die mit define beginnt.
```define <name> SMAInverter <pin> <hostname/ip>````
Diese gibt man in die Eingabezeile ein und kann im nächsten Schritt bereits spezifische Felder für dieses Modul auswählen.
Achtung der neue Code ist in der fhem.cfg gelandet - und wird beim nächsten Update überschrieben!

#### Edit files 
1) Direktes editieren aller cfg Files.
2) Save config - zum abspeichern der Änderung
3) rereadcfg - In der Eingabzeile zum neuen einlesen der Konfiguration


#### lastloglines 
Zeigt die letzten 30 Zeilen des FHEM-Logfiles an. Anzahl Zeilen kann bei bedarf im Browserfenster erhöht werden.

### fhem.cfg / 00_Caterva / 00_Private.cfg

Die Programmierung von FHEM erfolgt normalerweise im File /opt/fhemfhem.cfg
Hier landen auch alle neuen Geräte die man über die Eingabezeile angelegt hat.
Am Ende der fhem.cfg werden weitere cfg-Files über ein include hinzugefügt.

Im File 00_Caterva sind alle Programbestandteile für unsere Weboberfläche enthalten.
Da die fhem.cfg sowie die 00_Caterva.cfg bei updates überschrieben wird, empfiehlt es sich alle eigenen Geräte in das File 00_Private zu verschieben bzw. diese dort direkt anzulegen.

### Unterprogramme

Oft lagert man Funktionen in Unterprogramme aus. Diese sind normalerweise in Perl geschrieben und werden im File 99_myUtils.pm gesammelt. Eigene Unterprogramme sollten in ebenfalls in einem File gesammelt werden z.b.99_myUtils2.pm Files mit 99 bzw. Uilts werden geladen ohne dass hierfür ein include erforderlich wäre.

Nach Änderungen müsste dann ein "reload 99_myUtils2.pm" in die Eingabezeile eingegeben werden. Alternativ "rereadcfg" hier wird alles neu eingelesen.

### Räume
Jedes Gerät hat das Attribut room. Damit wird ein neuer Raum im Menü erzeugt. Es empfiehlt sich eigene Geräte in einem neuen Raum zu organisieren.

### backup
Ein Backup aller Files ist schnell erstellt. Ein einfaches "backup" in der Eingabezeile genügt. Dieser Stand lässt sich bei Bedarf wieder herstellen.




### Einstiegslektüre
https://fhem.de/Heimautomatisierung-mit-fhem.pdf

### FHEM Wiki
https://wiki.fhem.de/wiki/Hauptseite

### FHEM Forum
https://forum.fhem.de/

