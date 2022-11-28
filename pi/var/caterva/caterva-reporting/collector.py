import configparser
import subprocess
import sys
import re
import subprocess
import datetime
from prometheus_client import Gauge, CollectorRegistry, push_to_gateway
from prometheus_client.exposition import basic_auth_handler
from os import path
from pprint import pprint

version = "1.2.1"
privacyConsent = [
    "SN000",
    "SN000013",
    "SN000027",
    "SN000038",
    "SN000093",
    "SN000099",
    "SN000120",
    "SN000122",
    "SN000134",
    "SN000135",
    "SN000138",
    "SN000139",
    "SN000149",
    "SN000154",
    "SN000160",
    "SN000167",
    "SN000169",
    "SN000174",
    "SN000177",
    "SN000188",
    "SN000197",
    "SN000198",
    "SN000201",
    "SN000231"
]

# see https://github.com/ac-caterva/webserver-public/blob/main/pi/var/caterva/scripts/copy_log.sh
class LogLine:
    def __init__(self, parsedLogLine):
        try:
            self.date = parsedLogLine[0]
            self.socProzent = parsedLogLine[1]  # Ladezustand
            # self.householdWattGrid = parsedLogLine[2]
            # self.householdWattBattery = parsedLogLine[3]
            # self.householdWatt = parsedLogLine[4]
            self.batteryWatt = parsedLogLine[5]  # Einspeicherwert
            # self.gridWatt = parsedLogLine[6]
            self.pvPowerProvision = parsedLogLine[7]  # PVLeistung
            # self.householdDemandWatt = parsedLogLine[8]
            # self.pvPeakWatt = parsedLogLine[9]
            # self.loadResistorWatt = parsedLogLine[10]
            self.negInverterACPower = parsedLogLine[11]  # Ausspeichern
            # self.posInverterACPower = parsedLogLine[12]
            # self.negInverterDCPower = parsedLogLine[13]
            # self.posInverterDCPower = parsedLogLine[14]
            # self.pfcrWatt = parsedLogLine[15]
            # self.pfcrPosWatt = parsedLogLine[16]
            # self.pfcrNegWatt = parsedLogLine[17]
            # self.tradedPowerWatt = parsedLogLine[18]
            # self.pgrdWatt = parsedLogLine[19]
            # self.pfrrWatt = parsedLogLine[20]
            # self.pfrrPosWatt = parsedLogLine[21]
            # self.pfrrNegWatt = parsedLogLine[22]
            # self.pfcrPosWatt = parsedLogLine[23]
            # self.pfcrNegWatt = parsedLogLine[24]
            self.rechargeByPowerWatt = parsedLogLine[28]  # Zwangsnachladung
            self.avgLoad = parsedLogLine[47]  # Systemlast
        except IndexError:
            print("Oh no! Failed to parse logfile")
            raise


commandLookup = {
    # command: [localPropName, ssh/nc, remoteCommand]
    "uptime": ["uptime", "ssh", "awk '{print $1}' /proc/uptime"],
    "snValue": [
        "snValue",
        "ssh",
        "ls /home/admin/registry/out | grep 'SN' | grep '.key' | tail -n 1 | rev | cut -c5- | rev",
    ],
    "gen": [
        "gen",
        "ssh",
        "ls /home/admin/registry/out | grep 'gen' | awk '{print toupper($0)}' ",
    ],
    "batteryType": [
        "batteryType",
        "ssh",
        'if [ $(ls /home/admin/registry/out/gen1 1>/dev/null 2>&1 ; echo $?) -eq 0 ]; then echo "SAFT"; else cat /home/admin/registry/out/bmmType ;fi',
    ],
    "Reg_WarAlm": [
        "WarAlm",
        "nc",
        '(echo "SwDER/LLN0";echo "exit";) | netcat 192.168.0.222 1337 | grep "WarAlm" | grep -oP "[0-9]{32}"',
    ],
    "Reg_BusAlm": [
        "BusAlm",
        "nc",
        '(echo "SwDER/LLN0";echo "exit";) | netcat 192.168.0.222 1337 | grep "BusAlm" | grep -oP "[0-9]{32}"',
    ],
    "Reg_CcAlm": [
        "CcAlm",
        "nc",
        '(echo "SwDER/LLN0";echo "exit";) | netcat 192.168.0.222 1337 | grep "CcAlm"  | grep -oP "[0-9]{32}"',
    ],
    "Reg_InoAlm": [
        "InoAlm",
        "nc",
        '(echo "SwDER/LLN0";echo "exit";) | netcat 192.168.0.222 1337 | grep "InoAlm" | grep -oP "[0-9]{32}"',
    ],
    "Reg_MacAlm": [
        "MacAlm",
        "nc",
        '(echo "SwDER/LLN0";echo "exit";) | netcat 192.168.0.222 1337 | grep "MacAlm" | grep -oP "[0-9]{32}"',
    ],
    "Reg_SafAlm": [
        "SafAlm",
        "nc",
        '(echo "SwDER/LLN0";echo "exit";) | netcat 192.168.0.222 1337 | grep "SafAlm" | grep -oP "[0-9]{32}"',
    ],
    "Reg_Mod": [
        "Reg_Mod",
        "nc",
        '(echo "mod";echo "exit";) | netcat 192.168.0.222 1338',
    ],
    "InitSTVAl": [
        "InitSTVAl",
        "nc",
        '(echo "SwDER/LLN0";echo "exit";) | netcat 192.168.0.222 1337 | grep "Init.stVal" | grep -oP "[0-9]{3}.*"',
    ],
    "cs_steuerung_logline": [
        "cs_steuerung_logline",
        "ssh",
        "tail -n1 /home/admin/bin/CS_Steuerung.log",
    ],
    "cs_steuerung_cfg": [
        "cs_steuerung_cfg",
        "ssh",
        "if [ $(ls /home/admin/bin/CS_Steuerung.cfg 1>/dev/null 2>&1 ; echo $?) -eq 0 ]; then tail -n1 /home/admin/bin/CS_Steuerung.cfg; else echo '-1;-1;-1;-1;CS-Config nicht vorhanden'; fi;",
    ],
    "cs_steuerung_log": [
        "cs_steuerung_log",
        "ssh",
        "if [ $(ls /home/admin/bin/CS_Steuerung.log 1>/dev/null 2>&1 ; echo $?) -eq 0 ]; then tail -n1 /home/admin/bin/CS_Steuerung.log; else echo 'CS-Log nicht vorhanden'; fi;",
    ],
    "cs_steuerung_pid": [
        "cs_steuerung_pid",
        "ssh",
        "if [ $(ls /tmp/CS_Steuerung.pid 1>/dev/null 2>&1 ; echo $?) -eq 0 ]; then echo 'true'; else echo 'false'; fi;",
    ],
    "bo_pid": [
        "bo_pid",
        "ssh",
        "if [ $(ls /tmp/BusinessOptimum.pid>/dev/null 2>&1 ; echo $?) -eq 0 ]; then echo 'true'; else echo 'false'; fi;",
    ],
    "bo_cfg": [
        "bo_cfg",
        "ssh",
        "if [ $(ls /home/admin/bin/BusinessOptimum.config 1>/dev/null 2>&1 ; echo $?) -eq 0 ]; then tail -n1 /home/admin/bin/BusinessOptimum.config; else echo '-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;BO-Config nicht vorhanden'; fi;",
    ],
    "bo_log": [
        "bo_log",
        "ssh",
        "if [ $(ls /home/admin/bin/BusinessOptimum.log 1>/dev/null 2>&1 ; echo $?) -eq 0 ]; then tail -n1 /home/admin/bin/BusinessOptimum.log | cut -d'|' -f12 | sed -e 's/^[[:space:]]*//'; else echo 'BO-Log nicht vorhanden'; fi;",
    ],
}

