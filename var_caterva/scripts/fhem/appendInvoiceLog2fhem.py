#!/usr/bin/python3


# 1. Lese /var/caterva/data/invoiceLog.diff.csv 
# 2. Wandle die Daten ins FHEM Format um 
#    Werte fuer die Kennzahlen - pro Minute nur ein Wert
#     - Beruecksichtige den letzten Eintrag im FHEM log
# 3. und haenge die Daten ans FHEM log an  

import sys
import csv
import time
from datetime import datetime
import os
import re
import subprocess

def checkSetWritePermission(filename):
  try:
      with open(filename, 'a') as f:
          pass
  except IOError as x:
      if x.errno == 13:
        commandChmodFile = 'sudo chmod 664 ' + filename + '; sync ; sync'
        os.popen(commandChmodFile)
        # Warte bis Daten gesynct sind
        time.sleep(3)
      else:
        print(filename, ': keine Berechtigung')


def getDatetimeOfLastLineInFile(filename, lastlineNumber, regex_obj_fhem_1min):
# Wenn FHEM Log schon da ist, ermittele Zeit des letzten Wertes in der Datei
  if lastlineNumber < 3:  # Abbruchkriterium fuer rekursiven Aufruf
    if os.path.isfile(filename):
      commandLastLineOfLogFile = 'tail -' + str(lastlineNumber) + ' ' + filename + ' | head -1' 
      stream = os.popen(commandLastLineOfLogFile)
      LogLastLine = stream.read()
      # Falls kein Datum gefunden wurde - Datei ist leer, dann setzte initiale Werte
      if not LogLastLine:
        lastDatetime = 1970, 1, 1, 0, 0, 0, 0, 0, 0
      else:
        # pruefe auf valide Werte
        match = regex_obj_fhem_1min.match(LogLastLine)
        if match == None:
          lastlineNumber += 1
          # rekursiver Aufruf 
          lastDatetime = getDatetimeOfLastLineInFile(filename, lastlineNumber, regex_obj_fhem_1min)
        # Liste mit den Feldern des Zeitstempels JJJJ MM TT HH MM SS 
        else:
          lastDatetime = int(float(LogLastLine[0:4])), int(float(LogLastLine[5:7])), int(float(LogLastLine[8:10])),\
                        int(float(LogLastLine[11:13])), int(float(LogLastLine[14:16])), int(float(LogLastLine[17:19])),\
                        0, 0, 0
    else:
      lastDatetime = 1970, 1, 1, 0, 0, 0, 0, 0, 0
      # Lege Datei an
      commandCreateFile = 'touch ' + filename + \
                          '; sudo chmod 664 ' + filename + \
                          '; sudo chown fhem:dialout ' + filename 
      os.popen(commandCreateFile)
      # Warte bis Daten gesynct sind
      time.sleep(3)
  else:
    lastDatetime = 1970, 1, 1, 0, 0, 0, 0, 0, 0
  return lastDatetime

def datetime1IsTimeInMinutesGEDatetime2(datetime1, timeInMinutes, datetime2):
  datetime1InSecs = time.mktime(datetime1) 
  datetime2InSecs = time.mktime(datetime2)
  datetime2InSecs = datetime2InSecs + timeInMinutes * 60
  
  if datetime1InSecs > datetime2InSecs:
    return True
  else:
    return False 

def getAverageLoadFromCaterva():
    load = subprocess.check_output(['/var/caterva/scripts/get_average_load.sh'])
    catervaAverageLoad = float(load[0:len(load)-1])
    return catervaAverageLoad


#######################
#        MAIN         #
#######################

actualDatetime = datetime.now() 
yearMonthOfActualDatetime = actualDatetime.strftime("%Y-%m") # 2020-03 (Maerz 2020)

# Dateiname invoiceLog.dif.csv
newValuesDirname = '/var/caterva/data/'
# newValuesDirname = '/home/pi/Git-Clones/unit_test/'
newValuesFilename = 'invoiceLog.diff.csv'
newValuesFilename = newValuesDirname + newValuesFilename
# regulaerer Ausdruck fuer eine Zeile der invoiceLog.dif.csv Datei
regexNewValuesLineCheck = "^\[\'\d{13}\', \'\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2}\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2}\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2}\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2}\', \'-?\d+\.\d+\', \'\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2}\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2}\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2}\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2}\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2}\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\', \'-?\d+\', \'-?\d+\.\d+\', \'-?\d+\', \'-?\d+\', \'-?\d+\.\d+\', \'-?\d+\', \'-?\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\', \'-?\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2}\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'-?\d+\', \'-?\d+\.\d+\', \'-?\d+\.\d+\', \'\'\]"
# Objekt fuer die regular Expression
regexObjNewValues = re.compile(regexNewValuesLineCheck)


