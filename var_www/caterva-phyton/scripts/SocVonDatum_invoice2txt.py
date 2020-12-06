#!/usr/bin/python3

# Parameter: Datum im Format JJJJ-MM-DD

# Lese invoiceLog.csv fuer den Tag 'Parameter' und erzeuge eine Text Datei mit den 
# Werten fuer SoC (State of Charge). Pro Minute nur ein Wert.

import sys
import csv

if(len(sys.argv)<=1):
  print("Es wurden keine Parameter übergeben.")
else:
  x = str(sys.argv[1:])[2:-2]
  csv_filename = '/var/caterva/logs/invoiceLog.'
  csv_filename = csv_filename + x + '.csv'
  # print(csv_filename)
  txt_filename = '/var/caterva/data/SoC-'
  txt_filename = txt_filename + x + '.txt'
  # print(txt_filename)

  with open(csv_filename)      as csvfile, \
       open(txt_filename, 'w') as txtout :
    # Leser fuer die CSV Datei   
    cr = csv.reader(csvfile, delimiter=';')

    lasttime='00:00'  # 0:00 Uhr [hh:mm]
  
  # Schleife über alle Zeilen der CSV-Datei
    for line in cr:
      try:
        # Konvertiere DD/MM/YYYY in YYYY-MM-DD
        date = line[1][6:10] + '-' + \
               line[1][3:5] + '-' + \
               line[1][0:2]   
        time = line[1][11:16]  # 2. Spalte ab Zeichen 11 - nur die Stunden und Minuten
        SoC = line[15]
      except:
        print('Syntaxfehler in CSV-Datei, die fehlerhafte Zeile lautet:')
        print(line)
  
      # Nur ein Eintrag pro Minute
      if lasttime == time:
        continue
      # Header Zeilen auslassen
      elif SoC == 'SoC in %':
        continue
      else:
        lasttime = time

      # # Sammle Daten in Listen
      #   Zeit.append(time)
      #   StateOfCharge.append(SoC)

      # Schreibe in Datei  
        datetime = date + ' ' + time
        txtout.writelines('%s\t%s\n' % (datetime, SoC))  # datetime[tabulator]Soc