catchedLines = {
    "uptime": 0.0,
    "snValue": "",
    "socProzent": 0.0,
    "gen": "",
    "batteryType": "",
    "statusFlags": {},
    "InitSTVAl": "",
}

# Quelle https://github.com/meschnigm/fhem/blob/master/FHEM/99_myUtils.pm
registerCodeWarAlm = [
    "WarAlm(0)  -  Kurzzeitige Inkonsistenz der Leistungsmessungen am internen EHZ und Wechselrichter-Alarm kann ignoriert werden.",
    "WarAlm(1)  -  Kurzzeitige Inkonsistenz der Leistungsvorgabe und Leistungsmessung am Wechselrichter-Alarm kann ignoriert werden.",
    "WarAlm(2)  -  Lastwiderstand kann im Moment nicht angeschaltet werden, da zu heiß-Keine Aktion nötig - Lastwiderstand regeneriert sich selbst.",
    "WarAlm(3)  -  Lastwiderstand kann im Moment nicht angeschaltet werden, da in Regnerationspahse-Keine Aktion nötig - Lastwiderstand regeneriert sich selbst.",
    "WarAlm(4)  -  Lastwiderstand wurde mit höherer Leistung eingestellt als dies die Betriebslogik angefordert hat.-Alarm kann ignoriert werden.",
    "WarAlm(5)  -  Lastwiderstand wurde mit niedrigerer Leistung eingestellt als dies die Betriebslogik angefordert hat.-Alarm kann ignoriert werden.",
    "WarAlm(6)  -  Es können kurzzeitig keine Werte aus dem HH Leistungsmesser gelesen werden-Alarm kann ignoriert werden.",
    "WarAlm(7)  -  Es können kurzzeitig keine Werte aus dem PV Leistungsmesser gelesen werden-Alarm kann ignoriert werden.",
    "WarAlm(8)  -  Es können kurzzeitig keine Werte aus dem internen ehz gelesen werden-Alarm kann ignoriert werden.",
    "WarAlm(9)  -  Es konnten kurzzeitig keine Werte aus dem Frequenzmessgerät gelesen werden!-Alarm kann ignoriert werden.",
    "WarAlm(10) -  Batterie hat einen niedrigen Ladestand. Baldige automatisierte Nachladung der Batterie aus dem Netz.-Alarm kann ignoriert werden.",
    "WarAlm(11) -  Unterschied in den Zellspannungen übertrifft 60 mV-Alarm kann ignoriert werden.",
    "WarAlm(12) -  Neg. Regelleistung, die dem ESS vom CC zugeteilt ist, kann im Anforderungsfall nicht geleistet werden-Alarm kann ignoriert werden.",
    "WarAlm(13) -  Pos. Regelleistung, die dem ESS vom CC zugeteilt ist, kann im Anforderungsfall nicht geleistet werden-Alarm kann ignoriert werden.",
    "WarAlm(14) -  nicht belegt",
    "WarAlm(15) -  Hohe PV-Pufferleistung-Alarm kann ignoriert werden.",
    "WarAlm(16) -  Kommunikation zwischen den beiden lokalen Steuergeräten ist kurzfristig unterbrochen-Alarm kann ignoriert werden.",
    "WarAlm(17) -  ESS hat keine Rückmeldung von der Leitstelle erhalten.-Alarm kann ignoriert werden.",
    "WarAlm(18) -  Lesen des externen EHZ ist fehlgeschlagen.-Alarm kann ignoriert werden.",
    "WarAlm(19) -  Im Moment erhält das ESS seine Frequenz vom Server-Alarm kann ignoriert werden.",
    "WarAlm(20) -  Wechselrichter sendet eine Fehlermeldung-Alarm kann ignoriert werden.",
    "WarAlm(21) -  Verbindungsqualität ESS / Leitstelle ist schlecht.",
    "WarAlm(22) -  Messung der Leistung am Hausanschluss nicht möglich, Messgerät nicht verfügbar!",
    "WarAlm(23) -  Messung der PV-Leistung nicht möglich, Messgerät nicht verfügbar!",
    "WarAlm(24) -  ESS hat keine Verbindung zum Frequenzserver.-Alarm kann ignoriert werden.",
    "WarAlm(25) -  PV-Pufferung ist deaktiviert.-Alarm kann ignoriert werden.",
    "WarAlm(26) -  Lokales Steuergerät meldet eine Warnung.-Alarm kann ignoriert werden.",
    "WarAlm(27) -  Batterie Steuergerät (BMM) meldet eine Warnung.-Alarm kann ignoriert werden.",
    "WarAlm(28) -  nicht belegt",
    "WarAlm(29) -  nicht belegt",
    "WarAlm(30) -  nicht belegt",
    "WarAlm(31) -  nicht belegt",
]

