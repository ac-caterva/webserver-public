#!/bin/bash

function Echo_ok ()
{ 
    echo -e "\033[0;32m Check war ok.\033[0m"
}

function Echo_nok ()
{
    echo -e "\033[0;31m Check war nicht ok.\033[0m"
}

function Color_green_on ()
{ 
    echo -e "\033[0;32m "
}

function Color_turkis_on ()
{ 
    echo -e "\033[0;36m "
}

function Color_red_on ()
{
    echo -e "\033[0;31m "
}

function Color_off ()
{
    echo -e "\033[0m"
}

function Read_Caterva_Type ()
{
    echo -e "\n---Bestimme den Anlagentyp"
    if [ -f /home/admin/registry/out/gen1 ] ; then
        TYPE=GEN1_SAFT
    else
        if [ -f /home/admin/registry/out/gen2 ] ; then
            TYPE=GEN2_SAFT
            IS_SONY=`grep -i sony /home/admin/registry/out/bmmType | wc -l`
            if [ $IS_SONY -eq 1 ] ; then
                TYPE=GEN2_SONY
            fi
        fi
    fi   
    Color_green_on
    echo -e "Anlagentyp: $TYPE"     
    Color_off
}

function Check_FS_var_log ()
{
    echo -e "\n---Pruefe FS /var/log < 50% Usage"
    VAR_LOG_USAGE_IN_PCT=`df --output=pcent /var/log | tail -1`
    VAR_LOG_USAGE=`echo $VAR_LOG_USAGE_IN_PCT | cut -d "%" -f1`

    if [ $VAR_LOG_USAGE -lt 50 ] ; then
        Echo_ok
    else    
        Echo_nok
    fi
}

function Check_number_of_invoiceLog ()
{
    echo -e "\n---Pruefe Anzahl invoiceLog Dateien < 270 "
    NUMBER_OF_invoiceLog=`ls -1 /var/log/invoiceLog.csv.* | wc -l`

    if [ $NUMBER_OF_invoiceLog -le 270 ] ; then
        Echo_ok
    else    
        Echo_nok
    fi
}

function Check_logrotate_of_invoiceLog ()
{
    echo -e "\n---Pruefe logrotate = 270 fuer invoiceLog Dateien "
    NUMBER_OF_invoiceLog_rotate=`grep rotate /home/admin/bin/log-cleanup.conf | grep 270 | wc -l`

    if [ $NUMBER_OF_invoiceLog_rotate -eq 1 ] ; then
        Echo_ok
    else    
        Echo_nok
    fi
}

function Command_should_not_run ()
{
    if [ $1 -eq 0 ] ; then
        Echo_ok
    else    
        Echo_nok
    fi
}

function Command_should_run ()
{
    if [ $1 -eq 1 ] ; then
        Echo_ok
    else    
        Echo_nok
    fi
}

function Check_crontab_log_cleanup ()
{
    echo -e "\n---Pruefe crontab Job /home/admin/bin/log-cleanup "
    CRONTAB_START=`cat /etc/crontab | grep -v "#" | grep "/home/admin/bin/log-cleanup" | cut -d " " -f1-5`

    if [ "$CRONTAB_START" = "00 0 * * *" ] ; then
        Echo_ok
    else    
        Echo_nok
    fi    
}

function Check_crontab ()
{
    echo -e "\n---Pruefe crontab Job $1 "
    COMMAND_EXISTS=`cat /etc/crontab | grep -v "#" | grep "$1"| wc -l`

    case $1 in
        /home/admin/bin/swarmcomm.sh )
            if [ $TYPE = GEN2_SAFT ] ; then
                Command_should_run $COMMAND_EXISTS 
            else
                Command_should_not_run $COMMAND_EXISTS 
            fi
            ;;
        * )
            Command_should_not_run $COMMAND_EXISTS 
            ;;
    esac
}

function Check_etc_rclocal ()
{
    echo -e "\n---Pruefe /etc/rc.local - Kommando iptables muss auskommentiert sein"
    COMMAND_EXISTS=`cat /etc/rc.local | grep -v "#" | grep "iptables"| wc -l`

    Command_should_not_run $COMMAND_EXISTS 
}

function Check_date ()
{
    echo -e "\n---Pruefe das Datum"
    DATE=`date` 
    Color_turkis_on
    echo -n "   $DATE"
    Color_green_on
    echo -n " ENTER fuer weiter: " 
    read _ANSWER_
    Color_off
}

function Warn_swarm_comm ()
{
    if [ $TYPE = GEN2_SAFT ] ; then
        Color_red_on
        echo "Anlagentyp ist $TYPE. Swarm Kommunikation darf nicht ausgeschlatet werden"
        Color_off
    fi
}