# Dateiname FHEM Datei
fhemLog1MinDirname = '/opt/fhem/log/'
# fhemLog1MinDirname = '/home/pi/Git-Clones/unit_test/'
fhemLog1MinFilename = 'ESS_Minutenwerte-'
fhemLog1MinFilename = fhemLog1MinDirname + fhemLog1MinFilename + yearMonthOfActualDatetime + '.log'
# regulaerer Ausdruck fuer Datum am Anfang der Zeile
regexFhemLog1MinLineCheck = "^\d{4}-\d{2}-\d{2}_\d{2}:\d{2}:\d{2} "
# Objekt fuer die regular Expression
regexObjFhem1Min = re.compile(regexFhemLog1MinLineCheck)

# fhem_10min_filename = '/opt/fhem/log/ESS_10Minutenwerte-'
# fhem_10min_filename = fhem_10min_filename + yearMonthOfActualDatetime + '.log'

# Wenn FHEM Log schon da ist, ermittele Zeit des letzten Wertes in der Datei
last1MinuteDatetime = getDatetimeOfLastLineInFile(fhemLog1MinFilename, 1, regexObjFhem1Min)
# last10MinuteDatetime = getDatetimeOfLastLineInFile(fhem_10min_filename)

# Datei kann trotzdem nicht schreibbar sein
checkSetWritePermission(fhemLog1MinFilename)
# checkSetWritePermission(fhem_10min_filename)

catervaAverageLoad = getAverageLoadFromCaterva()

with open(newValuesFilename)      as csvfileNewValues, \
      open(fhemLog1MinFilename, 'a') as fhemLog1MinAppend:
      # open(fhem_10min_filename, 'a') as fhem_10min_append :
  # Leser fuer die CSV Datei   
  csv_readerNewValues = csv.reader(csvfileNewValues, delimiter=';')