registerCodeBusAlm = [
    "BusAlm(0)  -  Keine Regelleistung möglich, da in Zwangsnachladung aufgrund niedrigem SOCs",
    "BusAlm(1)  -  Abweichung zwischen Soll- und Istleistung, Leistung eingeschränkt.",
    "BusAlm(2)  -  Systemleistung maximal, Abweichungen möglich!",
    "BusAlm(3)  -  Ausfall der Frequenzmessung!",
    "BusAlm(4)  -  ESS hat keine Rückmeldung von der Leitstelle erhalten.",
    "BusAlm(5)  -  nicht belegt",
    "BusAlm(6)  -  ESS erbringt keine Regelleistung!",
    "BusAlm(7)  -  ESS ist im Inselnetzbetrieb!",
    "BusAlm(8)  -  Parameter der Betriebslogik sind nicht plausibel",
    "BusAlm(9)  -  ESS wird auf neutralen Ladestand gebracht",
    "BusAlm(10) -  Leistungstest ist geplant",
    "BusAlm(11) -  Leistungstest wird durchgeführt",
    "BusAlm(12) -  nicht belegt",
    "BusAlm(13) -  nicht belegt",
    "BusAlm(14) -  nicht belegt",
    "BusAlm(15) -  nicht belegt",
    "BusAlm(16) -  nicht belegt",
    "BusAlm(17) -  nicht belegt",
    "BusAlm(18) -  nicht belegt",
    "BusAlm(19) -  nicht belegt",
    "BusAlm(20) -  nicht belegt",
    "BusAlm(21) -  nicht belegt",
    "BusAlm(22) -  nicht belegt",
    "BusAlm(23) -  nicht belegt",
    "BusAlm(24) -  nicht belegt",
    "BusAlm(25) -  nicht belegt",
    "BusAlm(26) -  nicht belegt",
    "BusAlm(27) -  nicht belegt",
    "BusAlm(28) -  nicht belegt",
    "BusAlm(29) -  nicht belegt",
    "BusAlm(30) -  nicht belegt",
    "BusAlm(31) -  nicht belegt",
]

registerCodeCCAlm = [
    "CcAlm(0)  -  ESS ist nicht verfügbar!",
    "CcAlm(1)  -  Kapazität der Batterien reicht für positive Regelleistung nicht aus!",
    "CcAlm(2)  -  Kapazität der Batterien reicht für angeforderte Energieabgabe nicht aus!",
    "CcAlm(3)  -  Kapazität der Batterien reicht für angeforderte Energieaufnahme nicht aus!",
    "CcAlm(4)  -  Anzahl der ESS im Schwarm reicht für die Erbringung von maximaler Regelleistung nicht aus!",
    "CcAlm(5)  -  In der Zukunft wird ein kritischer Ladezustand des Schwarms erreicht!",
    "CcAlm(6)  -  In der Zukunft wird der Schwarm die angeforderte Leistung nicht erbringen können!",
    "CcAlm(7)  -  Ladestand der Batterien reicht für negative Regelleistung nicht aus!",
    "CcAlm(8)  -  Kritischer Zustand erreicht! Schwarm Ladezustand außerhalb Zielbereich!",
    "CcAlm(9)  -  Schwarm Ladezustand zu gering!",
    "CcAlm(10) -  Schwarm Ladezustand zu hoch!",
    "CcAlm(11) -  Schwarm Ladezustand zu gering! Kritischer Zustand erreicht!",
    "CcAlm(12) -  Schwarm Ladezustand zu hoch! Kritischer Zustand erreicht!",
    "CcAlm(13) -  nicht belegt",
    "CcAlm(14) -  nicht belegt",
    "CcAlm(15) -  nicht belegt",
    "CcAlm(16) -  nicht belegt",
    "CcAlm(17) -  nicht belegt",
    "CcAlm(18) -  nicht belegt",
    "CcAlm(19) -  nicht belegt",
    "CcAlm(20) -  nicht belegt",
    "CcAlm(21) -  nicht belegt",
    "CcAlm(22) -  nicht belegt",
    "CcAlm(23) -  nicht belegt",
    "CcAlm(24) -  nicht belegt",
    "CcAlm(25) -  nicht belegt",
    "CcAlm(26) -  nicht belegt",
    "CcAlm(27) -  nicht belegt",
    "CcAlm(28) -  nicht belegt",
    "CcAlm(29) -  nicht belegt",
    "CcAlm(30) -  nicht belegt",
    "CcAlm(31) -  nicht belegt",
]

