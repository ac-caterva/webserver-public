#!/bin/bash

# Soll alle Minute (im Crontab pi eintragen) 
# - die letzte Zeile der Invoicelog 
# - die letzte Zeiler der batteryLog 
# - den load der Caterva
# von der Caterva holen
#
# V3 Uptime seperater Aufruf
#    SoC aus batteryLog.csv
# V2 Anlegen der ESS_Minuten Datei (Eigentuemer/Rechte)
# v1 Ersterstellung nach duchsicht mit Anja


LOCK_FILE=/tmp/copyinvoice.lock
_DATUM_=$(date +"%Y-%m")
_ESS_MINUTENFILE_=/opt/fhem/log/ESS_Minutenwerte-${_DATUM_}.log


##############################################
# func_exit
function func_exit ()
{
    rm $LOCK_FILE
    exit 0
}    



##############################################
# MAIN
##############################################


trap 'func_exit' 1 2 15

[ -f $LOCK_FILE ] && exit

echo $$ > $LOCK_FILE


if ( [ -s ${_ESS_MINUTENFILE_} ] ) ; then
	_INVOICELOG_=$(tail -n 1 ${_ESS_MINUTENFILE_})
else 
	sudo touch  ${_ESS_MINUTENFILE_}
	sudo chown fhem:dialout ${_ESS_MINUTENFILE_}
	sudo chmod 664 ${_ESS_MINUTENFILE_}
fi	



_UPTIME_=$(ssh admin@192.168.0.222 "uptime")
# Exit if Caterva is not reachable
STATUS=$?
[ ${STATUS} != 0 ] && func_exit


_INVOICELOGAKTUELL_=$(ssh admin@192.168.0.222 "tail -n 2 /var/log/invoiceLog.csv | grep -v '^#' | tail -n 1 ") 
_BATTERYLOGAKTUELL_=$(ssh admin@192.168.0.222 "tail -n 2 /var/log/batteryLog.csv | grep -v '^#' | tail -n 1 ") 