function Check_swarm_comm ()
{
    echo -e "\n---Pruefe Datei /etc/init.d/swarm-comm - Swarm Kommunikation sollte ausgeschaltet sein\n"
    Color_turkis_on
    head -19 /etc/init.d/swarm-comm
    Color_off
    Warn_swarm_comm
    echo -ne "\nPruefe die Datei. \033[0;32m ENTER fuer weiter: \033[0m" 
    read _ANSWER_
}

function Check_swarm_switch_on ()
{
    echo -e "\n---Pruefe Datei /etc/init.d/swarm-switch-on\n"
    Color_turkis_on
    cat /etc/init.d/swarm-switch-on
    Color_off
    echo -ne "\nPruefe die Datei. \033[0;32m ENTER fuer weiter: \033[0m" 
    read _ANSWER_

    echo -e "\n---Pruefe Verlinkungen auf /etc/init.d/swarm-switch-on"
    NUM_FILES=`sudo find /etc -name \*swarm-switch\* -exec ls -1 {} \; | wc -l`

    if [ $NUM_FILES -eq 8 ] ; then
        Echo_ok
    else
        Echo_nok
    fi
}

function Check_router ()
{
    bmmType=$(cat /home/admin/registry/out/bmmType)
    if [ "$bmmType" = "sony" ] ; then
        echo -e "\n---Pruefe Router Einstellungen\n\033[0;31m Sollte ein Passwort erfragt werden, dann bitte \033[0m admin01 \033[0;31m eingeben."
        echo -ne "\033[0;32m ENTER fuer weiter: \033[0m" 
        read _ANSWER_
        Color_turkis_on
        ssh root@192.168.0.105 cat /root/monitor.config
        Color_off
        echo -ne "\nPruefe die Router Einstellungen.\033[0;32m \n ENTER fuer weiter: \033[0m" 
        read _ANSWER_
    fi
}

function Check_prediction_problem ()
{
    echo -e "\n---Pruefe, ob es Probleme mit der Prediction/Extrapolation gibt"   
    echo -e "\n---Erster Teil der Pruefung: ITCI1 Werte"  
    Color_turkis_on
    (echo "SwDER/ITCI1.E_HH_PA.setMag.f";sleep 0.3;echo "exit";) | netcat localhost 1337 | grep SwDER/ITCI1
    (echo "SwDER/ITCI1.E_PV_PA.setMag.f";sleep 0.3;echo "exit";) | netcat localhost 1337 | grep SwDER/ITCI1
    (echo "SwDER/ITCI1.E_BH_PA.setMag.f";sleep 0.3;echo "exit";) | netcat localhost 1337 | grep SwDER/ITCI1
    (echo "SwDER/ITCI1.E_PB_PA.setMag.f";sleep 0.3;echo "exit";) | netcat localhost 1337 | grep SwDER/ITCI1
    Color_off
    echo -e "Pruefe, ob einer der Wert gleich 0 ist."
    echo
    echo -e "Sollte einer der Werte 0 sein, dann  muss das ITCI1 Script von Uli in die /etc/crontab aufgenommen werden"
    echo -e "Siehe dazu https://github.com/ac-caterva/Technik/blob/master/docs/Business_Controller/Analyse/Anlage_laden_nicht_wg_prediction.md"
    echo
    Color_green_on
    echo -ne "\033[0;32m ENTER fuer weiter: \033[0m"
    read _ANSWER_


    echo -e "\n---Zweiter Teil der Pruefung: Prediction im bin.zip"  
    Color_turkis_on
    echo -e "\n     Start: Teile der Prediction SW im bin.zip:"
    Color_off
    unzip -l /home/admin/release/bin.zip | grep --colour prediction
    Color_turkis_on
    echo -e "\n     Ende: Teile der Prediction SW im bin.zip:"
    Color_off
    echo -e "Pruefe, noch Prediction SW im bin.zip enthalten ist."
    echo -e "Siehe dazu https://github.com/ac-caterva/Technik/blob/master/docs/Business_Controller/Analyse/Anlage_laden_nicht_wg_prediction.md"
    echo
    Color_green_on
    echo -ne "\033[0;32m ENTER fuer weiter: \033[0m"
    read _ANSWER_
}

#######################################
# MAIN

Read_Caterva_Type
Check_FS_var_log
Check_number_of_invoiceLog
Check_logrotate_of_invoiceLog
Check_crontab_log_cleanup
Check_crontab /home/admin/bin/timeupdate
Check_crontab /home/admin/bin/swarmcomm.sh
Check_etc_rclocal
Check_date
Check_swarm_comm
Check_swarm_switch_on
Check_router
Check_prediction_problem

Color_green_on
echo -e "\n ----Der Check ist beendet----"
Color_off