registerCodeInoAlm = [
    "InoAlm(0)  -  Eingangsdaten für die Betriebslogik sind nicht plausibel",
    "InoAlm(1)  -  Rechenergebnis der Betriebslogik ist nicht plausibel",
    "InoAlm(2)  -  Fehler am Wechselrichter lässt sich nicht quittieren.-ESS deaktivieren!",
    "InoAlm(3)  -  Inkonsistenz der Leistungsvorgabe und Leisttungsmessung am Wechselrichter-ESS deaktivieren!",
    "InoAlm(4)  -  Wechselrichter ist abgeschaltet und sendet eine Fehlermeldung-ESS deaktivieren!",
    "InoAlm(5)  -  Inkonsistenz der Leistungsmessung am internen EHZ und am Wechselrichters-ESS deaktivieren!",
    "InoAlm(6)  -  Batterie ist in der Initialisierung und nicht in Betrieb-ESS nach zwei Minuten deaktivieren! !",
    "InoAlm(7)  -  Batterie ist nicht betriebsbereit, Batterieschütz ist offen-ESS deaktivieren!",
    "InoAlm(8)  -  Berechnung der Batterieleistungsgrenzen fehlgeschlagen evtl sind die gesendeten Batteriedaten nicht plausibel-ESS nach zwei Minuten deaktivieren!",
    "InoAlm(9)  -  Batteriedaten sind nicht plausibel oder werden nicht gesendet-ESS nach zwei Minuten deaktivieren!",
    "InoAlm(10) -  Batterie meldet einen Fehler-ESS deaktivieren!",
    "InoAlm(11) -  Lokales Steuergerät kann die Kommunikation zur Batterie nicht aufbauen.-ESS nach zwei Minuten deaktivieren!",
    "InoAlm(12) -  ESS ist in nicht funktionstüchtigem Systemzustand, Reset notwendig-ESS deaktivieren und nach 30 Sekunden wieder aktivieren!",
    "InoAlm(13) -  Fehler in der Messung der Leistungaufnahme des Haushalts!-ESS bei wiederholtem Auftreten deaktivieren! ",
    "InoAlm(14) -  Fehler in der Messung der PV-Leistung!-ESS bei wiederholtem Auftreten deaktivieren! ",
    "InoAlm(15) -  Berechnung der Phasenleistungsgrenzen des HA fehlgeschlagen evtl sind die gesendeten Messdaten (HH u. PV) nicht plausibel-ESS bei wiederholtem Auftreten deaktivieren! ",
    "InoAlm(16) -  HH oder PV Messdaten sind nicht plausibel oder werden nicht gesendet-ESS bei wiederholtem Auftreten deaktivieren!",
    "InoAlm(17) -  Überprüfung der Spannungen am Haushaltsanschluss fehlgeschlagen evtl sind die gesendeten Messdaten (HH) nicht plausibel-ESS bei wiederholtem Auftreten deaktivieren!",
    "InoAlm(18) -  HH Spannungswerte sind nicht plausibel oder werden nicht gesendet-ESS bei wiederholtem Auftreten deaktivieren!",
    "InoAlm(19) -  Kommunikation zwischen den beiden lokalen Steuergeräten ist unterbrochen-ESS bei wiederholtem Auftreten deaktivieren!",
    "InoAlm(20) -  Messung des Haushaltsverbrauchs nicht möglich!-ESS bei wiederholtem Auftreten deaktivieren!",
    "InoAlm(21) -  Messung der PV-Leistung nicht möglich!-ESS bei wiederholtem Auftreten deaktivieren!",
    "InoAlm(22) -  Batterie ist nicht in Betrieb da im Energiesparmodus",
    "InoAlm(23) -  Steuerungssoftware versagt-ESS deaktivieren!",
    "InoAlm(24) -  Anlagenschutz versagt-ESS deaktivieren!",
    "InoAlm(25) -  Initialisierung des Stromzählers des ESS ist fehlgeschlagen.-ESS bei wiederholtem Auftreten deaktivieren!",
    "InoAlm(26) -  Batteriedaten lassen keine Lade- oder Entlade-Leistung zu.",
    "InoAlm(27) -  Wechselrichterdaten lassen keine Lade- oder Entleistung zu. ",
    "InoAlm(28) -  Die Steuerungssoftware reagiert nicht",
    "InoAlm(29) -  Lokale Steuerung meldet einen Systemfehler-ESS deaktivieren!",
    "InoAlm(30) -  Die Wechselrichterüberwachung hat einen Fehler festgestellt-ESS deaktivieren!",
    "InoAlm(31) -  1-nicht belegt",
]