if [ ! "$(echo ${_INVOICELOG_} | cut -d " " -f1 | cut -d "_" -f2)" == "$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f2 | cut -d " " -f2)" ]
then
	_JAHR_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f2 | cut -c7-10)
	_MONAT_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f2 | cut -c4-5)
	_TAG_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f2 | cut -c1-2)
	_UHRZEIT_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f2 | cut -d " " -f2)
	#_3_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f16 | cut -d "." -f1) 				# SoC in %
	_3_=$(echo ${_BATTERYLOGAKTUELL_} | cut -d ";" -f6 ) 				                            # SoC in %
	_5_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f8 | cut -d "." -f1)                            # Grid -> Household in W
	_7_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f9 | cut -d "." -f1)                            # Battery -> Household in W
	_9_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f10 | cut -d "." -f1)                           # PV -> Household in W
	_11_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f11 | cut -d "." -f1)                          # PV -> Battery in W
	_13_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f12 | cut -d "." -f1)                          # PV -> Grid in W
	_15_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f14 | cut -d "." -f1)                          # PV power provision in W
	_17_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f15 | cut -d "." -f1)                          # Household demand in W
	_19_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f54 | cut -d "." -f1)                          # PVpeak in W
	_21_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f13 | cut -d "." -f1)                          # Load resistor in W
	_23_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f17 | cut -d "." -f1)                          # Neg. Inverter AC power in W
	_25_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f18 | cut -d "." -f1)                          # Pos. Inverter AC power in W
	_27_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f19 | cut -d "." -f1)                          # Neg. Inverter DC power in W
	_29_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f20 | cut -d "." -f1)                          # Pos. Inverter DC power in W
	_31_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f44 | cut -d "." -f1)                          # PFCR as measured in W
	_33_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f45 | cut -d "." -f1)                          # PFCRpos scheduled in W
	_35_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f46 | cut -d "." -f1)                          # PFCRneg scheduled in W
	_37_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f49 | cut -d "." -f1)                          # Traded power in W
	_39_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f52 | cut -d "." -f1)                          # PGRD as measured in W
	_41_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f55 | cut -d "." -f1)                          # PFRR as measured in W
	_43_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f56 | cut -d "." -f1)                          # PFRRpos reserved in W
	_45_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f57 | cut -d "." -f1)                          # PFRRneg reserved in W
	_47_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f69 | cut -d "." -f1)                          # PFCRpos overfulfillment setpoint in W
	_49_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f70 | cut -d "." -f1)                          # PFCRneg overfulfillment setpoint in W
	_51_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f3 | cut -d "." -f1)                           # Control Power -> Battery in W
	_53_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f4 | cut -d "." -f1)                           # Battery -> Control Power in W
	_55_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f5 | cut -d "." -f1)                           # Deadband recharge in W
	_57_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f6 | cut -d "." -f1)                           # Recharge by power purchase in W
	_59_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f7 | cut -d "." -f1)                           # Discharge by power sale in W
	_61_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f21 | cut -d "." -f1)                          # ESS counter level discharge in Wh
	_63_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f24 | cut -d "." -f1)                          # HH counter level discharge in Wh
	_65_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f25 | cut -d "." -f1)                          # HH counter level charge in Wh
	_67_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f27 | cut -d "." -f1)                          # PV counter level discharge in Wh
	_69_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f22 | cut -d "." -f1)                          # ESS counter level charge in Wh 
	_71_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f28 | cut -d "." -f1)                          # PV counter level charge in Wh
	_73_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f32 | cut -d "." -f1)                          # PV+HH counter level discharge in Wh
	_75_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f33 | cut -d "." -f1)                          # PV+HH counter level charge in Wh
	_77_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f35 | cut -d "." -f1)                          # PBH counter level in Wh
	_79_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f36 | cut -d "." -f1)                          # PPB counter level in Wh
	_81_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f38 | cut -d "." -f1)                          # PRE counter level in Wh 
	_83_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f39 | cut -d "." -f1)                          # PDI counter level in Wh
	_85_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f41 | cut -d "." -f1)                          # PFCRpos counter level in Wh
	_87_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f42 | cut -d "." -f1)                          # PFCRneg counter level in Wh
	_89_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f53 | cut -d "." -f1)                          # HHpa in Wh
	_91_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f60 | cut -d "." -f1)                          # PFRRpos counter level in Wh
	_93_=$(echo ${_INVOICELOGAKTUELL_} | cut -d ";" -f61 | cut -d "." -f1)                          # PFRRneg counter level in Wh
    #_95_=$(echo ${_INVOICELOGAKTUELL_} | awk -F": " '{print $2}' | awk -F"," '{print $1}')          # Average Load der Caterva
    _95_=$(echo ${_UPTIME_} | awk -F": " '{print $2}' | awk -F"," '{print $1}')                     # Average Load der Caterva

echo "${_JAHR_}-${_MONAT_}-${_TAG_}_${_UHRZEIT_} 3: ${_3_} 5: ${_5_} 7: ${_7_} 9: ${_9_} 11: ${_11_} 13: ${_13_} 15: ${_15_} 17: ${_17_} 19: ${_19_} 21: ${_21_} 23: ${_23_} 25: ${_25_} 27: ${_27_} 29: ${_29_} 31: ${_31_} 33: ${_33_} 35: ${_35_} 37: ${_37_} 39: ${_39_} 41: ${_41_} 43: ${_43_} 45: ${_45_} 47: ${_47_} 49: ${_49_} 51: ${_51_} 53: ${_53_} 55: ${_55_} 57: ${_57_} 59: ${_59_} 61: ${_61_} 63: ${_63_} 65: ${_65_} 67: ${_67_} 69: ${_69_} 71: ${_71_} 73: ${_73_} 75: ${_75_} 77: ${_77_} 79: ${_79_} 81: ${_81_} 83: ${_83_} 85: ${_85_} 87: ${_87_} 89: ${_89_} 91: ${_91_} 93: ${_93_} 95: ${_95_}" >> ${_ESS_MINUTENFILE_}

fi

func_exit

