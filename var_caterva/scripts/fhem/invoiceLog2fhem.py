#!/usr/bin/python3

# Parameter: Datum im Format JJJJ-MM-DD

# Lese invoiceLog.csv fuer den Tag 'Parameter' und erzeuge eine Text Datei mit den 
# Werten fuer alle Kennzahlen. Pro Minute nur ein Wert.

import sys
import csv

if(len(sys.argv)<=1):
  print("Es wurden keine Parameter übergeben.")
else:
  parameterDatum = str(sys.argv[1:])[2:-2]
  # Dateiname invoiceLog
  csv_filename = '/var/caterva/logs/invoiceLog.'
  csv_filename = csv_filename + parameterDatum + '.csv'
  # Dateiname FHEM Datei
  txt_filename = '/var/caterva/data/SoC-'
  txt_filename = txt_filename + parameterDatum + '.txt'


  with open(csv_filename)      as csvfile, \
       open(txt_filename, 'w') as txtout :
    # Leser fuer die CSV Datei   
    cr = csv.reader(csvfile, delimiter=';')

    # Wir wollen nur den ersten Wert pro Minute aus der invoiceLog Datei lesen
    lasttime='00:00'  # 0:00 Uhr [hh:mm]
  
  # Schleife über alle Zeilen der CSV-Datei
    for line in cr:
      try:
        # Konvertiere DD/MM/YYYY in YYYY-MM-DD
        date = line[1][6:10] + '-' + \
               line[1][3:5] + '-' + \
               line[1][0:2]   
        # 2. Spalte ab Zeichen 11 - nur die Stunden und Minuten
        time = line[1][11:16]  

      except:
        print('Syntaxfehler in CSV-Datei, die fehlerhafte Zeile lautet:')
        print(line)
  
      # Nur ein Eintrag pro Minute
      if lasttime == time:
        continue
      # Header Zeilen auslassen
      elif line[15] == 'SoC in %':
        continue
      else:
        lasttime = time

      # # Sammle Daten in Listen
      #   Zeit.append(time)
      #   StateOfCharge.append(SoC)
 
        # Ergaenze die Sekunden :00 
        datetime = date + '_' + time + ':00'
        
      # Schreibe in Datei 
        # Datum YYY-MM-DD_HH:MM:SS
        txtout.writelines('%s ' % (datetime))
        # Kennzahl: Wert Kennzahl: Wert Kennzahl: Wert
        txtout.writelines('Timestamp_in_ms: %s Control_Power_to_Battery_in_W: %s Battery_to_Control_Power_in_W: %s ' % (line[0], line[2], line[3])) 
        txtout.writelines('Deadband_recharge_in_W: %s Recharge_by_power_purchase_in_W: %s Discharge_by_power_sale_in_W: %s ' % (line[4], line[5], line[6])) 
        txtout.writelines('Grid_to_Household_in_W: %s Battery_to_Household_in_W: %s PV_to_Household_in_W: %s ' % (line[7], line[8], line[9])) 
        txtout.writelines('PV_to_Battery_in_W: %s PV_to_Grid_in_W: %s Load_resistor_in_W: %s ' % (line[10], line[11], line[12])) 
        txtout.writelines('PV_power_provision_in_W: %s Household_demand_in_W: %s SoC_in_Pct: %s ' % (line[13], line[14], line[15])) 
        txtout.writelines('Neg_Inverter_AC_power_in_W: %s Pos_Inverter_AC_power_in_W: %s Neg_Inverter_DC_power_in_W: %s ' % (line[16], line[17], line[18])) 
        txtout.writelines('Pos_Inverter_DC_power_in_W: %s ESS_counter_level_discharge_in_Wh: %s ESS_counter_level_charge_in_Wh: %s ' % (line[19], line[20], line[21])) 
        txtout.writelines('ESS_meter_reading_time-date: %s HH_counter_level_discharge_in_Wh: %s HH_counter_level_charge_in_Wh: %s ' % (line[22], line[23], line[24])) 
        txtout.writelines('HH_meter_reading_time-date: %s PV_counter_level_discharge_in_Wh: %s PV_counter_level_charge_in_Wh: %s ' % (line[25], line[26], line[27])) 
        txtout.writelines('PV_meter_reading_time-date: %s Frequency_in_Hz: %s Frequency_timestamp: %s ' % (line[28], line[29], line[30])) 
        txtout.writelines('PV+HH_counter_level_discharge_in_Wh: %s PV+HH_counter_level_charge_in_Wh: %s PV+HH_meter_reading_time-date: %s ' % (line[31], line[32], line[33])) 
        txtout.writelines('PBH_counter_level_in_Wh: %s PPB_counter_level_in_Wh: %s PPB+PBH_meter_reading_time-date: %s ' % (line[34], line[35], line[36])) 
        txtout.writelines('PRE_counter_level_in_Wh: %s PDI_counter_level_in_Wh: %s PRE+PDI_meter_reading_time-date: %s ' % (line[37], line[38], line[39])) 
        txtout.writelines('PFCRpos_counter_level_in_Wh: %s PFCRneg_counter_level_in_Wh: %s PFCRpos+PFCRneg_meter_reading_time-date: %s ' % (line[40], line[41], line[42])) 
        txtout.writelines('PFCR_as_measured_in_W: %s PFCRpos_scheduled_in_W: %s PFCRneg_scheduled_in_W: %s ' % (line[43], line[44], line[45])) 
        txtout.writelines('PFCR_start_in_ms: %s PFCR_duration_in_ms: %s Traded_power_in_W: %s ' % (line[46], line[47], line[48])) 
        txtout.writelines('Traded_power_start_in_ms: %s Traded_power_duration_in_ms: %s PGRD_as_measured_in_W: %s ' % (line[49], line[50], line[51])) 
        txtout.writelines('HHpa_in_Wh: %s PVpeak_in_W: %s PFRR_as_measured_in_W: %s ' % (line[52], line[53], line[54])) 
        txtout.writelines('PFRRpos_reserved_in_W: %s PFRRneg_reserved_in_W: %s PFRR_start_in_ms: %s ' % (line[55], line[56], line[57])) 
        txtout.writelines('PFRR_duration_in_ms: %s PFRRpos_counter_level_in_Wh: %s PFRRneg_counter_level_in_Wh: %s ' % (line[58], line[59], line[60])) 
        txtout.writelines('PFRRpos+PFRRneg_meter_reading_time-date: %s Cluster_positive_FCR_min_freq_in_Hz: %s Cluster_positive_FCR_max_freq_in_Hz: %s ' % (line[61], line[62], line[63])) 
        txtout.writelines('Cluster_positive_FCR_start_in_s: %s Cluster_negative_FCR_min_freq_in_Hz: %s Cluster_negative_FCR_max_freq_in_Hz: %s ' % (line[64], line[65], line[66])) 
        # Kennzahl: Wert Kennzahl: Wert Kennzahl: Wert\n
        txtout.writelines('Cluster_negative_FCR_start_in_s: %s PFCRpos_overfulfillment_setpoint_in_W: %s PFCRneg_overfulfillment_setpoint_in_W: %s\n' % (line[67], line[68], line[69])) 