# Schleife über alle Zeilen der CSV-Datei
  for lineOfNewValues in csv_readerNewValues:
      match = regexObjNewValues.match(str(lineOfNewValues))
      if match == None:
          continue
      try:
        # Liste mit den Feldern des Zeitstempels JJJJ MM TT HH MM SS
        NewValueDatetime = int(float(lineOfNewValues[1][6:10])), int(float(lineOfNewValues[1][3:5])), int(float(lineOfNewValues[1][0:2])),\
                      int(float(lineOfNewValues[1][11:13])), int(float(lineOfNewValues[1][14:16])), int(float(lineOfNewValues[1][17:19])),\
                      0, 0, 0
      except:
        print('Syntaxfehler in CSV-Datei, die fehlerhafte Zeile lautet:')
        print(lineOfNewValues)

      # Nur ein Eintrag pro Minute
      if datetime1IsTimeInMinutesGEDatetime2(NewValueDatetime, 1, last1MinuteDatetime):
        last1MinuteDatetime = NewValueDatetime

        # Konvertiere DD/MM/YYYY HH:MM:SS aus csv in YYYY-MM-DD_HH:MM:SS
        newValue_Date_Time = lineOfNewValues[1][6:10] + '-' + lineOfNewValues[1][3:5] + '-' + lineOfNewValues[1][0:2] + '_' + lineOfNewValues[1][11:19]    
        
        # Schreibe in Datei 
        # # fhemLog1MinAppend.writelines('Timestamp_in_ms: %s ' % (line[0])) 
        # Datum YYY-MM-DD_HH:MM:SS
        fhemLog1MinAppend.writelines('%s ' % (newValue_Date_Time))  # line[1] im Format YYYY-MM-DD
        # Kennzahl: Wert 
        # 3	SoC_in_Pct:	Ladestatus	%	1 min	15
        fhemLog1MinAppend.writelines('3: %d ' % (int(float(lineOfNewValues[15])))) 
        # 5	Grid_to_Household_in_W:	Netzbezug  [W]	Leistung	1 min	7
        fhemLog1MinAppend.writelines('5: %d ' % (int(float(lineOfNewValues[7])))) 
        # 7	Battery_to_Household_in_W:	Ausspeicherung  [W]	Leistung 1 min	8
        fhemLog1MinAppend.writelines('7: %d ' % (int(float(lineOfNewValues[8])))) 
        # 9	PV_to_Household_in_W:	Direktverbrauch [W]	Leistung	1 min	9
        fhemLog1MinAppend.writelines('9: %d ' % (int(float(lineOfNewValues[9])))) 
        # 11	PV_to_Battery_in_W:	Einspeicherung  [W]	Leistung	1 min	10
        fhemLog1MinAppend.writelines('11: %d ' % (int(float(lineOfNewValues[10])))) 
        # 13	PV_to_Grid_in_W:	Netzeinspeisung [W]	Leistung	1 min	11
        fhemLog1MinAppend.writelines('13: %d ' % (int(float(lineOfNewValues[11])))) 
        # 15	PV_power_provision_in_W:	PV-Leistung [W]	Leistung	1 min	13
        fhemLog1MinAppend.writelines('15: %d ' % (int(float(lineOfNewValues[13])))) 
        # 17	Household_demand_in_W:	Verbrauch [W]	Leistung	1 min	14
        fhemLog1MinAppend.writelines('17: %d ' % (int(float(lineOfNewValues[14])))) 
        # 19	PVpeak_in_W:		Leistung	1 min	53
        fhemLog1MinAppend.writelines('19: %d ' % (int(float(lineOfNewValues[53])))) 
        # 21	Load_resistor_in_W:		Leistung	1 min	12
        fhemLog1MinAppend.writelines('21: %d ' % (int(float(lineOfNewValues[12])))) 
        # 23	Neg_Inverter_AC_power_in_W:		Leistung	1 min	16
        fhemLog1MinAppend.writelines('23: %d ' % (int(float(lineOfNewValues[16])))) 
        # 25	Pos_Inverter_AC_power_in_W:		Leistung	1 min	17
        fhemLog1MinAppend.writelines('25: %d ' % (int(float(lineOfNewValues[17])))) 
        # 27	Neg_Inverter_DC_power_in_W:		Leistung	1 min	18
        fhemLog1MinAppend.writelines('27: %d ' % (int(float(lineOfNewValues[18])))) 
        # 29	Pos_Inverter_DC_power_in_W:		Leistung	1 min	19
        fhemLog1MinAppend.writelines('29: %d ' % (int(float(lineOfNewValues[19])))) 
        # 31	PFCR_as_measured_in_W:		Leistung	1 min	43
        fhemLog1MinAppend.writelines('31: %d ' % (int(float(lineOfNewValues[43])))) 
        # 33	PFCRpos_scheduled_in_W:		Leistung	1 min	44
        fhemLog1MinAppend.writelines('33: %d ' % (int(float(lineOfNewValues[44])))) 
        # 35	PFCRneg_scheduled_in_W:		Leistung	1 min	45
        fhemLog1MinAppend.writelines('35: %d ' % (int(float(lineOfNewValues[45])))) 
        # 37	Traded_power_in_W:		Leistung	1 min	48
        fhemLog1MinAppend.writelines('37: %d ' % (int(float(lineOfNewValues[48])))) 
        # 39	PGRD_as_measured_in_W:		Leistung	1 min	51
        fhemLog1MinAppend.writelines('39: %d ' % (int(float(lineOfNewValues[51])))) 
        # 41	PFRR_as_measured_in_W:		Leistung	1 min	54
        fhemLog1MinAppend.writelines('41: %d ' % (int(float(lineOfNewValues[54])))) 
        # 43	PFRRpos_reserved_in_W:		Leistung	1 min	55
        fhemLog1MinAppend.writelines('43: %d ' % (int(float(lineOfNewValues[55])))) 
        # 45	PFRRneg_reserved_in_W:		Leistung	1 min	56
        fhemLog1MinAppend.writelines('45: %d ' % (int(float(lineOfNewValues[56])))) 
        # 47	PFCRpos_overfulfillment_setpoint_in_W:		Leistung	1 min	68
        fhemLog1MinAppend.writelines('47: %d ' % (int(float(lineOfNewValues[68])))) 
        # 49	PFCRneg_overfulfillment_setpoint_in_W:		Leistung	1 min	69
        fhemLog1MinAppend.writelines('49: %d ' % (int(float(lineOfNewValues[69])))) 
        # 51	Control_Power_to_Battery_in_W:		Leistung	1 min	2
        fhemLog1MinAppend.writelines('51: %d ' % (int(float(lineOfNewValues[2])))) 
        # 53	Battery_to_Control_Power_in_W:		Leistung	1 min	3
        fhemLog1MinAppend.writelines('53: %d ' % (int(float(lineOfNewValues[3])))) 
        # 55	Deadband_recharge_in_W:		Leistung	1 min	4
        fhemLog1MinAppend.writelines('55: %d ' % (int(float(lineOfNewValues[4])))) 
        # 57	Recharge_by_power_purchase_in_W:		Leistung	1 min	5
        fhemLog1MinAppend.writelines('57: %d ' % (int(float(lineOfNewValues[5])))) 
        # 59	Discharge_by_power_sale_in_W:		Leistung	1 min	6
        fhemLog1MinAppend.writelines('59: %d ' % (int(float(lineOfNewValues[6])))) 
        # 61	ESS_counter_level_discharge_in_Wh:		Energie	10 min	20
        fhemLog1MinAppend.writelines('61: %d ' % (int(float(lineOfNewValues[20])))) 
        # 63	HH_counter_level_discharge_in_Wh:		Energie	10 min	23
        fhemLog1MinAppend.writelines('63: %d ' % (int(float(lineOfNewValues[23])))) 
        # 65	HH_counter_level_charge_in_Wh:		Energie	10 min	24
        fhemLog1MinAppend.writelines('65: %d ' % (int(float(lineOfNewValues[24])))) 
        # 67	PV_counter_level_discharge_in_Wh:		Energie	10 min	26
        fhemLog1MinAppend.writelines('67: %d ' % (int(float(lineOfNewValues[26])))) 
        # 69	ESS_counter_level_charge_in_Wh:		Energie	10 min	21
        fhemLog1MinAppend.writelines('69: %d ' % (int(float(lineOfNewValues[21])))) 
        # 71	PV_counter_level_charge_in_Wh:		Energie	10 min	27
        fhemLog1MinAppend.writelines('71: %d ' % (int(float(lineOfNewValues[27])))) 
        # 73	PV+HH_counter_level_discharge_in_Wh:		Energie	10 min	31
        fhemLog1MinAppend.writelines('73: %d ' % (int(float(lineOfNewValues[31])))) 
        # 75	PV+HH_counter_level_charge_in_Wh:		Energie	10 min	32
        fhemLog1MinAppend.writelines('75: %d ' % (int(float(lineOfNewValues[32])))) 
        # 77	PBH_counter_level_in_Wh:		Energie	10 min	34
        fhemLog1MinAppend.writelines('77: %d ' % (int(float(lineOfNewValues[24])))) 
        # 79	PPB_counter_level_in_Wh:		Energie	10 min	35
        fhemLog1MinAppend.writelines('79: %d ' % (int(float(lineOfNewValues[35])))) 
        # 81	PRE_counter_level_in_Wh:		Energie	10 min	37
        fhemLog1MinAppend.writelines('81: %d ' % (int(float(lineOfNewValues[37])))) 
        # 83	PDI_counter_level_in_Wh:		Energie	10 min	38
        fhemLog1MinAppend.writelines('83: %d ' % (int(float(lineOfNewValues[38])))) 
        # 85	PFCRpos_counter_level_in_Wh:		Energie	10 min	40
        fhemLog1MinAppend.writelines('85: %d ' % (int(float(lineOfNewValues[40])))) 
        # 87	PFCRneg_counter_level_in_Wh:		Energie	10 min	41
        fhemLog1MinAppend.writelines('87: %d ' % (int(float(lineOfNewValues[41])))) 
        # 89	HHpa_in_Wh:		Energie	10 min	52
        fhemLog1MinAppend.writelines('89: %d ' % (int(float(lineOfNewValues[52])))) 
        # 91	PFRRpos_counter_level_in_Wh:		Energie	10 min	59
        fhemLog1MinAppend.writelines('91: %d ' % (int(float(lineOfNewValues[59])))) 
        # 93	PFRRneg_counter_level_in_Wh:		Energie	10 min	60
        fhemLog1MinAppend.writelines('93: %d ' % (int(float(lineOfNewValues[60])))) 
        # 95	Average Load der Caterva per SSH Script alle 5 Minuten
        fhemLog1MinAppend.writelines('95: %f ' % (float(catervaAverageLoad))) 

        # Zeilenende
        fhemLog1MinAppend.writelines('\n') 

csvfileNewValues.close()
fhemLog1MinAppend.close()
# fhem_10min_append.close()
