# Hausdienlicher Betrieb für Dummies - wie mich

## Vorwort

Nach nahezu zwei Jahren, läuft seit kurzer Zeit mein Speicher wieder. Dies wäre mir als ahnungslosem Menschen in Sachen Elektro-, Computertechnik etc., ohne die selbstlose Hilfe des Technik-Teams, niemals gelungen.
Bei den Recherchen nach den nötigen Schritten zur Wiederinbetriebnahme habe ich viel Zeit damit verbracht die richtigen Maßnahmen im Discord ꙮ***Discord ist ein Onlinedienst auf dem der Austausch unter den Community-Mitgliedern stattfindet***ꙮ zu finden. 

Meine auch danach noch vorhandene Unwissenheit bei den Maßnahmen des Technik-Teams hat deren Mitglieder viel Zeit gekostet um mich auf den aktuellen und nötigen Stand zu bringen - was noch viel schlimmer ist, da diese Leute eh schon viel Zeit in die Hilfe für mich gesteckt haben.

Dies hat mich dazu gebracht mal zusammenzufassen, was ich als Laie mittlerweile weiß, bzw. glaube zu wissen. Diese Zusammenfassung möchte ich der Community zur Verfügung zu stellen. Damit traut sich vielleicht der/die Ein oder Andere daran die Arbeiten in Angriff zu nehmen. 

Einige Punkte sind noch nicht, oder noch unvollständig erarbeitet. Diese Passagen sind in 2 Fragezeichen (??Text??) gefügt. Ergänzungen und Änderungswünsche nehme ich gerne auf.

Anton Köszegi, SN096

## Erste Schritte / Voraussetzungen
-	Bestellung und Einbau einer **RasberryPi** (Pi) ꙮ***Mini-Computer***ꙮ 
    - Damit man von außen auf die Caterva-Sonne (CS)  zugreifen kann, benötigt man einen kleinen Computer in der CS auf den man mit einer Remotedesktop-Verbindung ꙮ***Start > Einstellungen > System > Remotedesktop***ꙮ vom einem anderen Computer aus zugreifen kann. Dazu benötigt es eine LAN- oder WLAN-Verbindung.
    - Die nötigen Komponenten, die dazu bestellt werden müssen finden sich im Discord-Ordner **#pi-bestellung!** Dort sind zwei Beschreibungen angepinnt:![grafik](https://user-images.githubusercontent.com/82029620/113884540-56752e80-97bf-11eb-8fdc-66308bdfced7.png)
  *`RasberryPi4LAN_WLAN.pdf`* und *`RasberryPi4LAN_LAN.pdf`* 
    - Die ebenso benötigte SD-Karte wird mit frankierten Rückumschlag (Größe einer Postkarte mit 80 Cent frankiert) und dem unterschriebenen Haftungsausschluss - zu finden im Discord-Ordner **#protokolle-telefonkonferenz!** *`Haftungsausschluss.pdf`* (31.03.2020) - bestellt bei: **Anja Christian; Großwaldstr. 113; 66265 Heusweiler**
    - Für den Zusammenbau der Pi gibt es im Ordner **#sd-karte-in-betrieb-nehmen!** (12.04.2020) zwei Anleitungen:  
