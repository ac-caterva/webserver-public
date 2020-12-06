#!/usr/bin/python3

# Parameter: Datum im Format JJJJ-MM-DD

# v1.0: Lese Zeitstempel und StateOfCharge aus der Textdatei und
#        zeige die Daten in einer Graphik an

import sys
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

# Datum als Parameter
if(len(sys.argv)<=1):
    print("Es wurden keine Parameter übergeben.")
else:
    x = str(sys.argv[1:])[2:-2]
    title = x + ': SoC [%]'
    txt_filename = '/var/caterva/data/SoC-'
    txt_filename = txt_filename + x + '.txt'
    # print(txt_filename)
    png_filename = '/var/caterva/data/SoC-'
    png_filename = png_filename + x + '.png'
    # print(png_filename)


    # Daten einlesen
    data = pd.read_csv(txt_filename,
                     parse_dates=[0],           # 1. Spalte als datetime
                     sep='\t',
                     header=None,
                     names = ['time', 'SoC'])
  
    # Zeitspalte als Index verwenden
    data.index = data['time']
    del data['time']
  
    # Diagramm erzeugen
    fig, ax = plt.subplots(1)
    ax.plot(data)
    xfmt = mdates.DateFormatter('%H:%M')
    ax.xaxis.set_major_formatter(xfmt)
    ax.set(title=title)
    ax.grid()
    fig.savefig(png_filename, dpi=200)
