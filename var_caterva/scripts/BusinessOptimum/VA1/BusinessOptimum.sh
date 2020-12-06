#!/bin/bash
### BEGIN INFO
# Provides: Business Optimization
#
# chargeStandbyThreshold_hyst:      Charging routine will stop, when "chargeStandbyThreshold_hyst" has been reached
# dischargeStandbyThreshold:		Discharging immediately, when "dischargeStandbyThreshold" exceeded
# dischargeStandbyThreshold_delay:	Discharging only, when "dischargeStandbyThreshold_delay" has been exceeded > "counter_standby_to_discharge_max"
# dischargeStandbyThreshold_hyst:	Discharging routine will stop, when "dischargeStandbyThreshold_hyst" has been reached
# Charching until "SoC_max" reached; sets "ChargedFlag", which ensures that until reaching "SoC_charge" only discharge is possible
#
# Log: /home/admin/bin/BusinessOptimum.log
# Standby is forced due to file '/home/admin/registry/noPVBuffering'
# /home/admin/registry/chargeStandbyThreshold   		- not existing or standard value: 400.00
# /home/admin/registry/dischargeStandbyThreshold 		- not existing or standard value: 300.00
#
# Status  ---  cat /home/admin/registry/noPVBuffering   - not existing: PVBuffering / existing: noPVBuffering
#              cat /var/log/ChargedFlag					- '0' charge/discharge possible
#														- '1' discharge only
#														- "-1" force charching
#
#
#
# Siegfried Quinger - VA10_2020-12-05_12.00
### END INFO


#-------------------------------------------------------------------------------------------------------------------
version="VA10_2020-12-05_12.00"
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
_LOGDIR_=/home/admin/bin
_LOGFILENAME_=BusinessOptimum.log
_LOGFILE_=${_LOGDIR_}/${_LOGFILENAME_}

