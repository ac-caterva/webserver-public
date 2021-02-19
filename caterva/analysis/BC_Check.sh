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

function Color_green_off ()
{
    echo -e "\033[0m"
}

function Check_FS_var_log ()
{
    echo -e "\n Pruefe FS /var/log < 50% Usage"
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
    echo -e "\n Pruefe Anzahl invoiceLog Dateien < 200 "
    NUMBER_OF_invoiceLog=`ls -1 /var/log/invoiceLog.csv.* | wc -l`

    if [ $NUMBER_OF_invoiceLog -lt 200 ] ; then
        Echo_ok
    else    
        Echo_nok
    fi
}

function Command_exist ()
{
    if [ $1 -eq 0 ] ; then
        Echo_ok
    else    
        Echo_nok
    fi
}

function Check_crontab_log_cleanup ()
{
    echo -e "\n Pruefe crontab Job /home/admin/bin/log-cleanup "
    CRONTAB_START=`cat /etc/crontab | grep -v "#" | grep "/home/admin/bin/log-cleanup" | cut -d " " -f1-5`

    if [ "$CRONTAB_START" = "00 0 * * *" ] ; then
        Echo_ok
    else    
        Echo_nok
    fi    
}

function Check_crontab ()
{
    echo -e "\n Pruefe crontab Job $1 "
    COMMAND_EXISTS=`cat /etc/crontab | grep -v "#" | grep "$1"| wc -l`

    Command_exist $COMMAND_EXISTS 
}

function Check_etc_rclocal ()
{
    echo -e "\n Pruefe /etc/rc.local"
    COMMAND_EXISTS=`cat /etc/rc.local | grep -v "#" | grep "iptables"| wc -l`

    Command_exist $COMMAND_EXISTS 
}

function Check_date ()
{
    echo -e "\n Pruefe Datum"
    DATE=`date` 
    echo -e "Pruefe das Datum:\033[0;32m $DATE . ENTER fuer weiter: \033[0m" 
    read _ANSWER_
}

function Check_swarm_comm ()
{
    echo -e "\n Pruefe Datei /etc/init.d/swarm-comm\n"
    Color_green_on
    head -19 /etc/init.d/swarm-comm
    Color_green_off
    echo -e "\nPruefe die Datei. \033[0;32m ENTER fuer weiter: \033[0m" 
    read _ANSWER_
}

function Check_swarm_switch_on ()
{
    echo -e "\n Pruefe Datei /etc/init.d/swarm-switch-on\n"
    Color_green_on
    cat /etc/init.d/swarm-switch-on
    Color_green_off
    echo -e "\nPruefe die Datei. \033[0;32m ENTER fuer weiter: \033[0m" 
    read _ANSWER_

    echo -e "\n Pruefe Verlinkungen auf /etc/init.d/swarm-switch-on"
    NUM_FILES=`sudo find /etc -name \*swarm-switch\* -exec ls -1 {} \; | wc -l`

    if [ $NUM_FILES -eq 8 ] ; then
        Echo_ok
    else    
        Echo_nok
    fi
}

#######################################
# MAIN

Check_FS_var_log
Check_number_of_invoiceLog
Check_crontab_log_cleanup
Check_crontab /home/admin/bin/timeupdate
Check_crontab /home/admin/bin/swarmcomm.sh
Check_etc_rclocal
Check_date
Check_swarm_comm
Check_swarm_switch_on