registerCodeMacAlm = [
    "MacAlm(0)  -  Selbsttest des Rauchmelders fehlgeschlagen - Wartungsprozess anstoßen!",
    "MacAlm(1)  -  Batterie des ESS verlangt nach einem Self-Test - Wartungsprozess anstoßen!",
    "MacAlm(2)  -  Fehler in der Summenmessung PV + Haushalt - Keine Aktion nötig.",
    "MacAlm(3)  -  nicht belegt",
    "MacAlm(4)  -  Summenmessung PV + Haushalt nicht möglich, ext. Messgerät nicht verfügbar - Keine Aktion nötig.",
    "MacAlm(5)  -  Unterschied in den Zellspannungen übertrifft 120 mV - Keine Aktion nötig.",
    "MacAlm(6)  -  Primärregelenergie wird nicht gezählt - Wartungsprozess anstoßen!",
    "MacAlm(7)  -  Eigenverbrauchserhöhung wird nicht gezählt - Wartungsprozess anstoßen!",
    "MacAlm(8)  -  Fahrplangeschäfte werden nicht gezählt - Wartungsprozess anstoßen!",
    "MacAlm(9)  -  Angefragter Doppelhöcker kann nicht ausgeführt werden - Sollte gerade gar kein Doppelhöcker gefahren werden: Wartungsprozess anstoßen!",
    "MacAlm(10) -  Lokale Frequenzmessung nicht möglich, Messgerät nicht verfügbar! - Bei wiederholtem Auftreten Caterva in Übergabe benachrichtigen!",
    "MacAlm(11) -  Lastwiderstand nicht einsatzbereit wegen ungültiger Messwerte - Bei wiederholtem Auftreten Caterva in Übergabe benachrichtigen!",
    "MacAlm(12) -  Soft Asset Protection ist abgeschaltet. - System sofort deaktivieren - Bei wiederholtem Auftreten Caterva in Übergabe benachrichtigen!",
    "MacAlm(13) -  Lastwiderstand nicht einsatzbereit wegen ungültiger Messwerte - Bei wiederholtem Auftreten Caterva in Übergabe benachrichtigen!",
    "MacAlm(14) -  Datenspeicher fast voll - Wartungsprozess anstoßen!",
    "MacAlm(15) -  Die Vorladung des Zwischenkreises ist fehlgeschlagen - Wartungsprozess anstoßen!",
    "MacAlm(16) -  Die Frequenzmessung des ESS weicht von der Frequenzmessung des Servers ab. - Bei längerem Auftreten: Wartungsprozess anstoßen!",
    "MacAlm(17) -  Fehler im Datensammler für die Endkunden-App - Wartungsprozess anstoßen!",
    "MacAlm(18) -  Fehler bei der Durchführung des Selbsttests - Wartungsprozess anstoßen!",
    "MacAlm(19) -  Sekundärregelenergie wird nicht gezählt - Wartungsprozess anstoßen!",
    "MacAlm(20) -  ESS führt eine (u.Ust. längere) geplante Wartungsoperation durch. - Keine Aktion nötig. ESS bitte nicht deaktivieren.",
    "MacAlm(21) -  nicht belegt",
    "MacAlm(22) -  nicht belegt",
    "MacAlm(23) -  nicht belegt",
    "MacAlm(24) -  nicht belegt",
    "MacAlm(25) -  nicht belegt",
    "MacAlm(26) -  nicht belegt",
    "MacAlm(27) -  nicht belegt",
    "MacAlm(28) -  nicht belegt",
    "MacAlm(29) -  nicht belegt",
    "MacAlm(30) -  nicht belegt",
    "MacAlm(31) -  nicht belegt",
]

registerCodeSafAlm = [
    "SafAlm(0)  -  Tür ist nicht verschlossen! - ESS deaktivieren! Erst nach Klärung quittieren!",
    "SafAlm(1)  -  Not-Aus vor Ort gedrückt oder automatisch ausgelöst (Ausgelöst durch andere rot/schwarze Alarme oder auch durch Stromausfall möglich) - Besitzer anfragen! Auf weitere Alarme achten! Erst nach Klärung quittieren!",
    "SafAlm(2)  -  Überflutungsalarm oder Überhitzung! - Erst nach Klärung quittieren! ",
    "SafAlm(3)  -  Rauchalarm! - ESS deaktivieren! Feuerwehr benachrichtigen! ",
    "SafAlm(4)  -  Luftfeuchtigkeit überschreitet Grenzwert - Besitzer anfragen! Nach Klärung und Lösung durch Besitzer quittieren! ",
    "SafAlm(5)  -  Netzausfall am ESS! Netzparameter außerhalb der Regelwerte",
    "SafAlm(6)  -  Übertemperatur im Elektronikschrank oder am Trafo! - Temperatur des ESS überprüfen! Bei >55°C ESS deaktivieren",
    "SafAlm(7)  -  Übertemperatur Lastwiderstand! - Temperatur des Lastwiderstands am ESS überprüfen! Bei >55°C ESS deaktivieren",
    "SafAlm(8)  -  Lastwiderstand lehnt aufgrund von Sicherheitsanforderungen Leistungsanforderung ab!",
    "SafAlm(9)  -  Entweder ist der Temperatursensor im Lastwiderstandsschrank oder der Lastwiderstand defekt - Temperatur des Lastwiderstands am ESS überprüfen! Bei >55°C ESS deaktivieren ",
    "SafAlm(10) -  Temperatur im Lastwiderstandsscharnk erhöht sich zu schnell - Temperatur am Lastwiderstand (STMP/Tmp) überprüfen! Bei >90°C ESS deaktivieren und Caterva in Übergabe benachrichtigen!",
    "SafAlm(11) -  Test des Vorladeschützes fehlegschlagen. Gefahr, dass Schütz verklebt ist - ESS deaktivieren.",
    "SafAlm(12) -  Sebststest der Batterie fehlegschlagen. Gefahr, dass BMM-Schütz verklebt ist - ESS deaktivieren.",
    "SafAlm(13) -  Inselnetzschütz Rückmeldung falsch. Gefahr, dass das Schütz verklebt ist! - ESS deaktivieren.",
    "SafAlm(14) -  ",
    "SafAlm(15) -  ",
    "SafAlm(16) -  ",
    "SafAlm(17) -  ",
    "SafAlm(18) -  ",
    "SafAlm(19) -  ",
    "SafAlm(20) -  ",
    "SafAlm(21) -  ",
    "SafAlm(22) -  ",
    "SafAlm(23) -  ",
    "SafAlm(24) -  ",
    "SafAlm(25) -  ",
    "SafAlm(26) -  ",
    "SafAlm(27) -  ",
    "SafAlm(28) -  ",
    "SafAlm(29) -  ",
    "SafAlm(30) -  ",
    "SafAlm(31) -  ",
]