*`Anleitung_fuer_die_Inbetriebnahme_LAN_LAN_v0.02.pdf`*, oder
*`Anleitung_fuer_die_Inbetriebnahme_LAN_WAN_v0.02.pdf`*
    - Nach dem Zusammenbau eine persönliche Nachricht an SN245 Anja Christian im Discord senden. ꙮ***dazu mit der rechten Maustaste auf die Person klicken und mit der linken Maustaste „Nachricht“ auswählen***ꙮ um einen Termin für die Inbetriebnahme der SD Karte und das Einrichten der Verbindung zwischen der Pi und der CS  zu vereinbaren.
    - Auf dem eigenen PC **AnyDesk** ꙮ***Fernwartungs-Software***ꙮ installieren. Diese Software kann man z. B. hier downloaden: (https://anydesk.com/de/downloads/windows) 
    - Die CS muss soweit angeschlossen sein, dass sie eingeschaltet werden kann.
Der Speicherbesitzer muss wissen, wie er die CS wieder in Betrieb nehmen kann: Welche Sicherungen und evtl. Steckverbindungen wieder eingeschaltet und verbunden werden müssen. ꙮ***bis hier hin eigenständige Durchführung der beschriebenen Schritte***ꙮ 

-	Unterschiedliche CS-Konfigurationen
    - Es gibt unterschiedliche Generationen von Speichern, was bei den folgenden Schritten zu unterschiedlichen Maßnahmen führt.
        - Generation 0 (CS 1502 bis ≈ SN070)
        - Generation 1 (CS 1511 bis ≈ SN130)
        - Generation 2 (CS 1705 bis ≈ SN250)

-   Umbau auf Messkonzept FNN 5.5.1
    - Je nach Generation der CS sind unterschiedliche Messkonzepte installiert. Für den hausdienlichen Betrieb muss das Messkonzept 5.5.1 (Speicher im Verbrauchspfad) installiert sein. Dazu wird bei verschiedenen CS ein ECS 3 Zähler benötigt, bei anderen ist dieser Zähler schon eingebaut.  Der Zähler mit der Bezeichnung KE P80 MID MOD-BUS kann bei der Firma K´electric in Bayreuth zu besonderen Konditionen bestellt werden. Nähere Beschreibung in **#wiederinbetriebnahme!**  Dort ist folgende Datei angepinnt:![grafik](https://user-images.githubusercontent.com/82029620/113884540-56752e80-97bf-11eb-8fdc-66308bdfced7.png)   *`Roadmap_und_Installationsmeilensteine_fur_community_I_III-4_230520.pdf`*
Darin ist die Vorgehensweise, Schaltpläne und der Umbau und die Inbetriebnahme durch einen Elektriker mit VNB Zulassung beschrieben.

-	Anpassen der CS-Konfiguration auf das neue Messkonzept
    - Sind alle oben beschriebenen Voraussetzungen erfüllt und der Eintrag in die Doodle-Liste (https://doodle.com/poll/p9knyeaevkapntna?utm_source=poll&utm_medium=link)   erfolgt, kann das Technik-Team den Speicher an das neue Messkonzept anpassen. Zusammengefasste, detaillierte Informationen zur Inbetriebnahme und Aktualisierung hier: (https://github.com/ac-caterva/webserver-public/blob/main/README.md)
    - Dazu wird sich ein Mitglied des Technik-Teams beim Speicherbesitzer melden und gemeinsam mit dem Besitzer der CS die Anlage analysieren. Im Discord unter **#sd-karte-in-betrieb-nehmen!** ![grafik](https://user-images.githubusercontent.com/82029620/113884540-56752e80-97bf-11eb-8fdc-66308bdfced7.png) finden sich weitere Erläuterungen
    - Eventuell ist bei unterschiedlichem oder zu niedrigem Ladezustand von Batterien ein vorheriges Laden nötig. Nähere Informationen z.B. für Saft-Akkus können direkt beim Technik-Team angefragt werden.
 
## Speicher läuft
-   Sichtbar machen der Erträge mit **FHEM** ꙮ***Freundliche Hausautomation und Energie-Messung***ꙮ
    - Über einen Internet-Browser kann FHEM aufgerufen werden. Dazu die **IP-Adresse der Pi** gefolgt von **:8083** eingeben. ꙮ***die IP-Adresse der Pi kann man über den Router unter dem Namen raspberrypi herausfinden***ꙮ z.B.: 192.168.177.40:8083. Im dann erscheinenden Anmeldefenster bei Benutzername und Passwort **pi** eingeben. Weitere Informationen können hier abgerufen werden: (https://github.com/meschnigm/fhem/blob/master/README.md)
    - Sollten die Messwerte nicht korrekt dargestellt werden, kann es z. B. daran liegen, dass ein zusätzlicher PV-Zähler eingebaut werden muss. Ohne diesen werden die Werte von PV und Hausstrom als ein Wert angezeigt. Einige Wechselrichter haben diesen Zähler schon verbaut. ??Ein solcher Zähler hat die Bezeichnung: ECS3-80 BM modbus??
    - Optimiert werden kann der Betrieb des Speichers mit dem im FHEM enthaltenen **Business Optimum** (BO) [Beta-Version]. Eine Beschreibung befindet sich in der oben erwähnten FHEM-Beschreibung. Die An- und Ausschaltpunkte können über Schieberegler an die eigenen Bedürfnisse angepasst und über *`lastloglines_BO`* abgefragt werden.
    - Sollten die eingestellten Werte nicht ausgeführt werden, kann das daran liegen, dass die Werte außerhalb des definierten Bereiches liegen. Die akzeptierten Bereiche werden in *`lastloglines_BO`* sichtbar und müssen gegebenenfalls angepasst werden.
 
-   Überwachung der Anlage
    - Die Anlage muss vom Besitzer selbständig überwacht werden. Bei Fehlfunktionen diese dokumentieren und versuchen, ob durch einen Neustart die richtige Funktion wieder hergestellt werden kann. Ansonsten eine (kostenpflichtige) Nachfrage beim Technik-Team starten.

-   Voraussetzungen für Erfassung der Erträge
    - ??Darstellung von unterschiedlichen Konfigurationen??
    - ??Mögliche Erweiterungen mit Produktbeschreibung und Schaltplänen??

-   Berechnung von Verbrauch und Wirkungsgrad
    - Die Erfassung der Tages-Zählerwerte (Delta-Werte) lässt sich mit dem Befehl 
*`<IP:RASPERRY>:8083/fhem/FileLog_logWrapper&dev=Zaehler_Monatswerte&type=text&file=Zaehler_Monatswerte-2021-03.log`*                                           abrufen. ꙮ***in diesem Beispiel die Werte für März 2021. Was dann beispielsweise so aussieht***ꙮ  ![grafik](https://user-images.githubusercontent.com/82029620/113899400-11f08f80-97cd-11eb-9db0-91586d4e406d.png)
    - Die Bedeutung der wichtigsten Zählernummern:</br>
        07: Verbrauch (V) = NB+AS (Gesamtverbrauch)</br>
        13: PV-Ertrag (Energie E) - Direktverbrauch</br>
        19: Ausspeicherung (AS)</br>
        21: Einspeicherung (ES)</br>
        35: Netzeinspeisung (NE)</br>
        37: PV direkt vom Dach (DV) (Direktverbrauch)</br>
        39: Netzbezug (NB)</br>
     - Den Wirkungsgrad der CS kann man am einfachsten mit einer kleinen Excel-Tabelle berechnen. Dazu sind 2 Werte Voraussetzung, die man in BO bei *`Wertetabellen`* findet. *`ESS_Einspeicherung`* (ES) und *`ESS_Ausspeicherung`* (AS). Den Zählerstand dieser beiden Werte, in etwa zu gleicher Zeit und Speicherladung ablesen, die Delta-Werte (∆) ermitteln und danach **∆AS / ∆ES** ausführen. Das kann dann in etwa so aussehen:</br> 
![grafik](https://user-images.githubusercontent.com/82029620/113901252-f7b7b100-97ce-11eb-8709-6defb4b19e48.png)

-   Optimierung des Speichers
    - ??Anpassung an verschiedene Verbrauchssituationen??
    - ??Anpassung an die Jahreszeit??

-   Fehlfunktionen
    - ??unerwünschte Auswirkungen??
    - ??mögliche Fehlerquellen und Lösungsmöglichkeiten??
