#!/bin/bash
### BEGIN INFO
# Provides: Business Optimization
# Siegfried Quinger - VA10_2021-03-06_09.00
### END INFO


#-------------------------------------------------------------------------------------------------------------------
version="VA10_2021-03-06_09.00"
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
cat /home/admin/bin/nohup.out >> ${_LOGFILE_}
echo ------------------------------------------------------------------------ >> ${_LOGFILE_}
rm -f /home/admin/bin/nohup.out
touch /home/admin/bin/nohup.out
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_cleanup
# Clean up enivironment on exit
#-------------------------------------------------------------------------------------------------------------------
function function_Cleanup ()
{
# removes file noPVBuffering, -> charging/discharging possible for normal operation w/o BusinessOptimum
rm -f /home/admin/registry/noPVBuffering

# Remove status files of different functions of BusinessOptimum
rm -f /tmp/ChargedFlag
rm -f /tmp/BusinessOptimumStop
rm -f /tmp/BusinessOptimumActive
sshpass -p pi ssh pi@192.168.0.50 "rm -f /tmp/BusinessOptimumActive"
rm -f /tmp/ModuleBalancingActive
sshpass -p pi ssh pi@192.168.0.50 "rm -f /tmp/ModuleBalancingActive"
rm -f /tmp/CellBalancing
rm -f /tmp/CellBalancingActive
sshpass -p pi ssh pi@192.168.0.50 "rm -f /tmp/CellBalancingActive"
rm -f /tmp/ForcedChargingActive
sshpass -p pi ssh pi@192.168.0.50 "rm -f /tmp/ForcedChargingActive"
rm -f /tmp/BusinessOptimumGrid
sshpass -p pi ssh pi@192.168.0.50 "rm -f /tmp/BusinessOptimumGrid"
# Remove request files of ModuleBalancing of BusinessOptimum
rm -f /var/log/ModuleBalancing

# set back to normal operations, - needed when interrupted during forced charging, module balancing or grid operation
swarmBcSend "CPOL1.Wchrg.setMag.f=0" > /dev/null
swarmBcSend "CPOL1.OffsetDuration.setVal=1422692866" > /dev/null
swarmBcSend "CPOL1.OffsetStart.setVal=0" > /dev/null
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_exit_and_start
# Record System Status in log-File prior to restarting, force restart of BusinessOptimum
#-------------------------------------------------------------------------------------------------------------------
function function_exit_and_start ()
{
echo "" >> ${_LOGFILE_}
echo $(date +"%Y-%m-%d %T") '||' System nicht mehr betriebsbereit >> ${_LOGFILE_}
echo ------------------------------------------------------------------------------------------------ >> ${_LOGFILE_}
System_Initialization=$(swarmBcSend "LLN0.Init.stVal")
echo Systemzustandsabfrage 'LLN0.Init.stVal'... '"'$System_Initialization'"' >> ${_LOGFILE_}
System_Running=$(swarmBcSend "LLN0.Mod.stVal")
echo Systembetriebsabfrage 'LLN0.Mod.stVal'... '"'$System_Running'"' >> ${_LOGFILE_}

# Display / Print nohup.out
function_Print_nohup

echo $(date +"%Y-%m-%d %T") '||' System nicht mehr betriebsbereit - Abbruch >> ${_LOGFILE_}
echo ------------------------------------------------------------------------------------------------ >> ${_LOGFILE_}


# reset operation status: delete BusinessOptimumActive
rm -f /tmp/BusinessOptimumActive
sshpass -p pi ssh pi@192.168.0.50 "rm -f /tmp/BusinessOptimumActive"

# Restart only when BusinessOptimumStarter is not configured: Status: "0"
if [[ $BusinessOptimum_BOS == "0" ]]; then
echo $(date +"%Y-%m-%d %T") '||' BusinessOptimum wird neu gestartet >> ${_LOGFILE_}
echo "" >> ${_LOGFILE_}

# Re-Start BusinessOptimum
nohup /home/admin/bin/BusinessOptimum.sh &
fi
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_exit
# Exit BusinessOptimum when requested
function function_exit ()
{
if ( [ -f /tmp/BusinessOptimumStop ] ) ; then
echo "" >> ${_LOGFILE_}
echo $(date +"%Y-%m-%d %T") '||' Anforderung erhalten BusinessOptimum zu beenden.  >> ${_LOGFILE_}
# Clean up environment on exit
function_Cleanup
echo $(date +"%Y-%m-%d %T") '||' BusinessOptimum wurde kontrolliert beendet.  >> ${_LOGFILE_}
echo "" >> ${_LOGFILE_}
exit
fi
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
top -b -n 1 | grep haveged >> ${_LOGFILE_}
top -b -n 1 | grep monitor.sh >> ${_LOGFILE_}
top -b -n 1 | grep swarmcomm.sh >> ${_LOGFILE_}
p1=$(pidof -x agetty)
sudo pkill -SIGTERM agetty
p2=$(pidof -x agetty)
#echo $(date +"%Y-%m-%d %T") '||' agetty aktuell: $p1 '(PIDs)' '||' killed '||' agetty neu: $p2 '(PIDs)' >> ${_LOGFILE_}

if [[ $SystemSerial == "SN000168" ]]; then
sudo pkill -SIGTERM "swarmcomm.sh"
sudo pkill -SIGTERM haveged
sudo pkill -SIGTERM monitor.sh
top -b -n 1 | grep haveged >> ${_LOGFILE_}
top -b -n 1 | grep monitor.sh >> ${_LOGFILE_}
top -b -n 1 | grep swarmcomm.sh >> ${_LOGFILE_}
fi
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Timer_Minute
# Monitor time to initate certain functions (every minute)
#-------------------------------------------------------------------------------------------------------------------
function function_Timer_Minute ()
{
Timer_M_increment_int=0
printf -v date_S_int %.0f $(date +%S) # Second
if [ $Status_Timer_M_ini_int -eq 1 ]; then
# Timer_M --- Monitor time to initate certain functions (every minute)
if ( [ $date_S_int -ge 0 ] && [ $date_S_int -le 15 ] && [ $Status_Timer_M_int -eq 0 ] && [ $Timer_M_increment_int -eq 0 ] ); then
Timer_M_increment_int=$(awk '{print $1}' <<<"${Timer_M_increment_int}")
Status_Timer_M_int=1
fi
if ( [ $date_S_int -ge 16 ] && [ $Status_Timer_M_int -eq 1 ] ); then
Timer_M_increment_int=0
Status_Timer_M_int=0
Status_Timer_M_activated_int=0
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
printf -v date_M_int %.0f $(date +%M) # Minute
if [ $Status_Timer_H_ini_int -eq 1 ]; then
# Timer_H --- Monitor time to initate certain functions (every hour)
if ( [ $date_M_int -eq 0 ] && [ $Status_Timer_H_int -eq 0 ] ); then
Status_Timer_H_int=1
fi
if ( [ $date_M_int -eq 1 ] && [ $Status_Timer_H_int -eq 1 ] ); then
Status_Timer_H_int=0
Status_Timer_H_activated_int=0
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
# Convert floating/text to integer
printf -v U_cell_minV_int %.0f $U_cell_minV
printf -v U_cell_maxV_int %.0f $U_cell_maxV

# Safety: If BMU does not deliver a correct value (>0) repeat that step
while [ $U_cell_minV_int -le 0 ]; do
U_cell_minV=$(swarmBcSend "MBMS1.MinV.mag.f")
printf -v U_cell_minV_int %.0f $U_cell_minV
done

U_cell_diff_V_int=$(awk '{print $1-$2}' <<<"${U_cell_maxV_int} ${U_cell_minV_int}")
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Read__BMU_Current_SoC_Capa
# Read BMU_current_max / Capacity and SoC of all modules (for Gen2 only)
#-------------------------------------------------------------------------------------------------------------------
function function_Read__BMU_Current_SoC_Capa ()
{
# Determine actual current of BMU
BMU_current_max=$(swarmBcSend "MBMS1.MaxA.mag.f")
# Convert text to float
printf -v BMU_current_max_float %.3f $BMU_current_max
BMU_current_max=$(awk '{print ($1*1000)}' <<<"${BMU_current_max_float}")
# Convert floating/text to integer
printf -v BMU_current_max_int %.0f $BMU_current_max

# Read status of individual modules
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

# Convert floating/text to integer
printf -v SoC_module_BMU_int %.0f $SoC_module_BMU
printf -v SoC_module_1_int %.0f $SoC_module_1
printf -v SoC_module_2_int %.0f $SoC_module_2
printf -v SoC_module_3_int %.0f $SoC_module_3
printf -v SoC_module_4_int %.0f $SoC_module_4
printf -v SoC_module_5_int %.0f $SoC_module_5
printf -v SoC_module_6_int %.0f $SoC_module_6
printf -v SoC_module_7_int %.0f $SoC_module_7
printf -v SoC_module_8_int %.0f $SoC_module_8
printf -v SoC_module_9_int %.0f $SoC_module_9
printf -v SoC_module_10_int %.0f $SoC_module_10

#Determine the SoC difference of the individual modules
SoC_module_min_int=$SoC_module_BMU_int
SoC_module_max_int=$SoC_module_1_int
if [ $SoC_module_2_int -gt $SoC_module_max_int ]; then	SoC_module_max_int=$SoC_module_2_int; fi
if [ $SoC_module_3_int -gt $SoC_module_max_int ]; then	SoC_module_max_int=$SoC_module_3_int; fi
if [ $SoC_module_4_int -gt $SoC_module_max_int ]; then	SoC_module_max_int=$SoC_module_4_int; fi
if [ $SoC_module_5_int -gt $SoC_module_max_int ]; then	SoC_module_max_int=$SoC_module_5_int; fi
if [ $SoC_module_6_int -gt $SoC_module_max_int ]; then	SoC_module_max_int=$SoC_module_6_int; fi
if [ $SoC_module_7_int -gt $SoC_module_max_int ]; then	SoC_module_max_int=$SoC_module_7_int; fi
if [ $SoC_module_8_int -gt $SoC_module_max_int ]; then	SoC_module_max_int=$SoC_module_8_int; fi
if [ $SoC_module_9_int -gt $SoC_module_max_int ]; then	SoC_module_max_int=$SoC_module_9_int; fi
if [ $SoC_module_10_int -gt $SoC_module_max_int ]; then SoC_module_max_int=$SoC_module_10_int; fi
SoC_module_diff=$(awk '{print ($1-$2)/10}' <<<"${SoC_module_max_int} ${SoC_module_min_int}")
# Convert floating/text to integer
printf -v SoC_module_diff_int %.0f $SoC_module_diff

#Determine remaining and full capacity of BMU
tail -n 15 /tmp/swarm-battery-cmd.tmp | grep "rem" > /tmp/swarm-battery-cmd_tail.tmp
rem_capa_module_BMU=$(awk -F " " '{print $4}'    /tmp/swarm-battery-cmd_tail.tmp)
tail -n 15 /tmp/swarm-battery-cmd.tmp | grep "full" > /tmp/swarm-battery-cmd_tail.tmp
full_capa_module_BMU=$(awk -F " " '{print $4}'    /tmp/swarm-battery-cmd_tail.tmp)
# Convert floating/text to integer
printf -v rem_capa_module_BMU_int %.0f $rem_capa_module_BMU
printf -v full_capa_module_BMU_int %.0f $full_capa_module_BMU

capa_module_100=$(awk '{print (100*$1/$2)}' <<<"${rem_capa_module_BMU_int} ${full_capa_module_BMU_int}")
# Convert floating/text to integer
printf -v capa_module_100_int %.0f $capa_module_100
capa_module_100_int_low_int=$(awk '{print ($1-1)}' <<<"${capa_module_100_int}")

# Sum of all Soc_modules
SoC_total_int=$(awk '{print ($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)}' <<<"${SoC_module_1_int} ${SoC_module_2_int} ${SoC_module_3_int} ${SoC_module_4_int} ${SoC_module_5_int} ${SoC_module_6_int} ${SoC_module_7_int} ${SoC_module_8_int} ${SoC_module_9_int} ${SoC_module_10_int}")

# Determine remaining capacity for charging sequences
time_remaining_int=$(awk '{print ($1-$2)}' <<<"${time_limit_int} ${time_current_sec_epoch_int}")
capacity_remaining_int=$(awk '{print ($1-$2)}' <<<"${full_capa_module_BMU_minus_int} ${rem_capa_module_BMU_int}")

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
sleep 0.35
# 2nd reading of invoiceLog
tail -3 /var/log/invoiceLog.csv | grep -v "^#" | grep "20" | tail -1 > /var/log/invoiceLog_tail_2.csv
PV_2=$(awk -F ";" '{print $14}'    /var/log/invoiceLog_tail_2.csv)
HH_2=$(awk -F ";" '{print $15}'    /var/log/invoiceLog_tail_2.csv)
sleep 0.35
# 3rd reading of invoiceLog
tail -3 /var/log/invoiceLog.csv | grep -v "^#" | grep "20" | tail -1 > /var/log/invoiceLog_tail_3.csv
PV_3=$(awk -F ";" '{print $14}'    /var/log/invoiceLog_tail_3.csv)
HH_3=$(awk -F ";" '{print $15}'    /var/log/invoiceLog_tail_3.csv)
# Convert floating/text to integer
printf -v HH_1_int %.0f $HH_1
printf -v HH_2_int %.0f $HH_2
printf -v HH_3_int %.0f $HH_3
printf -v PV_1_int %.0f $PV_1
printf -v PV_2_int %.0f $PV_2
printf -v PV_3_int %.0f $PV_3

# Combine both PV and HH data to a complete set considerung +/- of Power "HH: +; PV: -"; calculate average of three measurements
PVandHH_1=$(awk '{print $1-$2}' <<<"${HH_1_int} ${PV_1_int}")
# Convert floating/text to integer
printf -v PVandHH_1_int %.0f $PVandHH_1
PVandHH_2=$(awk '{print $1-$2}' <<<"${HH_2_int} ${PV_2_int}")
# Convert floating/text to integer
printf -v PVandHH_2_int %.0f $PVandHH_2
PVandHH_3=$(awk '{print $1-$2}' <<<"${HH_3_int} ${PV_3_int}")
# Convert floating/text to integer
printf -v PVandHH_3_int %.0f $PVandHH_3
PVandHH=$(awk '{print ($1+$2+$3)/3}' <<<"${PVandHH_1_int} ${PVandHH_2_int} ${PVandHH_3_int}")
# Convert floating/text to integer
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
# function_secure__charge_discharge
# Ensures secure charging/discharging step of 15min
# CPOL1.OffsetStart.setVal set to current date; fixed time is used as a delay - 900sec
# based on that "secureDate_900s_int" is calculated;
# When "currentDate_int > secureDate_900s_int" Inverter will be adjusted to operate for additional 15 min.
# CPOL1.OffsetStart.setVal is set to current date again (new date)
# secure__charge_discharge_int=0;   set in sequence "rm -f /home/admin/registry/noPVBuffering", and start of balancing / forced charging
#-------------------------------------------------------------------------------------------------------------------
function function_secure__charge_discharge ()
{
# CPOL1.OffsetStart only driven by secure__charge_discharge_int=0 (900sec = 15min - status kept at "1")
printf -v currentDate_int %.0f $(date +%s) # Unix Epoch Time
if [ $secure__charge_discharge_int -eq 0 ]; then
swarmBcSend "CPOL1.OffsetStart.setVal=$currentDate_int"
secureDate_900s_int=$(awk '{print $1+900}' <<<"${currentDate_int}")
fi
difference_secureDates=$(awk '{print $1-$2}' <<<"${secureDate_900s_int} ${currentDate_int}")
secure__charge_discharge_int=1
if [ $currentDate_int -gt $secureDate_900s_int ]; then
secure__charge_discharge_int=0
fi
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Check_Inverter_ON
# Check status of inverter, - if not ON ("1") within 60s force shutdown
#-------------------------------------------------------------------------------------------------------------------
function function_Check_Inverter_ON ()
{
if [[ $CPOL1_Mod != "1" ]]; then
# activate device, if not yet activated: swarmBcSend "LLN0.Mod.ctlVal=1" > /dev/null
System_Activated=$(swarmBcSend "LLN0.Mod.ctlVal")
if [[ $System_Activated != "1" ]]; then
# activate system
swarmBcSend "LLN0.Mod.ctlVal=1" > /dev/null
echo $(date +"%Y-%m-%d %T") '||' System activated >> ${_LOGFILE_}
sleep 30
fi
echo $(date +"%Y-%m-%d %T") '||' 60s warten, damit sich der Umrichter aktivieren kann bzw noch aktiviert >> ${_LOGFILE_}
sleep 60
CPOL1_Mod=$(swarmBcSend "CPOL1.Mod.stVal")
if [[ $CPOL1_Mod != "1" ]]; then
echo $(date +"%Y-%m-%d %T") '||' System - shutdown --- System war nicht aktivierbar >> ${_LOGFILE_}
sudo shutdown -r now
echo $(date +"%Y-%m-%d %T") '||' '"shutdown -r now"' nicht möglich, deswegen wird forcierter Reboot eingeleitet  >> ${_LOGFILE_}
sudo reboot -f
fi
fi
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Check_Inverter_ON_charge_60_loops
# Check status of inverter, - if not ON ("1") after 60 loops force shutdown (4min ... 6min)
#-------------------------------------------------------------------------------------------------------------------
function function_Check_Inverter_ON_charge_60_loops ()
{
if ( [[ $CPOL1_Mod != "1" ]] && [ $loop_inverter_charge_int -lt 60 ] ); then
loop_inverter_charge_int=$(awk '{print $1+1}' <<<"${loop_inverter_charge_int}")
fi
if ( [[ $CPOL1_Mod != "1" ]] && [ $loop_inverter_charge_int -ge 60 ] ); then
echo $(date +"%Y-%m-%d %T") '||' System - shutdown --- EINSPEICHERN nicht mehr möglich seit für min. 4 min '(60 loops)'  >> ${_LOGFILE_}
sudo shutdown -r now
echo $(date +"%Y-%m-%d %T") '||' '"shutdown -r now"' nicht möglich, deswegen wird forcierter Reboot eingeleitet  >> ${_LOGFILE_}
sudo reboot -f
fi
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Check_Inverter_ON_discharge_60_loops
# Check status of inverter, - if not ON ("1") after 60 loops force shutdown (4min ... 6min)
#-------------------------------------------------------------------------------------------------------------------
function function_Check_Inverter_ON_discharge_60_loops ()
{
if ( [[ $CPOL1_Mod != "1" ]] && [ $loop_inverter_discharge_int -lt 60 ] ); then
loop_inverter_discharge_int=$(awk '{print $1+1}' <<<"${loop_inverter_discharge_int}")
fi
if ( [[ $CPOL1_Mod != "1" ]] && [ $loop_inverter_discharge_int -ge 60 ] ); then
echo $(date +"%Y-%m-%d %T") '||' System - shutdown --- AUSSPEICHERN nicht mehr möglich seit min. 4 min '(60 loops)'  >> ${_LOGFILE_}
sudo shutdown -r now
echo $(date +"%Y-%m-%d %T") '||' '"shutdown -r now"' nicht möglich, deswegen wird forcierter Reboot eingeleitet  >> ${_LOGFILE_}
sudo reboot -f
fi
}
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# function_Verify_Configuration
# Verify Configuration File and advice on changes
#-------------------------------------------------------------------------------------------------------------------
function function_Verify_Configuration ()
{
configuration_error_int=0
if [ $chargeStandbyThreshold_hyst_int -gt -400 ]; then
echo "P_in_W_chargeStandbyThreshold_hyst:    " '≤' '-400' '||' aktuell: $chargeStandbyThreshold_hyst_int >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
chargeStandbyThreshold_hyst_int=-1000
fi
if [ $chargeStandbyThreshold_int -ge $chargeStandbyThreshold_hyst_int ]; then
echo "P_in_W_chargeStandbyThreshold:         " '<' $chargeStandbyThreshold_hyst_int '||' aktuell: $chargeStandbyThreshold_int >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
chargeStandbyThreshold_int=-1500
fi
if [ $dischargeStandbyThreshold_hyst_int -lt 300 ]; then
echo "P_in_W_dischargeStandbyThreshold_hyst: " '≥' 300 '||' aktuell: $dischargeStandbyThreshold_hyst_int >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
dischargeStandbyThreshold_hyst_int=1000
fi
if [ $dischargeStandbyThreshold_delay_int -le $dischargeStandbyThreshold_hyst_int ]; then
echo "P_in_W_dischargeStandbyThreshold_delay:" '>' $dischargeStandbyThreshold_hyst_int '||' aktuell: $dischargeStandbyThreshold_delay_int >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
dischargeStandbyThreshold_delay_int=1500
fi
if [ $dischargeStandbyThreshold_int -le $dischargeStandbyThreshold_delay_int ]; then
echo "P_in_W_dischargeStandbyThreshold_delay:" '>' $dischargeStandbyThreshold_delay_int '||' aktuell: $dischargeStandbyThreshold_int >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
dischargeStandbyThreshold_int=2500
fi

if [ $SoC_max_config_int -gt 90 ]; then
echo "SoC_max:                               " '≤' 90 '||' aktuell: $SoC_max_config_int >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
SoC_max_config_int=90
fi
if [ $SoC_charge_config_int -ge $SoC_max_config_int ]; then
echo "SoC_charge:                            " '<' $SoC_max_config_int '||' aktuell: $SoC_charge_config_int >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
SoC_charge_config_int=80
fi
if [ $SoC_discharge_int -ge $SoC_charge_config_int ]; then
echo "SoC_discharge:                         " '<' $SoC_charge_config_int '||' aktuell: $SoC_discharge_int >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
SoC_discharge_int=23
fi
if [ $SoC_discharge_int -lt 20 ]; then
echo "SoC_discharge:                         " '≥' 20 '||' aktuell: $SoC_discharge_int >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
SoC_discharge_int=23
fi
if [ $SoC_min_int -ge $SoC_discharge_int ]; then
echo "SoC_min:                               " '<' $SoC_discharge_int '||' aktuell: $SoC_min_int >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
SoC_min_int=18
fi
if [ $SoC_min_int -lt 10 ]; then
echo "SoC_min:                               " '≥' 10 '||' aktuell: $SoC_min_int >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
SoC_min_int=18
fi
if [ $SoC_err_int -ne 0 ]; then
echo "SoC_err:                               " '==' 0 '||' aktuell: $SoC_err_int >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
SoC_err_int=0
fi

if ( [ $counter_increment_int -lt 3 ] || [ $counter_increment_int -gt 6 ] ); then
echo "counter_increment_int:                 " 3 ... 6 '||' aktuell: $counter_increment_int >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
counter_increment_int=4
fi
if ( [ $loop_delay_int -lt 0 ] || [ $loop_delay_int -gt 30 ] ); then
echo "loop_delay_int:                        " 0 ... 30 '||' aktuell: $loop_delay_int >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
loop_delay_int=0
fi

if [ $counter_discharge_to_standby_max_int -lt $counter_increment_total_int ]; then
echo "counter_discharge_to_standby_max:      " '≥' $counter_increment_total_int  '||' aktuell: $counter_discharge_to_standby_max_int >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
counter_discharge_to_standby_max_int=60
fi

if [ $counter_standby_to_discharge_max_int -lt $counter_increment_total_int ]; then
echo "counter_standby_to_discharge_max_int:  " '≥' $counter_increment_total_int  '||' aktuell: $counter_standby_to_discharge_max_int >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
counter_standby_to_discharge_max_int=60
fi

if [[ $system_initialization_req != "1112" ]]; then
if [[ $system_initialization_req != "112" ]]; then
echo "System_Initialization:                 " 1112 oder 112 '||' aktuell: $system_initialization_req >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
system_initialization_req="1112"
fi
fi
if [[ $ECS3_configuration != "PVHH" ]]; then
echo ECS3 Configuration: PVHH '||' aktuell: $ECS3_configuration >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
ECS3_configuration="PVHH"
fi
if [[ $BusinessOptimum_BOS != "0" ]]; then
if [[ $BusinessOptimum_BOS != "1" ]]; then
echo "BusinessOptimum_BOS:                   " 0 oder 1 '||' aktuell: $BusinessOptimum_BOS >> ${_LOGFILE_}
configuration_error_int=1
# set to standard configuration
BusinessOptimum_BOS="0"
fi
fi

if [ $configuration_error_int -eq 1 ]; then
echo "" >> ${_LOGFILE_}
echo Konfiguration war nicht ok, deswegen wird nun für einige Parameter eine Standardkonfiguration geladen >> ${_LOGFILE_}

# Set the timer/counter based on execution time of loop and requested delay (loop_delay)
counter_increment_total_int=$(awk '{print $1+$2}' <<<"${counter_increment_int} ${loop_delay_int}")

# function_Print_Configuration
function_Print_Configuration
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
echo "P_in_W_chargeStandbyThreshold:         " $chargeStandbyThreshold_int W >> ${_LOGFILE_}
echo "P_in_W_chargeStandbyThreshold_hyst:    " $chargeStandbyThreshold_hyst_int W >> ${_LOGFILE_}
echo "P_in_W_dischargeStandbyThreshold:       " $dischargeStandbyThreshold_int W >> ${_LOGFILE_}
echo "P_in_W_dischargeStandbyThreshold_delay: " $dischargeStandbyThreshold_delay_int W >> ${_LOGFILE_}
echo "P_in_W_dischargeStandbyThreshold_hyst:  " $dischargeStandbyThreshold_hyst_int W >> ${_LOGFILE_}
echo "SoC_max:                                " $SoC_max_config_int % >> ${_LOGFILE_}
echo "SoC_charge:                             " $SoC_charge_config_int % >> ${_LOGFILE_}
echo "SoC_discharge:                          " $SoC_discharge_int % >> ${_LOGFILE_}
echo "SoC_min:                                " $SoC_min_int % >> ${_LOGFILE_}
echo "SoC_err:                                " $SoC_err_int % >> ${_LOGFILE_}
echo "counter_discharge_to_standby_max:       " $counter_discharge_to_standby_max_int s >> ${_LOGFILE_}
echo "counter_standby_to_discharge_max:       " $counter_standby_to_discharge_max_int s >> ${_LOGFILE_}
echo "counter_increment:                      " $counter_increment_int s per loop without additional delay >> ${_LOGFILE_}
echo "loop_delay:                             " $loop_delay_int s '('additional delay until rescan')' >> ${_LOGFILE_}
echo "counter_increment_total:                " $counter_increment_total_int s '('complete loop time, rescan every $counter_increment_total_int s')' >> ${_LOGFILE_}
echo "system_initialization:                  " $system_initialization_req >> ${_LOGFILE_}
echo "ECS3_configuration:                     " $ECS3_configuration >> ${_LOGFILE_}
echo "BusinessOptimum:                        " $BusinessOptimum_BOS '('0: stand-alone // 1: BusinessOptimumStarter necessary')' >> ${_LOGFILE_}
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
loop_delay=$(awk -F ";" '{print $14}' /tmp/BusinessOptimum.tmp)
system_initialization_req=$(awk -F ";" '{print $15}' /tmp/BusinessOptimum.tmp)
ECS3_configuration=$(awk -F ";" '{print $16}' /tmp/BusinessOptimum.tmp)
BusinessOptimum_BOS=$(awk -F ";" '{print $17}' /tmp/BusinessOptimum.tmp)

# Convert floating/text to integer
printf -v chargeStandbyThreshold_int %.0f $chargeStandbyThreshold
printf -v chargeStandbyThreshold_hyst_int %.0f $chargeStandbyThreshold_hyst
printf -v dischargeStandbyThreshold_int %.0f $dischargeStandbyThreshold
printf -v dischargeStandbyThreshold_delay_int %.0f $dischargeStandbyThreshold_delay
printf -v dischargeStandbyThreshold_hyst_int %.0f $dischargeStandbyThreshold_hyst
printf -v SoC_max_config_int %.0f $SoC_max_config
printf -v SoC_charge_config_int %.0f $SoC_charge_config
printf -v SoC_discharge_int %.0f $SoC_discharge
printf -v SoC_min_int %.0f $SoC_min
printf -v SoC_err_int %.0f $SoC_err
printf -v counter_discharge_to_standby_max_int %.0f $counter_discharge_to_standby_max
printf -v counter_standby_to_discharge_max_int %.0f $counter_standby_to_discharge_max
printf -v counter_increment_int %.0f $counter_increment
printf -v loop_delay_int %.0f $loop_delay
# Set the timer/counter based on execution time of loop and requested delay (loop_delay)
counter_increment_total_int=$(awk '{print $1+$2}' <<<"${counter_increment_int} ${loop_delay_int}")
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
cp -f ${_BO_ConfigFILE_} /tmp/BusinessOptimum.config
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



#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
# Array of System Serialnumbers
#-------------------------------------------------------------------------------------------------------------------
SystemSerial_array=( SN000044 SN000068 SN000109 SN000135 SN000168 SN000173 SN000198 SN000230 SN000245 )
#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------


#===================================================================================================================
#===================================================================================================================
#===================================================================================================================
sleep 5
echo ==================================================================================================================================================== >> ${_LOGFILE_}
# Display / Print nohup.out
function_Print_nohup

SystemSerial=$(cat /home/admin/registry/out/serial)
MatchSystemSerial=0
# echo $SystemSerial >> ${_LOGFILE_}
for i in "${SystemSerial_array[@]}"; do
# echo "$i" >> ${_LOGFILE_}
if  [[ $SystemSerial == $i ]]; then
MatchSystemSerial_int=1
fi
done
# echo $MatchSystemSerial >> ${_LOGFILE_}
if [ $MatchSystemSerial_int -eq	0 ]; then
echo $SystemSerial ist nicht Teil der Testphase >> ${_LOGFILE_}
rm -f ${_LOGFILE_}
rm -f /home/admin/bin/BusinessOptimum.sh
exit
fi
#===================================================================================================================
#===================================================================================================================
#===================================================================================================================
#===================================================================================================================


trap 'function_Cleanup ; exit' 1 2 15


# Start loadTools to ensure that exported variables are supported
source /home/admin/bin/loadTools

# Remove temporarily established file of BusinessOptimum
rm -f /tmp/ChargedFlag
rm -f /tmp/BusinessOptimumStop
rm -f /tmp/BusinessOptimumActive
sshpass -p pi ssh pi@192.168.0.50 "rm -f /tmp/BusinessOptimumActive"
rm -f /tmp/ModuleBalancingActive
sshpass -p pi ssh pi@192.168.0.50 "rm -f /tmp/ModuleBalancingActive"
rm -f /tmp/CellBalancing
rm -f /tmp/CellBalancingActive
sshpass -p pi ssh pi@192.168.0.50 "rm -f /tmp/CellBalancingActive"
rm -f /tmp/ForcedChargingActive
sshpass -p pi ssh pi@192.168.0.50 "rm -f /tmp/ForcedChargingActive"
rm -f /tmp/BusinessOptimumGrid
sshpass -p pi ssh pi@192.168.0.50 "rm -f /tmp/BusinessOptimumGrid"

rm -f /tmp/BusinessOptimum.tmp
rm -f /tmp/balanceBatteryModules.tmp
rm -f /tmp/swarm-battery-cmd.tmp
rm -f /tmp/swarm-battery-cmd_tail.tmp
rm -f /tmp/BusinessOptimum_config.tmp
rm -f /tmp/BusinessOptimum_config_tail.tmp
rm -f /tmp/BusinessOptimum.config
# Remove any files hindering to execute BusinessLogic
rm -f /home/admin/registry/businessLogic
rm -f /home/admin/registry/chargeStandbyThreshold
rm -f /home/admin/registry/dischargeStandbyThreshold



# Reduce CPU load: eliminate processes not needed
# 40-updates (requires a reboot, however not enforced, as this will anyhow once take place....
if [ -f /etc/update-motd.d/40-updates ]; then
sudo mv /etc/update-motd.d/40-updates /etc/update-motd.d/40-updates_old
fi


# Read configuration data of BusinessOptimum.config
function_Read_Configuration


# Initialize Status
counter_discharge_to_standby_int=0	# pre-set value for counter_discharge_to_standby
counter_standby_to_discharge_int=0	# pre-set value for counter_standby_to_discharge
counter_SoC_err_int=0				# pre-set value for counter_SoC_err:				Counts sequeneces of consecutive lines with SoC_err
counter_int=0						# pre-set value for counter:						System-Status Counter
counter_forced_charging_int=0		# pre-set value for counter_forced_charging:		Counts events of performed << forced charging >> routines
CellBalancing_int=0					# pre-set value for CellBalancing:	 				'0' CellBalancing not active // '1' CellBalancing active
CellBalancingRequest_int=0			# pre-set value for CellBalancingRequest:			'0' CellBalancing not requested // '1' CellBalancing requested
ForcedCharging_int=0				# pre-set value for ForcedCharging: 				'0' ForcedCharging not active // '1' ForcedCharging active
System_Running="0"					# pre-set value for System_Running:					'0' System not runing // '1' System running
system_running_req="1"				# pre-set value for normal systems running			# when initalization "112" is used, this will be switched to "9"
Status_Timer_M_int=1  				# pre-set value for Status_Timer_M:					'0' Timer_M sequence deactivated  // '1' Timer_M sequence activated
Status_Timer_M_activated_int=0		# pre-set value for Status_Timer_M_activated:		'0' Status_Timer_M_activated recently NOT activated  // '1' Status_Timer_M_activated recently activated
Status_Timer_M_ini_int=0			# pre-set value for Status_Timer_M_ini:				'0' executes related functions which would be exeuted if Timer_M active
Status_Timer_H_int=1  				# pre-set value for Status_Timer_H:					'0' Timer_H sequence deactivated  // '1' Timer_H sequence activated
Status_Timer_H_activated_int=0		# pre-set value for Status_Timer_H_activated:		'0' Status_Timer_H_activated recently NOT activated  // '1' Status_Timer_H_activated recently activated
Status_Timer_H_ini_int=0			# pre-set value for Status_Timer_H_ini:				'0' executes related functions which would be exeuted if Timer_H active
SoC_module_diff_int=999				# pre-set value for SoC_module_diff:				to display "xxx" if Gen1 system is detected
capa_module_100_int=999				# pre-set value for capa_module_100_int:			to display "xxx" if Gen1 system is detected
U_cell_minV_int=0					# pre-set value for U_cell_minV:					min Voltage of BMU cell
U_cell_maxV_int=0					# pre-set value for U_cell_maxV:					max Voltage of BMU cell
U_cell_diff_V_int=0					# pre-set value for U_cell_diff_V:					difference Voltage of BMU cell
start_up__count_int=500				# start-up__time									during this period system should be up and running
loop_inverter_charge_int=0		    # pre-set value for loop_inverter_scharge			0 set when initially noPVBufferingis removed, counts for charge issues
loop_inverter_discharge_int=0		# pre-set value for loop_inverter_discharge			0 set when initially noPVBufferingis removed, counts for discharge issues
secure__charge_discharge_int=0		# pre-set value for secure__charge_discharge		0 (CPOL1.OffsetStart will be set to current time); 1 (during specified time CPOL1.OffsetStart will be kept)


if [ -f /home/admin/registry/out/bmmType ]; then
bmmType=$(cat /home/admin/registry/out/bmmType)
else
bmmType="unknown"
fi

if ( [ -f /home/admin/registry/out/gen2 ] && [[ $bmmType == "sony" ]] ); then
U_cell_minV_min_forced_enable_int=2900	# set-value for U_cell_minV_int:					Threshold when forced charging needed
U_cell_minV_min_forced_disable_int=3000	# set-value for U_cell_minV_int:					Threshold when forced charging is disabled
else # Data for SAFT Batteries to be adjusted
U_cell_minV_min_forced_enable_int=0		# set-value for U_cell_minV_int:					Threshold when forced charging needed
U_cell_minV_min_forced_disable_int=0	# set-value for U_cell_minV_int:					Threshold when forced charging is disabled
#U_cell_minV_min_forced_enable_int=3400	# set-value for U_cell_minV_int:					Threshold when forced charging needed
#U_cell_minV_min_forced_disable_int=3450	# set-value for U_cell_minV_int:					Threshold when forced charging is disabled
fi


# Initialize "/tmp/ChargedFlag" depending on current SoC
# Save last line of batteryLog --- Read data from batteryLog: SoC
tail -3 /var/log/batteryLog.csv | grep -v "^#" | grep "20" | tail -1 > /var/log/batteryLog_tail.csv
SoC=$(awk -F ";" '{print $6}'  /var/log/batteryLog_tail.csv)
# Convert floating/text to integer
printf -v SoC_int %.0f $SoC
# preset based on SoC
if [ $SoC_int -le $SoC_min_int ]; then
echo "-1" > /tmp/ChargedFlag      ## discharging disabled / charching enabled
elif  [ $SoC_int -gt $SoC_charge_config_int ] ; then
echo "1" > /tmp/ChargedFlag       ## discharging enabled / charching disabled
else
echo "0" > /tmp/ChargedFlag       ## discharging enabled / charching enabled
fi
# set Chargedflag based on existing file content
ChargedFlag=$(cat /tmp/ChargedFlag)


# Log configuration data in BusinessOptimum.log
function_Print_Configuration

# Verify Configuration File and advice on changes
function_Verify_Configuration


# Read Genx configuration
if [ -f /home/admin/registry/out/gen2 ]; then
echo "System:                                  Gen2" >> ${_LOGFILE_}
else
echo "System:                                  Gen1" >> ${_LOGFILE_}
fi
echo "BMMType:                                " $bmmType >> ${_LOGFILE_}
echo "" >> ${_LOGFILE_}


# Change system_running_req when system does not maintain communication with swarm
if [[ $system_initialization_req == "112" ]]; then
system_running_req="9"
fi

# Start functions of BusinessOptimum only when System is available/active
System_Initialization=$(swarmBcSend "LLN0.Init.stVal")
echo "Systemzustandsabfrage        LLN0.Init.stVal... "'"'$System_Initialization'"' >> ${_LOGFILE_}
while ( ( [[ $System_Initialization != $system_initialization_req ]] || [ -z "$System_Initialization" ] ) && ( [ $counter_int -le $start_up__count_int ] ) ); do
# Exit BusinessOptimum when requested
function_exit

if ( [[ $System_Initialization != $system_initialization_req ]] || [ -z "$System_Initialization" ] ); then
echo $(date +"%Y-%m-%d %T") '||' System noch nicht betriebsbereit  '('$counter_int'/'$start_up__count_int')' '||' '['$system_initialization_req':'$System_Initialization']' >> ${_LOGFILE_}
counter_int=$(awk '{print ($1+5)}' <<<"${counter_int}")
sleep 5
fi
System_Initialization=$(swarmBcSend ""LLN0.Init.stVal"")
done
echo "-> Systemzustandsabfrage     LLN0.Init.stVal... "'"'$System_Initialization'"' >> ${_LOGFILE_}
if [ $counter_int -ge $start_up__count_int ]; then
echo $(date +"%Y-%m-%d %T") '||' System - shutdown >> ${_LOGFILE_}
sleep 10
sudo shutdown -r now
sudo reboot -f
fi

counter_int=0
System_Activated=$(swarmBcSend "LLN0.Mod.ctlVal")
echo "Systemaktivierungsabfrage    LLN0.Mod.ctlVal... "'"'$System_Activated'"' >> ${_LOGFILE_}
while ( [[ $System_Activated != "1" ]] && [ $counter_int -le $start_up__count_int ] ); do
# Exit BusinessOptimum when requested
function_exit

if [[ $System_Activated != "1" ]]; then
echo $(date +"%Y-%m-%d %T") '||' System noch nicht aktiviert  '('$counter_int'/'$start_up__count_int')' '||' '[''1:'$$System_Activated']' >> ${_LOGFILE_}
counter_int=$(awk '{print ($1+5)}' <<<"${counter_int}")
sleep 5
fi
System_Activated=$(swarmBcSend "LLN0.Mod.ctlVal")
done
echo "-> Systemaktivierungsabfrage LLN0.Mod.ctlVal... "'"'$System_Activated'"' >> ${_LOGFILE_}
if [ $counter_int -ge $start_up__count_int ]; then
echo $(date +"%Y-%m-%d %T") '||' System - shutdown >> ${_LOGFILE_}
sleep 10
sudo shutdown -r now
sudo reboot -f
fi

counter_int=0
System_Running=$(swarmBcSend "LLN0.Mod.stVal")
echo "Systembetriebsabfrage        LLN0.Mod.stVal.... "'"'$System_Running'"' >> ${_LOGFILE_}
while ( [[ $System_Running != $system_running_req ]] && [ $counter_int -le $start_up__count_int ] ); do
# Exit BusinessOptimum when requested
function_exit

if [[ $System_Running != $system_running_req ]]; then
echo $(date +"%Y-%m-%d %T") '||' System noch nicht betriebsbereit  '('$counter_int'/'$start_up__count_int')' '||' '['$system_running_req':'$System_Running']' >> ${_LOGFILE_}
counter_int=$(awk '{print ($1+5)}' <<<"${counter_int}")
sleep 5
fi
System_Running=$(swarmBcSend "LLN0.Mod.stVal")
done
echo "-> Systembetriebsabfrage     LLN0.Mod.stVal.... "'"'$System_Running'"' >> ${_LOGFILE_}
if [ $counter_int -ge $start_up__count_int ]; then
echo $(date +"%Y-%m-%d %T") '||' System - shutdown >> ${_LOGFILE_}
sleep 10
sudo shutdown -r now
sudo reboot -f
fi
echo "" >> ${_LOGFILE_}
echo System betriebsbereit und aktiviert >> ${_LOGFILE_}


# CPOL: set back to normal operations
function_CPOL_Reset


# Display / Print Battery Status
if ( [ -f /home/admin/registry/out/gen2 ] && [[ $bmmType == "sony" ]] ); then
echo "" >> ${_LOGFILE_}
echo Aktueller Status Batteriemodule >> ${_LOGFILE_}
echo ------------------------------- >> ${_LOGFILE_}
function_Print_Battery_Status_1338
fi

# Read time, PVandHH, INV, SoC (invoice and battery log)
function_Read__Logs_Time_PVHH_INV_SoC

# Copy BusinessOptimum.config to temp file for comparison of changes
cp -f ${_BO_ConfigFILE_} /tmp/BusinessOptimum.config





#===================================================================================================================
#==== MAIN ROUTINE =================================================================================================
#===================================================================================================================
while ( [[ $System_Initialization == $system_initialization_req ]] && [[ $System_Running == $system_running_req ]] ); do

# Exit BusinessOptimum when requested
function_exit

# set operation status: BusinessOptimumActive
touch /tmp/BusinessOptimumActive
sshpass -p pi ssh pi@192.168.0.50 "touch /tmp/BusinessOptimumActive"

# Verify if ModuleBalancing shall be started
if [ -f /var/log/ModuleBalancing ]; then
counter_forced_charging_int=3 					# set counter to 3, whereas ModuleBalancing will be started
fi
# Verify if CellBalancing shall be started
if [ -f /tmp/CellBalancing ]; then
CellBalancingRequest_int=1
fi


printf -v date_S_int %.0f $(date +%S) # Second
printf -v date_M_int %.0f $(date +%M) # Minute
printf -v date_H_int %.0f $(date +%H) # Hour
printf -v date_w_int %.0f $(date +%u) # weekday

# Monitor time to initate certain functions (every Monday at 00:00) - back-up BusinessOptimum.log and start with new BusinessOptimum-old.log
if ( [ $date_w_int -eq 1 ] && [ $date_H_int -eq 0 ] && [ $date_M_int -eq 0 ] && [ $date_S_int -le 30 ] ); then
rm -f /home/admin/log/BusinessOptimum-old.log
cp -f ${_LOGFILE_} /home/admin/log/BusinessOptimum-old.log
rm -f ${_LOGFILE_}

# Log configuration data in new BusinessOptimum.log
function_Print_Configuration

# Wait until safely files are copied and removed
sleep 30
fi


# Monitor time to initate certain functions (every hour)
function_Timer_Hour

# Kill processes every hour
if ( [ $Status_Timer_H_int -eq 1 ] && [ $Status_Timer_H_activated_int -eq 0 ] ); then
# Kill processes
function_Kill_processes

Status_Timer_H_activated_int=1
if [ $Status_Timer_H_ini_int -eq 0 ]; then
Status_Timer_H_ini_int=1
Status_Timer_H_int=0
Status_Timer_H_activated_int=0
fi
fi


# Monitor time to initate certain functions (every minute)
function_Timer_Minute

# Monitor changes on .config / Display "BMU_current_max / Capacity and SoC of all modules" and "check on bigger SoC changes every minute"
if ( [ $Status_Timer_M_int -eq 1 ] && [ $Status_Timer_M_activated_int -eq 0 ] ); then
# Update Configuration when BusinessOptimum.config was changed
function_Compare_Configuration

# Scan of System Status
System_Initialization=$(swarmBcSend "LLN0.Init.stVal")
System_Running=$(swarmBcSend "LLN0.Mod.stVal")

# Verify if System is still activated, if not, - force shutdown
System_Activated=$(swarmBcSend "LLN0.Mod.ctlVal")
if [[ $System_Activated != "1" ]]; then
echo $(date +"%Y-%m-%d %T") '||' System - shutdown  - Status activation: $System_Activated anstelle von "1" >> ${_LOGFILE_}
sudo shutdown -r now
sudo reboot -f
fi


# Read cell voltage min/max
function_Read__Cell_Voltage

if ( [ -f /home/admin/registry/out/gen2 ] && [[ $bmmType == "sony" ]] ); then
# Read BMU_current_max / Capacity and SoC of all modules (for Gen2 only)
function_Read__BMU_Current_SoC_Capa
echo '                    ||' BMU-SoC: $SoC_module_BMU '|' $SoC_module_1_int $SoC_module_2_int $SoC_module_3_int $SoC_module_4_int $SoC_module_5_int $SoC_module_6_int $SoC_module_7_int $SoC_module_8_int $SoC_module_9_int $SoC_module_10_int '|' Σ: $SoC_total_int '||' BMU_Kapazität: $rem_capa_module_BMU_int mAh '(' $full_capa_module_BMU_int mAh ') ||' Zell-Spannung: $U_cell_minV_int mV '|' BMU-Strom: $BMU_current_max_int mA >> ${_LOGFILE_}
fi
# Identify SoC-Sprünge when comparing with the actual capacity
if [ $SoC_int -lt $capa_module_100_int_low_int ]; then
echo SoC-Sprung: SoC: $SoC_int % '|' SoC_Δ: $SoC_module_diff_int % '|' Capacity: $capa_module_100_int_low_int % >> ${_LOGFILE_}
fi

Status_Timer_M_activated_int=1
if [ $Status_Timer_M_ini_int -eq 0 ]; then
Status_Timer_M_ini_int=1
Status_Timer_M_int=0
Status_Timer_M_activated_int=0
fi
fi


# Correct original settings of SoC_max and SoC_charge considering the disbalance of the modules (SoC_module_diff)
if ( [ -f /home/admin/registry/out/gen2 ] && [[ $bmmType == "sony" ]] ); then
SoC_max_int=$(awk '{print $1-$2}' <<<"${SoC_max_config_int} ${SoC_module_diff_int}")
SoC_charge_int=$(awk '{print $1-$2}' <<<"${SoC_charge_config_int} ${SoC_module_diff_int}")
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
if ( [ $SoC_int -le $SoC_err_int ] && [ $counter_SoC_err_int -lt 10 ] ); then
counter_SoC_err_int=$(awk '{print $1+1}' <<<"${counter_SoC_err_int}")
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|'   '|' SoC observed with '≤' $SoC_err_int %: $counter_SoC_err_int'/'10 >> ${_LOGFILE_}
continue
else
counter_SoC_err_int=0
fi


# Set/Reset ChargedFlag: 1 '(fully charged -> no charging possible)' -> 0 '(partially charged -> charging possible)'
# 						-1 '(empty -> charging is forced)'
if [ $SoC_int -ge $SoC_max_int ]; then
echo "1" > /tmp/ChargedFlag      ## stop charging
fi
if ( [ $SoC_int -gt $SoC_min_int ] && [ $SoC_int -le $SoC_charge_int ] && [[ $ChargedFlag == "1" ]] ); then
echo "0" > /tmp/ChargedFlag      ## enable charging/discharing
fi
if ( [ $SoC_int -ge $SoC_discharge_int ] && [ $SoC_int -le $SoC_charge_int ] && [[ $ChargedFlag == "-1" ]] ); then
echo "0" > /tmp/ChargedFlag      ## enable charging/discharing
fi
if [ $SoC_int -le $SoC_min_int ] ; then
echo "-1" > /tmp/ChargedFlag     ## enable forced charging
fi
# set Chargedflag based on existing file content (changed conditions of previous settings)
ChargedFlag=$(cat /tmp/ChargedFlag)


#====================================================================================================================
#====================================================================================================================
# Z  # ChargedFlag = -1 (Battery empty): NACHLADEN (FORCED CHARGING) < SoC_discharge ODER < U_cell_minV_min_forced_enable
#====================================================================================================================
#====================================================================================================================


if ( ( [[ $ChargedFlag == "-1" ]] && [ $PVandHH_int -gt $chargeStandbyThreshold_hyst_int ] ) || [ $U_cell_minV_int -le $U_cell_minV_min_forced_enable_int ] ); then
		# Display / Print Battery Status
		echo "" >> ${_LOGFILE_}
		echo SoC $SoC_int % '<' $SoC_discharge_int % '('Initialisierungsphase')' >> ${_LOGFILE_}
		echo SoC $SoC_int % '≤' $SoC_min_int % bzw. Zell-Spannung zu niedrig $U_cell_minV_int mV '≤' $U_cell_minV_min_forced_enable_int mV ? >> ${_LOGFILE_}
		echo -------------------------------------------------------------------------------------------------- >> ${_LOGFILE_}
		if ( [ -f /home/admin/registry/out/gen2 ] && [[ $bmmType == "sony" ]] ); then
			echo Aktueller Status Batteriemodule: >> ${_LOGFILE_}
			echo -------------------------------- >> ${_LOGFILE_}
			function_Print_Battery_Status_1338
		fi

# Due to safety reasons in case charging would not start: Avoid discharging
touch /home/admin/registry/noPVBuffering

# Start charging the battery only up to SoC_discharge, and when available
System_Running=$(swarmBcSend "LLN0.Mod.stVal")
if [[ $System_Running != $system_running_req ]]; then
echo System ist NICHT betriebsbereit, Laden wird nicht gestartet  >> ${_LOGFILE_}
echo ----------------------------------------------------------- >> ${_LOGFILE_}
# Record System Status in log-File prior to restarting, force restart of BusinessOptimum
function_exit_and_start
else
echo System ist betriebsbereit, Nachladen wird gestartet - min. 10 min  >> ${_LOGFILE_}
echo ---------------------------------------------------------------- >> ${_LOGFILE_}
# set charge command
swarmBcSend "CPOL1.Wchrg.setMag.f=5555" > /dev/null

# 1111sec - 18min - greater than 900sec used for function_secure__charge_discharge
swarmBcSend "CPOL1.OffsetDuration.setVal=1111" > /dev/null
secure__charge_discharge_int=0

ForcedCharging_int=1
fi

# set operation status: ForcedChargingActive
touch /tmp/ForcedChargingActive
sshpass -p pi ssh pi@192.168.0.50 "touch /tmp/ForcedChargingActive"


printf -v time_current_sec_epoch_int %.0f $(date +%s) # Unix Epoch Time
time_offset_sec_int=600 # 10min
time_limit_int=$(awk '{print ($1+$2)}' <<<"${time_current_sec_epoch_int} ${time_offset_sec_int}")

while ( [ $SoC_int -lt $SoC_discharge_int ] || [ $U_cell_minV_int -le $U_cell_minV_min_forced_disable_int ] || [ $time_current_sec_epoch_int -le $time_limit_int ] ); do

# Exit BusinessOptimum when requested
function_exit

# Ensures secure charging/discharging step of 15min
function_secure__charge_discharge

# Monitor time to initate certain functions (every minute)
function_Timer_Minute

# Read cell voltage min/max, BMU_current_max and SoC of all modules (SoC/capacity for Gen2 only)
if ( [ $Status_Timer_M_int -eq 1 ] && [ $Status_Timer_M_activated_int -eq 0 ] ); then

# Read cell voltage min/max
function_Read__Cell_Voltage

if ( [ -f /home/admin/registry/out/gen2 ] && [[ $bmmType == "sony" ]] ); then
# Read BMU_current_max / Capacity and SoC of all modules (for Gen2 only)
function_Read__BMU_Current_SoC_Capa
echo '                    ||' BMU-SoC: $SoC_module_BMU '|' $SoC_module_1_int $SoC_module_2_int $SoC_module_3_int $SoC_module_4_int $SoC_module_5_int $SoC_module_6_int $SoC_module_7_int $SoC_module_8_int $SoC_module_9_int $SoC_module_10_int '|' Σ: $SoC_total_int '||' BMU_Kapazität: $rem_capa_module_BMU_int mAh '(' $full_capa_module_BMU_int mAh ') ||' Zell-Spannung: $U_cell_minV_int mV '|' BMU-Strom: $BMU_current_max_int mA  >> ${_LOGFILE_}
fi

Status_Timer_M_activated_int=1

if [ $Status_Timer_M_ini_int -eq 0 ]; then
Status_Timer_M_ini_int=1
Status_Timer_M_int=0
Status_Timer_M_activated_int=0
fi
fi

# Read time, PVandHH, INV, SoC (invoice and battery log)
function_Read__Logs_Time_PVHH_INV_SoC

echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' Z '|' Nachladen >> ${_LOGFILE_}
sleep 1
printf -v time_current_sec_epoch_int %.0f $(date +%s) # Unix Epoch Time

# Check status of inverter, - if not ON ("1") within 30s force shutdown
function_Check_Inverter_ON

done


if [ $ForcedCharging_int -eq 1 ]; then
echo Nachladen abgeschlossen >> ${_LOGFILE_}
echo ----------------------- >> ${_LOGFILE_}


# CPOL: set back to normal operations
function_CPOL_Reset


ForcedCharging_int=0

# Display / Print Battery Status
if ( [ -f /home/admin/registry/out/gen2 ] && [[ $bmmType == "sony" ]] ); then
echo "" >> ${_LOGFILE_}
echo Aktueller Status Batteriemodule: SoC $SoC_int % '≥' $SoC_discharge_int % bzw. Zell-Spannung $U_cell_minV_int mV '>' $U_cell_minV_min_forced_disable_int mV >> ${_LOGFILE_}
echo ------------------------------------------------------------------------------------- >> ${_LOGFILE_}
function_Print_Battery_Status_1338
fi

## enable normal charging/discharing
echo "0" > /tmp/ChargedFlag

# Count events of forced charching
counter_forced_charging_int=$(awk '{print $1+1}' <<<"${counter_forced_charging_int}")

# reset operation status: delete ForcedChargingActive
rm -f /tmp/ForcedChargingActive
sshpass -p pi ssh pi@192.168.0.50 "rm -f /tmp/ForcedChargingActive"

fi

#====================================================================================================================
# A1 # PVandHH ≥ dischargeStandbyThreshold_int  AND SoC > SoC_discharge: AUSSPEICHERN (Discharge)
#====================================================================================================================
elif ( [ $PVandHH_int -ge $dischargeStandbyThreshold_int ] && [ $SoC_int -gt $SoC_discharge_int ] ); then
if [[ $Status == "noPVBuffering" ]]; then
rm -f /home/admin/registry/noPVBuffering
loop_inverter_discharge_int=0
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' A1 '|' AUSSPEICHERN - rm noPVBuffering >> ${_LOGFILE_}
else
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' A1 '|' AUSSPEICHERN >> ${_LOGFILE_}
# Check status of inverter, - if not ON ("1") after 10 loops force shutdown
function_Check_Inverter_ON_discharge_60_loops
fi


counter_discharge_to_standby_int=0
counter_standby_to_discharge_int=0


#====================================================================================================================
# A2 # PVandHH ≥ dischargeStandbyThreshold_int  AND SoC ≤ SoC_discharge: STANDBY (Sleep)
#====================================================================================================================
elif ( [ $PVandHH_int -ge $dischargeStandbyThreshold_int ] && [ $SoC_int -le $SoC_discharge_int ] ); then
if [[ $Status == "PVBuffering" ]]; then
touch /home/admin/registry/noPVBuffering
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' A2 '|' STANDBY '(Sleep):' SoC≤$SoC_discharge_int% - touch noPVBuffering >> ${_LOGFILE_}

else
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' A2 '|' STANDBY '(Sleep):' SoC≤$SoC_discharge_int% >> ${_LOGFILE_}
fi

counter_discharge_to_standby_int=0
counter_standby_to_discharge_int=0

#====================================================================================================================
# B1 # PVandHH ≥ dischargeStandbyThreshold_delay_int  AND SoC > SoC_discharge: AUSSPEICHERN nach Delay (Discharge)
#====================================================================================================================
elif ( [ $PVandHH_int -ge $dischargeStandbyThreshold_delay_int ] && [ $SoC_int -gt $SoC_discharge_int ] ); then
if [[ $Status == "noPVBuffering" ]]; then
if [ $counter_standby_to_discharge_int -ge $counter_standby_to_discharge_max_int ]; then
rm -f /home/admin/registry/noPVBuffering
loop_inverter_discharge_int=0
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' B1 '|' AUSSPEICHERN - rm noPVBuffering >> ${_LOGFILE_}
else
counter_standby_to_discharge_int=$(awk '{print $1+$2}' <<<"${counter_standby_to_discharge_int} ${counter_increment_total_int}")
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' B1 '|' STANDBY - Wartezeit vor AUSSPEICHERN: '('$counter_standby_to_discharge_int'/'$counter_standby_to_discharge_max_int')sec' >> ${_LOGFILE_}
fi
else
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' B1 '|' AUSSPEICHERN >> ${_LOGFILE_}
# Check status of inverter, - if not ON ("1") after 10 loops force shutdown
function_Check_Inverter_ON_discharge_60_loops

counter_standby_to_discharge_int=0
fi

counter_discharge_to_standby_int=0

#====================================================================================================================
# B2 # PVandHH ≥ dischargeStandbyThreshold_delay_int  AND SoC ≤ SoC_discharge: STANDBY (Sleep)
#====================================================================================================================
elif ( [ $PVandHH_int -ge $dischargeStandbyThreshold_delay_int ] && [ $SoC_int -le $SoC_discharge_int ] ); then
if [[ $Status == "PVBuffering" ]]; then
touch /home/admin/registry/noPVBuffering
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' B2 '|' STANDBY '(Sleep):' SoC≤$SoC_discharge_int% - touch noPVBuffering >> ${_LOGFILE_}
else
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' B2 '|' STANDBY '(Sleep):' SoC≤$SoC_discharge_int% >> ${_LOGFILE_}
fi

counter_discharge_to_standby_int=0
counter_standby_to_discharge_int=0

#====================================================================================================================
# C1 # PVandHH ≥ dischargeStandbyThreshold_hyst_int  AND SoC > SoC_discharge: AUSSPEICHERN-Hysterse (Discharge)
#====================================================================================================================
elif ( [ $PVandHH_int -ge $dischargeStandbyThreshold_hyst_int ] && [ $SoC_int -gt $SoC_discharge_int ] ); then
if ( [[ $CPOL1_Mod == "1" ]] && [[ $Status != "noPVBuffering" ]] ); then
# Inverter ON, - continue charging within the hysteresis
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' C1 '|' AUSSPEICHERN >> ${_LOGFILE_}
else
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' C1 '|' STANDBY >> ${_LOGFILE_}
fi

counter_discharge_to_standby_int=0
counter_standby_to_discharge_int=0


#====================================================================================================================
# C2 # PVandHH ≥ dischargeStandbyThreshold_hyst_int  AND SoC ≤ SoC_discharge: STANDBY (Sleep)
#====================================================================================================================
elif ( [ $PVandHH_int -ge $dischargeStandbyThreshold_hyst_int ] && [ $SoC_int -le $SoC_discharge_int ] ); then
if [[ $Status == "PVBuffering" ]]; then
touch /home/admin/registry/noPVBuffering
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' C2 '|' STANDBY '(Sleep):' SoC≤$SoC_discharge_int% - touch noPVBuffering >> ${_LOGFILE_}
else
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' C2 '|' STANDBY '(Sleep):' SoC≤$SoC_discharge_int% >> ${_LOGFILE_}
fi

counter_discharge_to_standby_int=0
counter_standby_to_discharge_int=0


#====================================================================================================================
# D1 # PVandHH > 0: STANDBY
#====================================================================================================================
elif [ $PVandHH_int -gt 0 ]; then
if [[ $Status == "PVBuffering" ]]; then
if [ $counter_discharge_to_standby_int -ge $counter_discharge_to_standby_max_int ]; then
touch /home/admin/registry/noPVBuffering
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' D1 '|' STANDBY - touch noPVBuffering >> ${_LOGFILE_}
else
counter_discharge_to_standby_int=$(awk '{print $1+$2}' <<<"${counter_discharge_to_standby_int} ${counter_increment_total_int}")
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' D1 '|' AUSSPEICHERN - Nachlaufzeit vor STANDBY: '('$counter_discharge_to_standby_int'/'$counter_discharge_to_standby_max_int')sec' >> ${_LOGFILE_}
fi
else
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' D1 '|' STANDBY >> ${_LOGFILE_}
fi

counter_standby_to_discharge_int=0


#====================================================================================================================
# D2 # PVandHH > chargeStandbyThreshold_hyst_int: STANDBY
#====================================================================================================================
elif [ $PVandHH_int -gt $chargeStandbyThreshold_hyst_int ]; then
if [[ $Status == "PVBuffering" ]]; then
if [ $counter_discharge_to_standby_int -ge $counter_discharge_to_standby_max_int ]; then
touch /home/admin/registry/noPVBuffering
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' D2 '|' STANDBY - touch noPVBuffering >> ${_LOGFILE_}
else
counter_discharge_to_standby_int=$(awk '{print $1+$2}' <<<"${counter_discharge_to_standby_int} ${counter_increment_total_int}")
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' D2 '|' EINSPEICHERN - Nachlaufzeit vor STANDBY: '('$counter_discharge_to_standby_int'/'$counter_discharge_to_standby_max_int')sec' >> ${_LOGFILE_}
fi
else
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' D2 '|' STANDBY >> ${_LOGFILE_}
fi

counter_standby_to_discharge_int=0

#====================================================================================================================
# E  # PVandHH > chargeStandbyThreshold_int: EINSPEICHERN-Hysterse (Charge)
#====================================================================================================================
elif [ $PVandHH_int -gt $chargeStandbyThreshold_int ]; then
if [[ $CPOL1_Mod == "1" ]]; then
if [[ $ChargedFlag == "1" ]]; then
if [[ $Status == "PVBuffering" ]]; then
touch /home/admin/registry/noPVBuffering
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' E  '|' STANDBY - touch noPVBuffering >> ${_LOGFILE_}
else
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' E  '|' STANDBY >> ${_LOGFILE_}
fi
else
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' E  '|' EINSPEICHERN >> ${_LOGFILE_}
fi
else
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' E  '|' STANDBY >> ${_LOGFILE_}
fi

counter_discharge_to_standby_int=0
counter_standby_to_discharge_int=0
#====================================================================================================================

else
#====================================================================================================================
# F # PVandHH ≤ chargeStandbyThreshold_int: EINSPEICHERN (CHARGE)
#====================================================================================================================
if ( [[ $ChargedFlag == "-1" ]] || [[ $ChargedFlag == "0" ]] ); then
if [[ $Status == "noPVBuffering" ]]; then
rm -f /home/admin/registry/noPVBuffering
loop_inverter_charge_int=0
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' F  '|' EINSPEICHERN - rm noPVBuffering >> ${_LOGFILE_}
else
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' F  '|' EINSPEICHERN >> ${_LOGFILE_}
fi

else
# disable additional charging when reached the max value 'ChargedFlag'
if [[ $Status == "PVBuffering" ]]; then
touch /home/admin/registry/noPVBuffering
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' F  '|' STANDBY - touch noPVBuffering >> ${_LOGFILE_}
else
echo $time '||' Cell_Δ: $U_cell_diff_V_int mV '|' SoC_Δ: $SoC_module_diff_int % '|' PVundHH: $PVandHH_int W '|' Capa_% $capa_module_100_int % '|' SoC: $SoC_int % '|' ChargedFlag: $ChargedFlag '|' INV: $CPOL1_Mod '|' INV: $Inv_Request W '|' F  '|' STANDBY >> ${_LOGFILE_}
fi
fi

counter_discharge_to_standby_int=0
counter_standby_to_discharge_int=0

fi

sleep $loop_delay_int


done

# Record System Status in log-File prior to restarting, force restart of BusinessOptimum
function_exit_and_start