def main():
    print("starting caterva-collector in version " + version)
    debugMode = False
    if path.exists("sample-data"):
        if len(sys.argv) >= 2:
            print("second commandline argument detected. ignoring debug-mode.")
            debugMode = False
        else:
            print(
                "selected directory 'sample-data'. collector is now in debug mode and is using sample-data"
            )
            debugMode = True
    if debugMode:
        print("DEBUG-FLAG: " + str(debugMode))
    print("start collecting data")

    catchedLines = parseAllValues(debugMode)

    print("===================")
    print("collected entrys:")
    pprint(catchedLines)
    print("===================")

    if catchedLines["error"] == False:
        print("sending data to gateway..")

        registry = createCatervaMetrics(catchedLines)
        sendRegistry(registry)

        print("finshed. exiting..")
        print()
        print()
    else:
        if "snValue" in catchedLines and catchedLines["snValue"] != "":
            print("try to send error")

            registry = createCatervaMetrics(catchedLines)
            sendRegistry(registry)
            print("error was pushed for " + catchedLines["snValue"])
        else:
            print(
                "The SN value could also not be determined. Can therefore also not send a status to the server. No data has been sent"
            )
        sys.exit(-1)


def parseAllValues(debugMode):
    catchedLines["error"] = False
    catchedLines["scriptVersion"] = version
    try:
        logLine = parseCatervaLogLine(getCatervaLogLine(debugMode))

        # Other Parameter
        sn = getFileValue("snValue", debugMode)
        print("check privacy consent for sn " + sn)
        if sn not in privacyConsent:
            print("ABORT: " + sn + " has not underwriten the privacy consent!")
            catchedLines["error"] = "missing privacy consent"
            return catchedLines
        else:
            print(sn + " has a valid privacy consent")
        catchedLines["snValue"] = sn

        catchedLines["uptime"] = getFileValue("uptime", debugMode)
        catchedLines["socProzent"] = logLine.socProzent
        catchedLines["gen"] = getFileValue("gen", debugMode)
        catchedLines["batteryType"] = mapBatType(getFileValue("batteryType", debugMode))
        catchedLines["InitSTVAl"] = getFileValue("InitSTVAl", debugMode)

        if catchedLines["batteryType"] == "SAFT":
            print("Skipping BMM, since type is SAFT")
            catchedLines["reg_mod"] = {}
        else:
            print("Collecting BMM..")
            catchedLines["reg_mod"] = parseBMUTable(getFileValue("Reg_Mod", debugMode))

        # cs steuerung
        catchedLines["cs_steuerung_cfg"] = parseSteuerungCFG(
            getFileValue("cs_steuerung_cfg", debugMode)
        )
        catchedLines["cs_steuerung_log"] = getFileValue("cs_steuerung_log", debugMode)
        catchedLines["cs_steuerung_pid"] = mapPID(
            getFileValue("cs_steuerung_pid", debugMode)
        )
        if catchedLines["cs_steuerung_pid"] == 0:
            catchedLines["cs_steuerung_log"] = "CS-Steuerung läuft nicht (PID-File)"

        # bo
        catchedLines["bo_cfg"] = parseSteuerungCFG(getFileValue("bo_cfg", debugMode))
        catchedLines["bo_log"] = getFileValue("bo_log", debugMode)
        catchedLines["bo_pid"] = mapPID(getFileValue("bo_pid", debugMode))
        if catchedLines["bo_pid"] == 0:
            catchedLines["bo_log"] = "BO läuft nicht (PID-File)"
        else:
            catchedLines["bo_log"] = catchedLines["bo_log"]

        catchedLines["batteryWatt"] = logLine.batteryWatt
        catchedLines["negInverterACPower"] = logLine.negInverterACPower
        catchedLines["socProzent"] = logLine.socProzent
        catchedLines["rechargeByPowerWatt"] = logLine.rechargeByPowerWatt
        catchedLines["pvPowerProvision"] = logLine.pvPowerProvision
        catchedLines["avgLoad"] = logLine.avgLoad

        # Status-Flags
        catchedLines["statusFlags"]["WarAlm"] = getErrorCode(
            registerCodeWarAlm, getFileValue("Reg_WarAlm", debugMode)
        )
        catchedLines["statusFlags"]["BusAlm"] = getErrorCode(
            registerCodeBusAlm, getFileValue("Reg_BusAlm", debugMode)
        )
        catchedLines["statusFlags"]["CcAlm"] = getErrorCode(
            registerCodeCCAlm, getFileValue("Reg_CcAlm", debugMode)
        )
        catchedLines["statusFlags"]["InoAlm"] = getErrorCode(
            registerCodeInoAlm, getFileValue("Reg_InoAlm", debugMode)
        )
        catchedLines["statusFlags"]["MacAlm"] = getErrorCode(
            registerCodeMacAlm, getFileValue("Reg_MacAlm", debugMode)
        )
        catchedLines["statusFlags"]["SafAlm"] = getErrorCode(
            registerCodeSafAlm, getFileValue("Reg_SafAlm", debugMode)
        )

        print("successfully collected vars")
    except Exception as e:
        print(e)
        catchedLines["error"] = True
        catchedLines["scriptError"] = e

    return catchedLines


# Mappt die Übergebene Statuscode-Zeile in Registermeldungen
def getErrorCode(registerCodeMap, flag):
    # Loop backwards over flags
    codes = []
    for index, elem in enumerate(flag[::-1]):
        if elem == "1":
            try:
                codes.append(registerCodeMap[index])
            except IndexError:
                print(
                    "[WARNUNG] Konnte den Registerwert an der Stelle "
                    + (index)
                    + " nicht mappen."
                )
                print(registerCodeMap)
    return codes