_BO_ConfigDIR_=/home/admin/bin
_BO_ConfigFILENAME_=BusinessOptimum.config
_BO_ConfigFILE_=${_BO_ConfigDIR_}/${_BO_ConfigFILENAME_}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
#
# F  U  N  C  T  I  O  N  S 	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
#
#-------------------------------------------------------------------------------------------------------------------
# function_Print_Battery_Status_1338
# Display / Print Battery Status
#-------------------------------------------------------------------------------------------------------------------
function function_Print_Battery_Status_1338 ()
 {
	echo "" >> ${_LOGFILE_}
	(echo "mod";sleep 0.3;echo "exit";) | netcat localhost 1338 >> /tmp/swarm-battery-cmd.tmp
	tail -n 29 /tmp/swarm-battery-cmd.tmp > /tmp/swarm-battery-cmd_tail.tmp
	head -n 24 /tmp/swarm-battery-cmd_tail.tmp >> ${_LOGFILE_}	
	echo "" >> ${_LOGFILE_}
 }
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Print_nohup
# Display / Print nohup.out
#-------------------------------------------------------------------------------------------------------------------
function function_Print_nohup ()
 {
	echo ------------------------------------------------------------------------ >> ${_LOGFILE_}
	echo "Inhalt von nohup.out:" >> ${_LOGFILE_}
	cat nohup.out >> ${_LOGFILE_}
	echo ------------------------------------------------------------------------ >> ${_LOGFILE_}	
	rm -f /home/admin/bin/nohup.out
	touch /home/admin/bin/nohup.out	
 }
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_exit_and_start
# Record System Status in log-File prior to restarting, force restart of BusinessOptimum
#-------------------------------------------------------------------------------------------------------------------
function function_exit_and_start ()
{
echo "" >> ${_LOGFILE_}
echo System nicht mehr betriebsbereit >> ${_LOGFILE_}
echo ------------------------------------------------------------------------ >> ${_LOGFILE_}
System_Initialization=$(swarmBcSend "LLN0.Init.stVal")
echo Systemzustandsabfrage 'LLN0.Init.stVal'... '"'$System_Initialization'"' >> ${_LOGFILE_}
System_Running=$(swarmBcSend "LLN0.Mod.stVal")
echo Systembetriebsabfrage 'LLN0.Mod.stVal'... '"'$System_Running'"' >> ${_LOGFILE_}

# Display / Print nohup.out
function_Print_nohup

echo System nicht mehr betriebsbereit - Abbruch >> ${_LOGFILE_}
echo ------------------------------------------------------------------------ >> ${_LOGFILE_}
echo BusinessOptimum wird neu gestartet >> ${_LOGFILE_}
echo "" >> ${_LOGFILE_}

# Start BusinessOptimum while others is switched off
nohup BusinessOptimum.sh &
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Kill_processes
# Kill processes
#-------------------------------------------------------------------------------------------------------------------
function function_Kill_processes ()
 {
	echo "" >> ${_LOGFILE_}	
	top -b -n 1 | grep load >> ${_LOGFILE_}
	top -b -n 1 | grep agetty >> ${_LOGFILE_}
	top -b -n 1 | grep monitor.sh >> ${_LOGFILE_}
	top -b -n 1 | grep swarmcomm.sh >> ${_LOGFILE_}	
	p1=$(pidof -x agetty)	
	sudo pkill -SIGTERM agetty
	p2=$(pidof -x agetty)
	#echo $(date +"%Y-%m-%d %T") '||' agetty aktuell: $p1 '(PIDs)' '||' killed '||' agetty neu: $p2 '(PIDs)' >> ${_LOGFILE_}
	sudo pkill -SIGTERM swarmcomm.sh
 }
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Timer_Minute
# Monitor time to initate certain functions (every minute) 
#-------------------------------------------------------------------------------------------------------------------
function function_Timer_Minute ()
{
	Timer_M_increment=0
	if [ $Status_Timer_M_ini -eq 1 ]; then
		# Timer_M --- Monitor time to initate certain functions (every minute) 
		if ( [ $(date +%S) -ge 00 ] && [ $(date +%S) -le 15 ] && [ $Status_Timer_M -eq 0 ] && [ $Timer_M_increment -eq 0 ] ); then
			Timer_M_increment=$(awk '{print $1}' <<<"${Timer_M_increment}")
			Status_Timer_M=1		
		fi
		if ( [ $(date +%S) -ge 16 ] && [ $Status_Timer_M -eq 1 ] ); then
			Timer_M_increment=0
			Status_Timer_M=0
			Status_Timer_M_activated=0	
		fi
	fi	
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Timer_Hour
# Monitor time to initate certain functions (every hour) 
#-------------------------------------------------------------------------------------------------------------------
function function_Timer_Hour ()
{
	if [ $Status_Timer_H_ini -eq 1 ]; then
		# Timer_H --- Monitor time to initate certain functions (every hour) 
		if ( [ $(date +%M) -eq 00 ] && [ $Status_Timer_H -eq 0 ] ); then
			Status_Timer_H=1		
		fi		
		if ( [ $(date +%M) -eq 01 ] && [ $Status_Timer_H -eq 1 ] ); then
			Status_Timer_H=0
			Status_Timer_H_activated=0	
		fi
	fi
}
#-------------------------------------------------------------------------------------------------------------------	


#-------------------------------------------------------------------------------------------------------------------
# function_CPOL_Reset
# CPOL: set back to normal operations
#-------------------------------------------------------------------------------------------------------------------
function function_CPOL_Reset ()
{
	swarmBcSend "CPOL1.Wchrg.setMag.f=0" > /dev/null
	swarmBcSend "CPOL1.OffsetDuration.setVal=1422692866" > /dev/null
	swarmBcSend "CPOL1.OffsetStart.setVal=0" > /dev/null	
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Read__Cell_Voltage
# Read cell voltage min/max
#-------------------------------------------------------------------------------------------------------------------
function function_Read__Cell_Voltage ()
{
	U_cell_minV=$(swarmBcSend "MBMS1.MinV.mag.f")
	U_cell_maxV=$(swarmBcSend "MBMS1.MaxV.mag.f")
	U_cell_diff_V=$(awk '{print $1-$2}' <<<"${U_cell_maxV} ${U_cell_minV}")
	printf -v U_cell_minV_int %.0f $U_cell_minV		
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Read__BMU_Current_SoC_Capa 
# Read BMU_current_max / Capacity and SoC of all modules (for Gen2 only)
#-------------------------------------------------------------------------------------------------------------------
function function_Read__BMU_Current_SoC_Capa ()
{
	BMU_current_max=$(swarmBcSend "MBMS1.MaxA.mag.f")
	BMU_current_max=$(awk '{print ($1*1000)}' <<<"${BMU_current_max}")
	printf -v BMU_current_max_int %.0f $BMU_current_max						
				
	(echo "mod";sleep 0.3;echo "exit";) | netcat localhost 1338 >> /tmp/swarm-battery-cmd.tmp
	tail -n 15 /tmp/swarm-battery-cmd.tmp | grep "soc" > /tmp/swarm-battery-cmd_tail.tmp
	SoC_module_BMU=$(awk -F " " '{print $3}'    /tmp/swarm-battery-cmd_tail.tmp)
	SoC_module_1=$(awk -F " " '{print $4}'    /tmp/swarm-battery-cmd_tail.tmp)
	SoC_module_2=$(awk -F " " '{print $5}'    /tmp/swarm-battery-cmd_tail.tmp)
	SoC_module_3=$(awk -F " " '{print $6}'    /tmp/swarm-battery-cmd_tail.tmp)
	SoC_module_4=$(awk -F " " '{print $7}'    /tmp/swarm-battery-cmd_tail.tmp)
	SoC_module_5=$(awk -F " " '{print $8}'    /tmp/swarm-battery-cmd_tail.tmp)
	SoC_module_6=$(awk -F " " '{print $9}'    /tmp/swarm-battery-cmd_tail.tmp)
	SoC_module_7=$(awk -F " " '{print $10}'    /tmp/swarm-battery-cmd_tail.tmp)
	SoC_module_8=$(awk -F " " '{print $11}'    /tmp/swarm-battery-cmd_tail.tmp)
	SoC_module_9=$(awk -F " " '{print $12}'    /tmp/swarm-battery-cmd_tail.tmp)
	SoC_module_10=$(awk -F " " '{print $13}'    /tmp/swarm-battery-cmd_tail.tmp)
				
	SoC_module_min=$SoC_module_BMU
	SoC_module_max=$SoC_module_1
	if [ $SoC_module_2 -gt $SoC_module_max ]; then	SoC_module_max=$SoC_module_2; fi
	if [ $SoC_module_3 -gt $SoC_module_max ]; then	SoC_module_max=$SoC_module_3; fi
	if [ $SoC_module_4 -gt $SoC_module_max ]; then	SoC_module_max=$SoC_module_4; fi
	if [ $SoC_module_5 -gt $SoC_module_max ]; then	SoC_module_max=$SoC_module_5; fi
	if [ $SoC_module_6 -gt $SoC_module_max ]; then	SoC_module_max=$SoC_module_6; fi
	if [ $SoC_module_7 -gt $SoC_module_max ]; then	SoC_module_max=$SoC_module_7; fi
	if [ $SoC_module_8 -gt $SoC_module_max ]; then	SoC_module_max=$SoC_module_8; fi
	if [ $SoC_module_9 -gt $SoC_module_max ]; then	SoC_module_max=$SoC_module_9; fi
	if [ $SoC_module_10 -gt $SoC_module_max ]; then SoC_module_max=$SoC_module_10; fi
	SoC_module_diff=$(awk '{print ($1-$2)/10}' <<<"${SoC_module_max} ${SoC_module_min}")  

	tail -n 15 /tmp/swarm-battery-cmd.tmp | grep "rem" > /tmp/swarm-battery-cmd_tail.tmp
	rem_capa_module_BMU=$(awk -F " " '{print $4}'    /tmp/swarm-battery-cmd_tail.tmp)

	tail -n 15 /tmp/swarm-battery-cmd.tmp | grep "full" > /tmp/swarm-battery-cmd_tail.tmp
	full_capa_module_BMU=$(awk -F " " '{print $4}'    /tmp/swarm-battery-cmd_tail.tmp)			
						
	capa_module_100=$(awk '{print (100*$1/$2)}' <<<"${rem_capa_module_BMU} ${full_capa_module_BMU}") 
	printf -v capa_module_100_int %.0f $capa_module_100
			
	capa_module_100_int_low=$(awk '{print ($1-1)}' <<<"${capa_module_100_int}")
	
	time_remaining=$(awk '{print ($1-$2)}' <<<"${time_limit} ${time_current_sec_epoch}")
	capacity_remaining=$(awk '{print ($1-$2)}' <<<"${full_capa_module_BMU_minus} ${rem_capa_module_BMU}")
			
	BMU_current_max=$(swarmBcSend "MBMS1.MaxA.mag.f")
	BMU_current_max=$(awk '{print ($1*1000)}' <<<"${BMU_current_max}")
	printf -v BMU_current_max_int %.0f $BMU_current_max
	
	echo ""  >> ${_LOGFILE_}					
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Read__Logs_Time_PVHH_INV_SoC 
# Read time, PVandHH, INV, SoC (invoice and battery log) 
#-------------------------------------------------------------------------------------------------------------------
function function_Read__Logs_Time_PVHH_INV_SoC ()
{
	# Save last line of invoiceLog --- Read data from invoiceLog: PV, HH, SoC
	# Note: Only 1 reading is difficult, as value may vary a bit, therefore average of 3 readings
	# 1st reading of invoiceLog 
	tail -3 /var/log/invoiceLog.csv | grep -v "^#" | grep "20" | tail -1 > /var/log/invoiceLog_tail_1.csv
	time=$(awk -F ";" '{print $2}'  /var/log/invoiceLog_tail_1.csv)
	PV_1=$(awk -F ";" '{print $14}' /var/log/invoiceLog_tail_1.csv)
	HH_1=$(awk -F ";" '{print $15}' /var/log/invoiceLog_tail_1.csv)
	sleep 0.5
	# 2nd reading of invoiceLog 
	tail -3 /var/log/invoiceLog.csv | grep -v "^#" | grep "20" | tail -1 > /var/log/invoiceLog_tail_2.csv
	PV_2=$(awk -F ";" '{print $14}'    /var/log/invoiceLog_tail_2.csv)
	HH_2=$(awk -F ";" '{print $15}'    /var/log/invoiceLog_tail_2.csv)
	sleep 0.5
	# 3rd reading of invoiceLog 
	tail -3 /var/log/invoiceLog.csv | grep -v "^#" | grep "20" | tail -1 > /var/log/invoiceLog_tail_3.csv
	PV_3=$(awk -F ";" '{print $14}'    /var/log/invoiceLog_tail_3.csv)
	HH_3=$(awk -F ";" '{print $15}'    /var/log/invoiceLog_tail_3.csv)

	# Combine both PV and HH data to a complete set considerung +/- of Power "HH: +; PV: -"; calculate average of three measurements
	PVandHH_1=$(awk '{print $1-$2}' <<<"${HH_1} ${PV_1}")
	printf -v PVandHH_1_int %.0f $PVandHH_1
	PVandHH_2=$(awk '{print $1-$2}' <<<"${HH_2} ${PV_2}")
	printf -v PVandHH_2_int %.0f $PVandHH_2
	PVandHH_3=$(awk '{print $1-$2}' <<<"${HH_3} ${PV_3}")
	printf -v PVandHH_3_int %.0f $PVandHH_3
	PVandHH=$(awk '{print ($1+$2+$3)/3}' <<<"${PVandHH_1_int} ${PVandHH_2_int} ${PVandHH_3_int}")
	printf -v PVandHH_int %.0f $PVandHH

	# Save last line of batteryLog --- Read data from batteryLog: CPOL1_Mod, Inv_Request, SoC
	tail -3 /var/log/batteryLog.csv | grep -v "^#" | grep "20" | tail -1 > /var/log/batteryLog_tail.csv
	CPOL1_Mod=$(awk -F ";" '{print $25}'   /var/log/batteryLog_tail.csv)
	Inv_Request=$(awk -F ";" '{print $30}' /var/log/batteryLog_tail.csv)
	SoC=$(awk -F ";" '{print $6}'  /var/log/batteryLog_tail.csv)     
	# Convert floating/text to integer
	printf -v SoC_int %.0f $SoC				
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Check_Inverter_ON 
# Check status of inverter, - if not ON ("1") within 30s force shutdown
#-------------------------------------------------------------------------------------------------------------------
function function_Check_Inverter_ON ()
{
	if ( [[ $CPOL1_Mod != "1" ]] ); then			
		# activate device, if not yet activated: swarmBcSend "LLN0.Mod.ctlVal=1" > /dev/null
		System_Activated=$(swarmBcSend "LLN0.Mod.ctlVal")
		if ( [[ $System_Activated != "1" ]] ); then
			# activate system
			swarmBcSend "LLN0.Mod.ctlVal=1" > /dev/null
			echo $(date +"%Y-%m-%d %T") '||' System activated >> ${_LOGFILE_}
			sleep 30
		fi
		
		sleep 30
		CPOL1_Mod=$(swarmBcSend "CPOL1.Mod.stVal")
		if ( [[ $CPOL1_Mod != "1" ]] ); then
			echo $(date +"%Y-%m-%d %T") '||' System - shutdown >> ${_LOGFILE_}						
			sudo shutdown -r now						
		fi
	fi
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Verify_Configuration 
# Verify Configuration File and advice on changes  
#-------------------------------------------------------------------------------------------------------------------
function function_Verify_Configuration ()
{
	error=0
	if [ $chargeStandbyThreshold_hyst_int -gt -400 ]; then
		echo P_in_W_chargeStandbyThreshold_hyst: max: '-400' '||' aktuell: $chargeStandbyThreshold_hyst_int >> ${_LOGFILE_}
		error=1	
	fi
	if [ $chargeStandbyThreshold_int -ge $chargeStandbyThreshold_hyst_int ]; then
		echo P_in_W_chargeStandbyThreshold: '<' $chargeStandbyThreshold_hyst_int '||' aktuell: $chargeStandbyThreshold_int >> ${_LOGFILE_}
		error=1
	fi	
	if [ $dischargeStandbyThreshold_hyst_int -lt 300 ]; then
		echo P_in_W_dischargeStandbyThreshold_hyst: min: 300 '||' aktuell: $dischargeStandbyThreshold_hyst_int >> ${_LOGFILE_}
		error=1
	fi	
	if [ $dischargeStandbyThreshold_delay_int -le $dischargeStandbyThreshold_hyst_int ]; then
		echo P_in_W_dischargeStandbyThreshold_delay: '>' $dischargeStandbyThreshold_hyst_int '||' aktuell: $dischargeStandbyThreshold_delay_int >> ${_LOGFILE_}
		error=1
	fi
	if [ $dischargeStandbyThreshold_int -le $dischargeStandbyThreshold_delay_int ]; then
		echo P_in_W_dischargeStandbyThreshold_delay: '>' $dischargeStandbyThreshold_delay_int '||' aktuell: $dischargeStandbyThreshold_int >> ${_LOGFILE_}
		error=1
	fi

	if [ $SoC_max_config -gt 90 ]; then
		echo SoC_max: max: 90 '||' aktuell: $SoC_max_config >> ${_LOGFILE_}
		error=1
	fi
	if [ $SoC_charge_config -ge $SoC_max_config ]; then
		echo SoC_charge: kleiner als: $SoC_max_config '||' aktuell: $SoC_charge_config >> ${_LOGFILE_}
		error=1
	fi
	if [ $SoC_discharge -ge $SoC_charge_config ]; then
		echo SoC_discharge: kleiner als: $SoC_charge_config '||' aktuell: $SoC_discharge >> ${_LOGFILE_}
		error=1
	fi
	if [ $SoC_discharge -lt 20 ]; then
		echo SoC_discharge: größer/gleich: 20 '||' aktuell: $SoC_discharge >> ${_LOGFILE_}
		error=1
	fi
	if [ $SoC_min -ge $SoC_discharge ]; then
		echo SoC_min: kleiner als: $SoC_discharge '||' aktuell: $SoC_min >> ${_LOGFILE_}
		error=1
	fi
	if [ $SoC_min -lt 10 ]; then
		echo SoC_min: größer/gleich: 10 '||' aktuell: $SoC_min >> ${_LOGFILE_}
		error=1
	fi
	if [ $SoC_err -ne 0 ]; then
		echo SoC_err: gleich: 0 '||' aktuell: $SoC_err >> ${_LOGFILE_}
		error=1
	fi
	if [[ $system_initialization_req != "1112" ]]; then		
		if [[ $system_initialization_req != "112" ]]; then
			echo System_Initialization: 1112 oder 112 '||' aktuell: $system_initialization_req >> ${_LOGFILE_}
			error=1
		fi
	fi
	if [[ $ECS3_configuration != "PVHH" ]]; then		
		echo ECS3 Configuration: PVHH '||' aktuell: $ECS3_configuration >> ${_LOGFILE_}
			error=1		
	fi
	
	if [ $error -eq 1 ]; then
		echo Konfiguration muss verändert werden - Programm wird abgebrochen >> ${_LOGFILE_}
		exit
	fi
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Print_Configuration
# Log configuration data in BusinessOptimum.log
#-------------------------------------------------------------------------------------------------------------------
function function_Print_Configuration ()
{
	SystemSerial=$(cat /home/admin/registry/out/serial)
	echo "" >> ${_LOGFILE_}
	echo BusinessOptimum: $version >> ${_LOGFILE_} 
	echo $(date +"%Y-%m-%d %T") "(NO WARRANTY)" >> ${_LOGFILE_} 
	echo "" >> ${_LOGFILE_}
	echo Configuration of $SystemSerial: >> ${_LOGFILE_} 
	echo ------------------------------- >> ${_LOGFILE_}
	echo P_in_W_chargeStandbyThreshold: $chargeStandbyThreshold >> ${_LOGFILE_}
	echo P_in_W_chargeStandbyThreshold_hyst: $chargeStandbyThreshold_hyst >> ${_LOGFILE_}
	echo P_in_W_dischargeStandbyThreshold: $dischargeStandbyThreshold >> ${_LOGFILE_}
	echo P_in_W_dischargeStandbyThreshold_delay: $dischargeStandbyThreshold_delay >> ${_LOGFILE_}
	echo P_in_W_dischargeStandbyThreshold_hyst: $dischargeStandbyThreshold_hyst >> ${_LOGFILE_}
	echo SoC_max: $SoC_max_config >> ${_LOGFILE_}
	echo SoC_charge: $SoC_charge_config >> ${_LOGFILE_}
	echo SoC_discharge: $SoC_discharge >> ${_LOGFILE_}
	echo SoC_min: $SoC_min >> ${_LOGFILE_}
	echo SoC_err: $SoC_err >> ${_LOGFILE_}
	echo counter_discharge_to_standby_max: $counter_discharge_to_standby_max >> ${_LOGFILE_}
	echo counter_standby_to_discharge_max: $counter_standby_to_discharge_max >> ${_LOGFILE_}
	echo counter_increment: $counter_increment >> ${_LOGFILE_}
	echo system_initialization: $system_initialization_req >> ${_LOGFILE_}
	echo ECS3_configuration: $ECS3_configuration >> ${_LOGFILE_}	
	echo "" >> ${_LOGFILE_}
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Read_Configuration
# Read configuration data of BusinessOptimum.config
#-------------------------------------------------------------------------------------------------------------------
function function_Read_Configuration ()
{
	# Read variabels from BusinessOptimum.config
	tail -1 ${_BO_ConfigFILE_} > /tmp/BusinessOptimum.tmp
	chargeStandbyThreshold=$(awk -F ";" '{print $1}'  /tmp/BusinessOptimum.tmp)
	chargeStandbyThreshold_hyst=$(awk -F ";" '{print $2}'  /tmp/BusinessOptimum.tmp)
	dischargeStandbyThreshold=$(awk -F ";" '{print $3}'  /tmp/BusinessOptimum.tmp)
	dischargeStandbyThreshold_delay=$(awk -F ";" '{print $4}'  /tmp/BusinessOptimum.tmp)
	dischargeStandbyThreshold_hyst=$(awk -F ";" '{print $5}'  /tmp/BusinessOptimum.tmp)
	SoC_max_config=$(awk -F ";" '{print $6}'  /tmp/BusinessOptimum.tmp)
	SoC_charge_config=$(awk -F ";" '{print $7}'  /tmp/BusinessOptimum.tmp)
	SoC_discharge=$(awk -F ";" '{print $8}'  /tmp/BusinessOptimum.tmp)
	SoC_min=$(awk -F ";" '{print $9}'  /tmp/BusinessOptimum.tmp)
	SoC_err=$(awk -F ";" '{print $10}' /tmp/BusinessOptimum.tmp)
	counter_discharge_to_standby_max=$(awk -F ";" '{print $11}' /tmp/BusinessOptimum.tmp)
	counter_standby_to_discharge_max=$(awk -F ";" '{print $12}' /tmp/BusinessOptimum.tmp)
	counter_increment=$(awk -F ";" '{print $13}' /tmp/BusinessOptimum.tmp)
	system_initialization_req=$(awk -F ";" '{print $14}' /tmp/BusinessOptimum.tmp)
	ECS3_configuration=$(awk -F ";" '{print $15}' /tmp/BusinessOptimum.tmp)

	# Convert floating/text to integer
	printf -v chargeStandbyThreshold_int %.0f $chargeStandbyThreshold
	printf -v chargeStandbyThreshold_hyst_int %.0f $chargeStandbyThreshold_hyst
	printf -v dischargeStandbyThreshold_int %.0f $dischargeStandbyThreshold
	printf -v dischargeStandbyThreshold_delay_int %.0f $dischargeStandbyThreshold_delay
	printf -v dischargeStandbyThreshold_hyst_int %.0f $dischargeStandbyThreshold_hyst
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Compare_Configuration
# Update Configuration when BusinessOptimum.config was changed 
#-------------------------------------------------------------------------------------------------------------------
function function_Compare_Configuration ()
{
	if ( ! cmp -s ${_BO_ConfigFILE_} /tmp/BusinessOptimum.config ); then
		# Copy BusinessOptimum.config to temp file for comparison of changes
		sudo cp -f ${_BO_ConfigFILE_} /tmp/BusinessOptimum.config		
		# Read configuration data of BusinessOptimum.config
		function_Read_Configuration
		echo "" >> ${_LOGFILE_}
		echo ------------------------------------------------------------------------ >> ${_LOGFILE_}
		echo $(date +"%Y-%m-%d %T") '|' "Update der Konfiguration" >> ${_LOGFILE_}
		echo ------------------------------------------------------------------------ >> ${_LOGFILE_}	
		# Log configuration data in BusinessOptimum.log
		function_Print_Configuration
		# Verify Configuration File and advice on changes  
		function_Verify_Configuration
	fi
}
#-------------------------------------------------------------------------------------------------------------------


#===================================================================================================================
#===================================================================================================================
#===================================================================================================================
sleep 5
echo ==================================================================================================================================================== >> ${_LOGFILE_}     
# Display / Print nohup.out
function_Print_nohup

#===================================================================================================================
#===================================================================================================================
#===================================================================================================================
#===================================================================================================================

# Start loadTools to ensure that exported variabels are supported
source /home/admin/bin/loadTools

# Remove temporarily established file of BusinessOptimum
sudo rm -f /tmp/BusinessOptimum.tmp
sudo rm -f /tmp/balanceBatteryModules.tmp
sudo rm -f /tmp/swarm-battery-cmd.tmp
sudo rm -f /tmp/swarm-battery-cmd_tail.tmp
sudo rm -f /tmp/BusinessOptimum_config.tmp
sudo rm -f /tmp/BusinessOptimum_config_tail.tmp
sudo rm -f /tmp/BusinessOptimum.config
# Remove any files hindering to execute BusinessLogic
sudo rm -f /home/admin/registry/businessLogic
sudo rm -f /home/admin/registry/chargeStandbyThreshold
sudo rm -f /home/admin/registry/dischargeStandbyThreshold


# Read configuration data of BusinessOptimum.config
function_Read_Configuration


# Initialize Status
counter_discharge_to_standby=0		# pre-set value for counter_discharge_to_standby
counter_standby_to_discharge=0		# pre-set value for counter_standby_to_discharge
counter_SoC_err=0					# pre-set value for counter_SoC_err:				Counts sequeneces of censecutive lines with SoC_err
counter=0							# pre-set value for counter:						System-Status Counter
counter_forced_charging=0			# pre-set value for counter_forced_charging:		Counts events of performed << forced charging >> routines
Balancing=0							# pre-set value for Balancing: 						'0' Balancing not active // '1' Balancing active
ForcedCharging=0					# pre-set value for ForcedCharging: 				'0' ForcedCharging not active // '1' ForcedCharging active
System_Running=0					# pre-set value for System_Running:					'0' System not runing // '1' System running
Status_Timer_M=1  					# pre-set value for Status_Timer_M:					'0' Timer_M sequence deactivated  // '1' Timer_M sequence activated
Status_Timer_M_activated=0			# pre-set value for Status_Timer_M_activated:		'0' Status_Timer_M_activated recently NOT activated  // '1' Status_Timer_M_activated recently activated
Status_Timer_M_ini=0				# pre-set value for Status_Timer_M_ini:				'0' executes related functions which would be exeuted if Timer_M active
Status_Timer_H=1  					# pre-set value for Status_Timer_H:					'0' Timer_H sequence deactivated  // '1' Timer_H sequence activated
Status_Timer_H_activated=0			# pre-set value for Status_Timer_H_activated:		'0' Status_Timer_H_activated recently NOT activated  // '1' Status_Timer_H_activated recently activated
Status_Timer_H_ini=0				# pre-set value for Status_Timer_H_ini:				'0' executes related functions which would be exeuted if Timer_H active
SoC_module_diff=xxx					# pre-set value for SoC_module_diff:				to display "xxx" if Gen1 system is detected
capa_module_100_int=xxx				# pre-set value for capa_module_100_int:			to display "xxx" if Gen1 system is detected
U_cell_minV=0						# pre-set value for U_cell_minV:					min Voltage of BMU cell	
U_cell_maxV=0						# pre-set value for U_cell_maxV:					max Voltage of BMU cell
U_cell_diff_V=0						# pre-set value for U_cell_diff_V:					difference Voltage of BMU cell
start_up__count=500					# start-up__time									during this period system should be up and running
system_running_req=1				# pre-set value for normal systems running			# when initalization "112" is used, this will be switched to "9"

bmmType=$(cat /home/admin/registry/out/bmmType)


if ( [ -f /home/admin/registry/out/gen2 ] && [ $bmmType == "sony" ] ); then
		U_cell_minV_min_forced_enable=2900	# set-value for U_cell_minV_int:					Threshold when forced charging needed
		U_cell_minV_min_forced_disable=3000	# set-value for U_cell_minV_int:					Threshold when forced charging is disabled
	else # Data for SAFT Batteries to be adjusted
		U_cell_minV_min_forced_enable=0		# set-value for U_cell_minV_int:					Threshold when forced charging needed
		U_cell_minV_min_forced_disable=0	# set-value for U_cell_minV_int:					Threshold when forced charging is disabled
		#U_cell_minV_min_forced_enable=3400	# set-value for U_cell_minV_int:					Threshold when forced charging needed
		#U_cell_minV_min_forced_disable=3450	# set-value for U_cell_minV_int:					Threshold when forced charging is disabled
fi


# Initialize "/var/log/ChargedFlag" depending on current SoC
# Save last line of batteryLog --- Read data from batteryLog: SoC
tail -3 /var/log/batteryLog.csv | grep -v "^#" | grep "20" | tail -1 > /var/log/batteryLog_tail.csv
SoC=$(awk -F ";" '{print $6}'  /var/log/batteryLog_tail.csv)  
# Convert floating/text to integer
printf -v SoC_int %.0f $SoC
# preset based on SoC
if [ $SoC_int -lt $SoC_discharge ]; then
		echo "-1" > /var/log/ChargedFlag      ## discharging disabled / charching enabled
	elif  [ $SoC_int -gt $SoC_charge_config ] ; then	
		echo "1" > /var/log/ChargedFlag       ## discharging enabled / charching disabled
	else
		echo "0" > /var/log/ChargedFlag       ## discharging enabled / charching enabled
fi	
# set Chargedflag based on existing file content
ChargedFlag=$(cat /var/log/ChargedFlag) 


# Log configuration data in BusinessOptimum.log
function_Print_Configuration

# Read Gen2 configuration
if ( [ -f /home/admin/registry/out/gen2 ] ); then
		echo System: Gen2 >> ${_LOGFILE_}
	else
		echo System: Gen1 >> ${_LOGFILE_}
fi
echo BMMType: $bmmType >> ${_LOGFILE_}
echo "" >> ${_LOGFILE_}

# Verify Configuration File and advice on changes  
function_Verify_Configuration


# Change system_running_req when system does not maintain communication with swarm
if [[ $system_initialization_req == "112" ]]; then
	system_running_req=9
fi

# Start functions of BusinessOptimum only when System is available/active
System_Initialization=$(swarmBcSend "LLN0.Init.stVal")
echo Systemzustandsabfrage 'LLN0.Init.stVal'... '"'$System_Initialization'"' >> ${_LOGFILE_}
while ( ( [ $System_Initialization != $system_initialization_req ] || [ -z $System_Initialization ] ) && ( [ $counter -le $start_up__count ] ) ); do
        if ( [ $System_Initialization != $system_initialization_req ] || [ -z $System_Initialization ] ); then
			echo $(date +"%Y-%m-%d %T") '||' System noch nicht betriebsbereit  '('$counter'/'$start_up__count')' >> ${_LOGFILE_}	
			counter=$(awk '{print ($1+5)}' <<<"${counter}")				
			sleep 5
		fi		
		System_Initialization=$(swarmBcSend ""LLN0.Init.stVal"")
done
echo '->' Systemzustandsabfrage 'LLN0.Init.stVal'... '"'$System_Initialization'"' >> ${_LOGFILE_}
if ( [ $counter -ge $start_up__count ] ); then    
	echo $(date +"%Y-%m-%d %T") '||' System - shutdown >> ${_LOGFILE_}
	sleep 10
	sudo shutdown -r now
fi

counter=0
System_Activated=$(swarmBcSend "LLN0.Mod.ctlVal")
echo Systemaktivierungsabfrage 'LLN0.Mod.ctlVal'... '"'$System_Activated'"' >> ${_LOGFILE_}
while ( [[ $System_Activated != "1" ]] && [ $counter -le $start_up__count ] ); do   
        if ( [[ $System_Activated != "1" ]] ); then
			echo $(date +"%Y-%m-%d %T") '||' System noch nicht aktiviert  '('$counter'/'$start_up__count')' >> ${_LOGFILE_}	
			counter=$(awk '{print ($1+5)}' <<<"${counter}")			
			sleep 5
		fi		
		System_Activated=$(swarmBcSend "LLN0.Mod.ctlVal")
done
echo '->' Systemaktivierungsabfrage 'LLN0.Mod.ctlVal'... '"'$System_Activated'"' >> ${_LOGFILE_}
if ( [ $counter -ge $start_up__count ] ); then    
	echo $(date +"%Y-%m-%d %T") '||' System - shutdown >> ${_LOGFILE_}
	sleep 10
	sudo shutdown -r now
fi

counter=0
System_Running=$(swarmBcSend "LLN0.Mod.stVal")
echo Systembetriebsabfrage 'LLN0.Mod.stVal'... '"'$System_Running'"' >> ${_LOGFILE_}
while ( [ $System_Running -ne $system_running_req ] && [ $counter -le $start_up__count ] ); do   
        if ( [ $System_Running -ne $system_running_req ] ); then
			echo $(date +"%Y-%m-%d %T") '||' System noch nicht betriebsbereit  '('$counter'/'$start_up__count')' >> ${_LOGFILE_}	
			counter=$(awk '{print ($1+5)}' <<<"${counter}")			
			sleep 5
		fi		
		System_Running=$(swarmBcSend "LLN0.Mod.stVal")
done
echo '->' Systembetriebsabfrage 'LLN0.Mod.stVal'... '"'$System_Running'"' >> ${_LOGFILE_}
if ( [ $counter -ge $start_up__count ] ); then    
	echo $(date +"%Y-%m-%d %T") '||' System - shutdown >> ${_LOGFILE_}
	sleep 10
	sudo shutdown -r now
fi
echo System betriebsbereit und aktiviert >> ${_LOGFILE_}

# CPOL: set back to normal operations
function_CPOL_Reset


# Display / Print Battery Status
if ( [ -f /home/admin/registry/out/gen2 ] && [ $bmmType == "sony" ] ); then
	echo "" >> ${_LOGFILE_}
	echo Aktueller Status Batteriemodule >> ${_LOGFILE_}
	echo ------------------------------- >> ${_LOGFILE_}
	function_Print_Battery_Status_1338
fi


# Copy BusinessOptimum.config to temp file for comparison of changes
sudo cp -f ${_BO_ConfigFILE_} /tmp/BusinessOptimum.config


#===================================================================================================================
#==== MAIN ROUTINE =================================================================================================
#===================================================================================================================
while ( [ $System_Initialization = $system_initialization_req ] && [ $System_Running -eq $system_running_req ] ); do

	# Scan of System Status
	System_Initialization=$(swarmBcSend "LLN0.Init.stVal")
	System_Running=$(swarmBcSend "LLN0.Mod.stVal")


	# Verify if ModuleBalancing shall be started
	if ( [ -f /var/log/ModuleBalancing ]  ); then
		counter_forced_charging=3 					# set counter to 3, whereas ModuleBalancing will be started
	fi
	# Verify if CellBalancing shall be started
	if ( [ -f /var/log/CellBalancing ]  ); then
		CellBalancing=1
	fi


	# Monitor time to initate certain functions (every Monday at 00:00) - back-up BusinessOptimum.log and start with new BusinessOptimum-old.log
	if ( [ $(date +%u) -eq 1 ] && [ $(date +%H) -eq 0 ] && [ $(date +%M) -eq 0 ] && [ $(date +%S) -le 30 ] ); then		
		sudo rm -f /home/admin/log/BusinessOptimum-old.log
		sudo cp -f ${_LOGFILE_} /home/admin/log/BusinessOptimum-old.log
		sudo rm -f ${_LOGFILE_}
		
		# Log configuration data in new BusinessOptimum.log
		function_Print_Configuration
		
		# Wait until safely files are copied and removed
		sleep 30
	fi

	# Correct original settings of SoC_max and SoC_charge considering the disbalance of the modules (SoC_module_diff)			
	if ( [ -f /home/admin/registry/out/gen2 ] && [ $bmmType == "sony" ] ); then
		SoC_max=$(awk '{print $1-$2}' <<<"${SoC_max_config} ${SoC_module_diff}")
		SoC_charge=$(awk '{print $1-$2}' <<<"${SoC_charge_config} ${SoC_module_diff}")
	fi

	
	# Monitor time to initate certain functions (every hour) 
	function_Timer_Hour
	
	# Kill processes every hour
	if ( [ $Status_Timer_H -eq 1 ] && [ $Status_Timer_H_activated -eq 0 ] ); then		
		# Kill processes
		function_Kill_processes					

		Status_Timer_H_activated=1	
		if [ $Status_Timer_H_ini -eq 0 ]; then
			Status_Timer_H_ini=1
			Status_Timer_H=0
			Status_Timer_H_activated=0
		fi		
	fi
	
	
	# Monitor time to initate certain functions (every minute) 
	function_Timer_Minute
	
	# Monitor changes on .config / Display "BMU_current_max / Capacity and SoC of all modules" and "check on bigger SoC changes every minute"
	if ( [ $Status_Timer_M -eq 1 ] && [ $Status_Timer_M_activated -eq 0 ] ); then			
		# Update Configuration when BusinessOptimum.config was changed 
		function_Compare_Configuration
		
		# Read cell voltage min/max
		function_Read__Cell_Voltage
						
		if ( [ -f /home/admin/registry/out/gen2 ] && [ $bmmType == "sony" ] ); then
			# Read BMU_current_max / Capacity and SoC of all modules (for Gen2 only)
			function_Read__BMU_Current_SoC_Capa
			echo '                    ||' BMU-SoC: $SoC_module_BMU '|' $SoC_module_1 $SoC_module_2 $SoC_module_3 $SoC_module_4 $SoC_module_5 $SoC_module_6 $SoC_module_7 $SoC_module_8 $SoC_module_9 $SoC_module_10 '||' BMU_Kapazität: $rem_capa_module_BMU mAh '(' $full_capa_module_BMU mAh ') ||' Zell-Spannung: $U_cell_minV_int mV '|' BMU-Strom: $BMU_current_max_int mA >> ${_LOGFILE_} 					
		fi
		# Identify SoC-Sprünge when comparing with the actual capacity
		if [ $SoC_int -lt $capa_module_100_int_low ]; then
		     echo SoC-Sprung: SoC: $SoC_int % '|' SoC_Δ: $SoC_module_diff % '|' Capacity: $capa_module_100_int_low % >> ${_LOGFILE_}
		fi						

		Status_Timer_M_activated=1	
		if [ $Status_Timer_M_ini -eq 0 ]; then
			Status_Timer_M_ini=1
			Status_Timer_M=0
			Status_Timer_M_activated=0
		fi		
	fi
	

	#####################################################################################################################
	#====================================================================================================================
	# Sequences of normal operations if module-balancing and cell-balancing is not needed.
	#====================================================================================================================
	#####################################################################################################################

	# Verify if "/home/admin/registry/noPVBuffering" exists
	if [ ! -f /home/admin/registry/noPVBuffering ]; then
			# File does NOT exist
			Status="PVBuffering"
		else
			Status="noPVBuffering"
	fi

	# Read time, PVandHH, INV, SoC (invoice and battery log)
	function_Read__Logs_Time_PVHH_INV_SoC

	
	# From time to time observed 0 SoC, therefore that will be ignored by avoiding that status and ending the loop of that 'while' operation
	if ( [ $SoC_int -le $SoC_err ] && [ $counter_SoC_err -lt 10 ] ); then
			counter_SoC_err=$(awk '{print $1+1}' <<<"${counter_SoC_err}")									
			echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|'   '|' SoC observed with '≤' $SoC_err %: $counter_SoC_err'/'10 >> ${_LOGFILE_}		  			
			continue
		else
			counter_SoC_err=0
	fi

	
	# Set/Reset ChargedFlag: 1 '(fully charged -> no charging possible)' -> 0 '(partially charged -> charging possible)'
	# 						-1 '(empty -> charging is forced)'
	if [ $SoC_int -ge $SoC_max ]; then
			echo "1" > /var/log/ChargedFlag      ## stop charging									
		elif ( [ $SoC_int -le $SoC_charge ] && [ $SoC_int -ge $SoC_discharge ] && [[ $ChargedFlag == "1" ]] ); then	
			echo "0" > /var/log/ChargedFlag      ## enable charging/discharing
		elif ( [ $SoC_int -le $SoC_charge ] && [ $SoC_int -ge $SoC_discharge ] && [[ $ChargedFlag == "-1" ]] ); then	
			echo "0" > /var/log/ChargedFlag      ## enable charging/discharing
		elif [ $SoC_int -le $SoC_min ] ; then
			echo "-1" > /var/log/ChargedFlag     ## enable forced charging		
	fi	

    # set Chargedflag based on existing file content (changed conditions of previous settings)
    ChargedFlag=$(cat /var/log/ChargedFlag) 

	
	#====================================================================================================================
	#====================================================================================================================
	# Z  # ChargedFlag = -1 (Battery empty): NACHLADEN (FORCED CHARGING) < SoC_discharge ODER < U_cell_minV_min_forced_enable
	#====================================================================================================================
	#====================================================================================================================
	

	if ( ( [[ $ChargedFlag == "-1" ]] && [ $PVandHH_int -gt $chargeStandbyThreshold_hyst_int ] ) || [ $U_cell_minV_int -le $U_cell_minV_min_forced_enable ] ); then
		# Display / Print Battery Status
		if ( [ -f /home/admin/registry/out/gen2 ] && [ $bmmType == "sony" ] ); then
			echo "" >> ${_LOGFILE_}
			echo Aktueller Status Batteriemodule: SoC $SoC_int % '<' $SoC_discharge % '('Initialisierungsphase')' >> ${_LOGFILE_}
			echo Aktueller Status Batteriemodule: SoC $SoC_int % '≤' $SoC_min % bzw. Zell-Spannung zu niedrig $U_cell_minV_int mV '≤' $U_cell_minV_min_forced_enable mV ? >> ${_LOGFILE_}
			echo -------------------------------------------------------------------------------------------------- >> ${_LOGFILE_}			
			function_Print_Battery_Status_1338
		fi		
								
		# Due to safety reasons in case charging would not start: Avoid discharging
		touch /home/admin/registry/noPVBuffering
					
		# Start charging the battery only up to SoC_discharge, and when available
		System_Running=$(swarmBcSend "LLN0.Mod.stVal")
        if [ $System_Running -ne $system_running_req ]; then
			echo System ist NICHT betriebsbereit, Laden wird nicht gestartet  >> ${_LOGFILE_}	
		    echo ----------------------------------------------------------- >> ${_LOGFILE_}			
			# Record System Status in log-File prior to restarting, force restart of BusinessOptimum
			function_exit_and_start
		 else
			echo System ist betriebsbereit, Nachladen wird gestartet - min. 10 min  >> ${_LOGFILE_}				
		    echo ---------------------------------------------------------------- >> ${_LOGFILE_}			
			# set charge command
			swarmBcSend "CPOL1.Wchrg.setMag.f=5555" > /dev/null
			swarmBcSend "CPOL1.OffsetDuration.setVal=3600" > /dev/null			# max. 1 hour
			swarmBcSend "CPOL1.OffsetStart.setVal=$(date +%s)" > /dev/null
			ForcedCharging=1
		fi

		time_current_original_sec_epoch=$(date +%s)
		time_current_sec_epoch=$(date +%s)
		time_offset_sec=600 # 10min
		time_limit=$(awk '{print ($1+$2)}' <<<"${time_current_original_sec_epoch} ${time_offset_sec}")

		while ( [ $SoC_int -le $SoC_discharge ] || [ $U_cell_minV_int -le $U_cell_minV_min_forced_disable ] || [ $time_current_sec_epoch -le $time_limit ] ); do    
		    # Monitor time to initate certain functions (every minute) 	 
			function_Timer_Minute
						
			# Read cell voltage min/max, BMU_current_max and SoC of all modules (SoC/capacity for Gen2 only)
			if ( [ $Status_Timer_M -eq 1 ] && [ $Status_Timer_M_activated -eq 0 ] ); then		
				
				# Read cell voltage min/max
				function_Read__Cell_Voltage
								
				if ( [ -f /home/admin/registry/out/gen2 ] && [ $bmmType == "sony" ] ); then
					# Read BMU_current_max / Capacity and SoC of all modules (for Gen2 only)
					function_Read__BMU_Current_SoC_Capa	
					echo '                    ||' BMU-SoC: $SoC_module_BMU '|' $SoC_module_1 $SoC_module_2 $SoC_module_3 $SoC_module_4 $SoC_module_5 $SoC_module_6 $SoC_module_7 $SoC_module_8 $SoC_module_9 $SoC_module_10 '||' BMU_Kapazität: $rem_capa_module_BMU mAh '(' $full_capa_module_BMU mAh ') ||' Zell-Spannung: $U_cell_minV_int mV '|' BMU-Strom: $BMU_current_max_int mA  >> ${_LOGFILE_} 					
				fi

				Status_Timer_M_activated=1
	
				if [ $Status_Timer_M_ini -eq 0 ]; then
					Status_Timer_M_ini=1
					Status_Timer_M=0
					Status_Timer_M_activated=0
				fi			
			fi

			# Read time, PVandHH, INV, SoC (invoice and battery log)
			function_Read__Logs_Time_PVHH_INV_SoC	
	 		
			echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' Z '|' Nachladen >> ${_LOGFILE_}		  
		    sleep 1
			time_current_sec_epoch=$(date +%s)
			
			# Check status of inverter, - if not ON ("1") within 30s force shutdown
			function_Check_Inverter_ON
		
		done
			
		
		if [ $ForcedCharging -eq 1 ]; then
			echo Nachladen abgeschlossen >> ${_LOGFILE_}
			echo ----------------------- >> ${_LOGFILE_}
			
			# CPOL: set back to normal operations
			function_CPOL_Reset					
			ForcedCharging=0	
						
			# Display / Print Battery Status
			if ( [ -f /home/admin/registry/out/gen2 ] && [ $bmmType == "sony" ] ); then
				echo "" >> ${_LOGFILE_}				
				echo Aktueller Status Batteriemodule: SoC $SoC_int % '>' $SoC_discharge % bzw. Zell-Spannung $U_cell_minV_int mV '>' $U_cell_minV_min_forced_disable mV >> ${_LOGFILE_}
				echo ------------------------------------------------------------------------------------- >> ${_LOGFILE_}			
				function_Print_Battery_Status_1338
			fi
		
			## enable normal charging/discharing
			echo "0" > /var/log/ChargedFlag		

			# Count events of forced charching
			counter_forced_charging=$(awk '{print $1+1}' <<<"${counter_forced_charging}")
			
		fi

	#====================================================================================================================
	# A1 # PVandHH ≥ dischargeStandbyThreshold_int  AND SoC > SoC_discharge: AUSSPEICHERN (Discharge)
	#====================================================================================================================	
	elif ( [ $PVandHH_int -ge $dischargeStandbyThreshold_int ] && [ $SoC_int -gt $SoC_discharge ] ); then
		if [[ $Status == "noPVBuffering" ]]; then
				rm -f /home/admin/registry/noPVBuffering				
				echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' A1 '|' AUSSPEICHERN - rm noPVBuffering >> ${_LOGFILE_}		  				
				
				
			else	      
				echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' A1 '|' AUSSPEICHERN >> ${_LOGFILE_}				
		fi
		counter_discharge_to_standby=0
		counter_standby_to_discharge=0

		
	#====================================================================================================================
	# A2 # PVandHH ≥ dischargeStandbyThreshold_int  AND SoC ≤ SoC_discharge: STANDBY (Sleep)
	#====================================================================================================================	
	elif ( [ $PVandHH_int -ge $dischargeStandbyThreshold_int ] && [ $SoC_int -le $SoC_discharge ] ); then
		if [[ $Status == "PVBuffering" ]]; then
				touch /home/admin/registry/noPVBuffering
				echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' A2 '|' STANDBY '(Sleep):' SoC≤$SoC_discharge% - touch noPVBuffering >> ${_LOGFILE_}		  				
			else	      
				echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' A2 '|' STANDBY '(Sleep):' SoC≤$SoC_discharge% >> ${_LOGFILE_}																																												
		fi 
		counter_discharge_to_standby=0
		counter_standby_to_discharge=0     
	
	#====================================================================================================================
	# B1 # PVandHH ≥ dischargeStandbyThreshold_delay_int  AND SoC > SoC_discharge: AUSSPEICHERN nach Delay (Discharge)
	#====================================================================================================================	
	elif ( [ $PVandHH_int -ge $dischargeStandbyThreshold_delay_int ] && [ $SoC_int -gt $SoC_discharge ] ); then
		if [[ $Status == "noPVBuffering" ]]; then	  	  
				if [ $counter_standby_to_discharge -ge $counter_standby_to_discharge_max ]; then
						rm -f /home/admin/registry/noPVBuffering
						echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' B1 '|' AUSSPEICHERN - rm noPVBuffering >> ${_LOGFILE_}		  						
					else
						counter_standby_to_discharge=$(awk '{print $1+$2}' <<<"${counter_standby_to_discharge} ${counter_increment}")
						echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' B1 '|' STANDBY - Wartezeit vor AUSSPEICHERN: '('$counter_standby_to_discharge'/'$counter_standby_to_discharge_max')sec' >> ${_LOGFILE_}						
				fi
			else
				echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' B1 '|' AUSSPEICHERN >> ${_LOGFILE_}		  
				counter_standby_to_discharge=0     
		fi 
		counter_discharge_to_standby=0
	
	#====================================================================================================================
	# B2 # PVandHH ≥ dischargeStandbyThreshold_delay_int  AND SoC ≤ SoC_discharge: STANDBY (Sleep)
	#====================================================================================================================	
	elif ( [ $PVandHH_int -ge $dischargeStandbyThreshold_delay_int ] && [ $SoC_int -le $SoC_discharge ] ); then
		if [[ $Status == "PVBuffering" ]]; then
				touch /home/admin/registry/noPVBuffering
				echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' B2 '|' STANDBY '(Sleep):' SoC≤$SoC_discharge% - touch noPVBuffering >> ${_LOGFILE_}		  
			else	      
				echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' B2 '|' STANDBY '(Sleep):' SoC≤$SoC_discharge% >> ${_LOGFILE_}
		fi 
        counter_discharge_to_standby=0
        counter_standby_to_discharge=0 

	#====================================================================================================================
	# C1 # PVandHH ≥ dischargeStandbyThreshold_hyst_int  AND SoC > SoC_discharge: AUSSPEICHERN-Hysterse (Discharge)
	#====================================================================================================================	
	elif ( [ $PVandHH_int -ge $dischargeStandbyThreshold_hyst_int ] && [ $SoC_int -gt $SoC_discharge ] ); then
		if [[ $CPOL1_Mod == "1" ]]; then   
				# Inverter ON, - continue charging within the hysteresis
				echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' C1 '|' AUSSPEICHERN >> ${_LOGFILE_}			   
			else           
				echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' C1 '|' STANDBY >> ${_LOGFILE_}		           
		fi
		counter_discharge_to_standby=0
		counter_standby_to_discharge=0     	 
	 
	
	#====================================================================================================================
	# C2 # PVandHH ≥ dischargeStandbyThreshold_hyst_int  AND SoC ≤ SoC_discharge: STANDBY (Sleep)
	#====================================================================================================================	
	elif ( [ $PVandHH_int -ge $dischargeStandbyThreshold_hyst_int ] && [ $SoC_int -le $SoC_discharge ] ); then
     	if [[ $Status == "PVBuffering" ]]; then
				touch /home/admin/registry/noPVBuffering
				echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' C2 '|' STANDBY '(Sleep):' SoC≤$SoC_discharge% - touch noPVBuffering >> ${_LOGFILE_}		  
			else	      
				echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' C2 '|' STANDBY '(Sleep):' SoC≤$SoC_discharge% >> ${_LOGFILE_}
	    fi 
        counter_discharge_to_standby=0
        counter_standby_to_discharge=0	 

	
	#====================================================================================================================
	# D1 # PVandHH > 0: STANDBY 
	#====================================================================================================================		
	elif [ $PVandHH_int -gt 0 ]; then 
		if [[ $Status == "PVBuffering" ]]; then
				if [ $counter_discharge_to_standby -ge $counter_discharge_to_standby_max ]; then
					touch /home/admin/registry/noPVBuffering
					echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' D1 '|' STANDBY - touch noPVBuffering >> ${_LOGFILE_}			  
				else
					counter_discharge_to_standby=$(awk '{print $1+$2}' <<<"${counter_discharge_to_standby} ${counter_increment}")
					echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' D1 '|' AUSSPEICHERN - Nachlaufzeit vor STANDBY: '('$counter_discharge_to_standby'/'$counter_discharge_to_standby_max')sec' >> ${_LOGFILE_}
				fi
			else
				echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' D1 '|' STANDBY >> ${_LOGFILE_}		  
		fi  
		counter_standby_to_discharge=0

    
	#====================================================================================================================
	# D2 # PVandHH > chargeStandbyThreshold_hyst_int: STANDBY 
	#====================================================================================================================	
	elif [ $PVandHH_int -gt $chargeStandbyThreshold_hyst_int ]; then 
		if [[ $Status == "PVBuffering" ]]; then
				if [ $counter_discharge_to_standby -ge $counter_discharge_to_standby_max ]; then
					touch /home/admin/registry/noPVBuffering
					echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' D2 '|' STANDBY - touch noPVBuffering >> ${_LOGFILE_}			  
				else
					counter_discharge_to_standby=$(awk '{print $1+$2}' <<<"${counter_discharge_to_standby} ${counter_increment}")
					echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' D2 '|' EINSPEICHERN - Nachlaufzeit vor STANDBY: '('$counter_discharge_to_standby'/'$counter_discharge_to_standby_max')sec' >> ${_LOGFILE_}
				fi
			else
				echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' D2 '|' STANDBY >> ${_LOGFILE_}		  
		fi  
		counter_standby_to_discharge=0  	    
    
	#====================================================================================================================
	# E  # PVandHH > chargeStandbyThreshold_int: EINSPEICHERN-Hysterse (Charge)  
	#====================================================================================================================	
	elif [ $PVandHH_int -gt $chargeStandbyThreshold_int ]; then
		if [[ $CPOL1_Mod == "1" ]]; then
				if ( [[ $ChargedFlag == "1" ]] ); then
						if [[ $Status == "PVBuffering" ]]; then
								touch /home/admin/registry/noPVBuffering		       
								echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' E  '|' STANDBY - touch noPVBuffering >> ${_LOGFILE_}
							else
								echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' E  '|' STANDBY >> ${_LOGFILE_}
						fi
					else
						echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' E  '|' EINSPEICHERN >> ${_LOGFILE_}	
				fi          
			else
				echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' E  '|' STANDBY >> ${_LOGFILE_}	      	   
		fi	  
		counter_discharge_to_standby=0
		counter_standby_to_discharge=0		
   	#====================================================================================================================	   
      
   else
	#====================================================================================================================
	# F # PVandHH ≤ chargeStandbyThreshold_int: EINSPEICHERN (CHARGE)
	#====================================================================================================================
		if ( [[ $ChargedFlag == "-1" ]] || [[ $ChargedFlag == "0" ]] ); then
				if [[ $Status == "noPVBuffering" ]]; then
						rm -f /home/admin/registry/noPVBuffering		       
						echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' F  '|' EINSPEICHERN - rm noPVBuffering >> ${_LOGFILE_}
					else
						echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' F  '|' EINSPEICHERN >> ${_LOGFILE_}
				fi		  
			else
			# disable additional charging when reached the max value 'ChargedFlag'
				if [[ $Status == "PVBuffering" ]]; then		   	
						touch /home/admin/registry/noPVBuffering
						echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' F  '|' STANDBY - touch noPVBuffering >> ${_LOGFILE_}			       		                 
					else
						echo $time '||' Cell_Δ: $U_cell_diff_V mV '|' SoC_Δ: $SoC_module_diff % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' F  '|' STANDBY >> ${_LOGFILE_}			   
				fi	  		  
		fi	
		counter_discharge_to_standby=0
		counter_standby_to_discharge=0				
fi

sleep 0

# Verify if System is still activated, if not, - force shutdown
System_Activated=$(swarmBcSend "LLN0.Mod.ctlVal")
if ( [[ $System_Activated != "1" ]] ); then
	echo $(date +"%Y-%m-%d %T") '||' System - shutdown  - Status activation: $System_Activated anstelle von "1" >> ${_LOGFILE_}
	sudo shutdown -r now							
fi


done   

# Record System Status in log-File prior to restarting, force restart of BusinessOptimum
function_exit_and_start