def dumpMetricsWithLabel(registry):
    entrys = {}
    for metric in registry.collect():
        for s in metric.samples:
            entrys[s.name] = [s.value, s.labels]
    return entrys


def mapBatType(value):
    tmpValue = value.upper()
    if tmpValue.startswith("SYNERION"):
        return "SONY"
    return tmpValue


def sendRegistry(registry):
    print("===================")
    print("sending following metrics:")
    pprint(dumpMetricsWithLabel(registry))
    print("===================")

    push_to_gateway(
        "https://gateway.caterva.fuchs-informatik.de",
        job="caterva_collector_" + catchedLines["snValue"],
        registry=registry,
        handler=basicAuthHandler,
    )


def mapPID(value):
    if value == "true":
        return 1
    return 0


def parseSteuerungCFG(value):
    return re.split(";", value)


def parseCatervaLogLine(line):
    entrys = re.split(" [0-9]{0,2}: ", line)
    return LogLine(entrys)


def getCatervaLogLine(debugMode):
    now = datetime.datetime.now()
    fileHandle = (
        "/opt/fhem/log/ESS_Minutenwerte-"
        + str(now.year)
        + "-"
        + str(now.month).zfill(2)
        + ".log"
    )
    if debugMode:
        fileHandle = "sample-data/ess-logfile.txt"
    try:
        print("try to open " + fileHandle)
        fileHandle = open(fileHandle, "r")
        lineList = fileHandle.readlines()
        fileHandle.close()
    except FileNotFoundError:
        print(
            "Achtung: Datei '"
            + fileHandle
            + "' konnte nicht gefunden werden! Collector wird beendet!"
        )
        raise

    return lineList[-1]


def getFileValue(attribute, debugMode):
    configs = commandLookup[attribute]
    if debugMode:
        if hasattr(debugMode, "__getitem__"):
            override_value = debugMode[attribute]
            print("WARN: Override value '" + attribute + "'")
            return override_value
        if attribute == "Reg_Mod":
            txt = ""
            with open("sample-data/bmm-register", "r") as bmuFile:
                txt = bmuFile.read()
            return txt
        config = configparser.ConfigParser()
        config.read("sample-data/dummy-values.properties")
        return config.get("General", configs[0])
    else:
        if configs[1] == "ssh":
            ret = subprocess.run(
                ["ssh", "admin@caterva", configs[2]], capture_output=True
            )
            print(ret)
            stdout = ret.stdout.decode("ascii").rstrip()
            print(stdout)
            return stdout
        if configs[1] == "nc":
            ret = subprocess.run(configs[2], shell=True, capture_output=True)
            print(ret)
            stdout = ret.stdout.decode("ascii").rstrip()
            print(stdout)
            return stdout
        print("Achtung: Typ nicht gefunden")
        return "WARNUNG: Nicht gefunden"


def basicAuthHandler(url, method, timeout, headers, data):
    username = "caterva_gateway"
    password = "eCDX43Mms7E2P2x8Juf6uQWXZLZ3zG"
    return basic_auth_handler(url, method, timeout, headers, data, username, password)


def parseBMUTable(text):
    matchingPatterns = ["soc", "current", "avg-current", "max", "min", "capa", "rem"]
    data = {}
    for line in iter(text.splitlines()):
        for pattern in matchingPatterns:
            if pattern in line:
                linePatch = re.sub(" +", " ", line).split()
                typeBezeichnung = linePatch[0]
                if "[" in linePatch[1] or "a" in linePatch[1] or "e" in linePatch[1]:
                    del linePatch[1]
                    if "[" in linePatch[1]:
                        typeBezeichnung += linePatch[1]
                        del linePatch[1]
                typeBezeichnung = (
                    typeBezeichnung.replace(
                        "current", "Aktueller Stromtransfer (current)"
                    )
                    .replace(
                        "avg-current", "Durchschnittlicher Stromtransfer (avg-current)"
                    )
                    .replace("max[mV]", "Maximale Zellspannung (max collvol)")
                    .replace("min[mV]", "Minimale Zellspannung (min collvol)")
                    .replace("max[0.1K]", "Maximale Zelltemperatur (max celltmp)")
                    .replace("min[0.1K]", "Minimale Zelltemperatur (min celltmp)")
                    .replace("rem.[mAh]", "Verbleibende Zellkapazität (rem. capa)")
                    .replace("full[mAh]", "Vollständige Zellkapazität (full. capa)")
                    .replace("soc", "State of charge (soc)")
                )
                data[typeBezeichnung] = linePatch[1:]
    return data


def createCatervaMetrics(catchedLines):
    registry = CollectorRegistry()

    gaugeScriptError = Gauge(
        "caterva_scriptError", "Script Error", ["errorMsg"], registry=registry
    )
    gaugeScriptVersion = Gauge(
        "caterva_version", "Script Version", ["version"], registry=registry
    )
    gaugeScriptVersion.labels(version=catchedLines["scriptVersion"]).set(1)

    if "scriptError" in catchedLines and catchedLines["scriptError"] != "":
        gaugeScriptError.labels(errorMsg=catchedLines["scriptError"]).set(1)
    else:
        gaugeSoc = Gauge("caterva_soc", "SoC in Prozent", ["sn"], registry=registry)
        gaugeGen = Gauge(
            "caterva_gen", "Generation der Caterva", ["gen"], registry=registry
        )
        gaugeBatType = Gauge(
            "caterva_batteryType",
            "Typ des Batteriemanagementmoduls",
            ["type"],
            registry=registry,
        )
        gaugeFlags = Gauge(
            "caterva_flags",
            "Meldungen der Caterva",
            ["register", "flag"],
            registry=registry,
        )
        gaugeUptime = Gauge(
            "caterva_uptime", "Uptime in Minuten", ["sn"], registry=registry
        )
        gaugeInitSTVAL = Gauge(
            "caterva_initSTVAL", "Initvektor", ["initval"], registry=registry
        )
        gaugeBatteryWatt = Gauge(
            "caterva_batteryWatt", "Einspeichern", registry=registry
        )
        gaugeNegInverterACPower = Gauge(
            "caterva_negInverterACPower", "Ausspeichern", registry=registry
        )
        gaugeRechargeByPowerWatt = Gauge(
            "caterva_rechargeByPowerWatt", "Zwangsnachladung", registry=registry
        )
        gaugePvPowerProvision = Gauge(
            "caterva_pvPowerProvision", "PV-Leistung", registry=registry
        )
        gaugeAvgLoad = Gauge("caterva_avgLoad", "Systemlast", registry=registry)
        gaugeCSSteuerung = Gauge(
            "caterva_cssteuerung",
            "CS-Steuerung",
            [
                "socMax",
                "socCharge",
                "startEinspeichern",
                "starteAusspeichern",
                "autoBalancing",
                "status",
            ],
            registry=registry,
        )
        gaugeBO = Gauge(
            "caterva_bo",
            "Business Optium",
            [
                "p_in_W_chargeStandbyThreshold",
                "p_in_W_chargeStandbyThreshold_hyst",
                "p_in_W_dischargeStandbyThreshold",
                "p_in_W_dischargeStandbyThreshold_delay",
                "p_in_W_dischargeStandbyThreshold_hyst",
                "soc_max",
                "soc_charge",
                "soc_discharge",
                "soc_min",
                "soc_err",
                "counter_discharge_to_standby_max",
                "counter_charge_to_standby_max",
                "counter_standby_to_discharge_max",
                "loop_delay",
                "system_initialization",
                "ecs3_Configuration",
                "businessOptimum_BOS",
                "status",
            ],
            registry=registry,
        )
        gaugeBMU = Gauge(
            "caterva_bmu",
            "Wertetabelle BMU (nur GEN2)",
            ["type", "number"],
            registry=registry,
        )

        gaugeSoc.labels(sn=catchedLines["snValue"]).set(catchedLines["socProzent"])
        gaugeUptime.labels(sn=catchedLines["snValue"]).set(catchedLines["uptime"])
        gaugeGen.labels(gen=catchedLines["gen"]).set(1)
        gaugeBatType.labels(type=catchedLines["batteryType"]).set(1)
        gaugeInitSTVAL.labels(initval=catchedLines["InitSTVAl"]).set(1)
        gaugeBatteryWatt.set(catchedLines["batteryWatt"])
        gaugeNegInverterACPower.set(catchedLines["negInverterACPower"])
        gaugeRechargeByPowerWatt.set(catchedLines["rechargeByPowerWatt"])
        gaugePvPowerProvision.set(catchedLines["pvPowerProvision"])
        gaugeAvgLoad.set(catchedLines["avgLoad"])
        gaugeCSSteuerung.labels(
            socMax=catchedLines["cs_steuerung_cfg"][0],
            socCharge=catchedLines["cs_steuerung_cfg"][1],
            startEinspeichern=catchedLines["cs_steuerung_cfg"][2],
            starteAusspeichern=catchedLines["cs_steuerung_cfg"][3],
            autoBalancing=catchedLines["cs_steuerung_cfg"][4],
            status=catchedLines["cs_steuerung_log"],
        ).set(catchedLines["cs_steuerung_pid"])
        gaugeBO.labels(
            p_in_W_chargeStandbyThreshold=catchedLines["bo_cfg"][0],
            p_in_W_chargeStandbyThreshold_hyst=catchedLines["bo_cfg"][1],
            p_in_W_dischargeStandbyThreshold=catchedLines["bo_cfg"][2],
            p_in_W_dischargeStandbyThreshold_delay=catchedLines["bo_cfg"][3],
            p_in_W_dischargeStandbyThreshold_hyst=catchedLines["bo_cfg"][4],
            soc_max=catchedLines["bo_cfg"][5],
            soc_charge=catchedLines["bo_cfg"][6],
            soc_discharge=catchedLines["bo_cfg"][7],
            soc_min=catchedLines["bo_cfg"][8],
            soc_err=catchedLines["bo_cfg"][9],
            counter_discharge_to_standby_max=catchedLines["bo_cfg"][10],
            counter_charge_to_standby_max=catchedLines["bo_cfg"][11],
            counter_standby_to_discharge_max=catchedLines["bo_cfg"][12],
            loop_delay=catchedLines["bo_cfg"][13],
            system_initialization=catchedLines["bo_cfg"][14],
            ecs3_Configuration=catchedLines["bo_cfg"][15],
            businessOptimum_BOS=catchedLines["bo_cfg"][16],
            status=catchedLines["bo_log"],
        ).set(catchedLines["bo_pid"])

        # bmu
        for type in catchedLines["reg_mod"]:
            for index, number in enumerate(catchedLines["reg_mod"][type]):
                numberValue = index
                if index == 0:
                    numberValue = "BMU"
                gaugeBMU.labels(type=type, number=numberValue).set(number)

        # StatusFlags
        for register in catchedLines["statusFlags"]:
            for flag in catchedLines["statusFlags"][register]:
                gaugeFlags.labels(register=register, flag=flag).set(1)

    return registry


if __name__ == "__main__":
    main()
