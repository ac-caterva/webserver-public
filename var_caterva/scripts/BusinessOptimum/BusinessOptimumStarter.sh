#!/bin/bash

# Starte BusinessOptimum.sh beim booten via crontab des Benutzers admin
# und starte BusinessOptimum.sh immer wieder. 

# Crontab Benutzer admin
# @reboot /home/admin/bin/BusinessOptimumStarter.sh start

BOS_LOG_FILE=/var/log/BusinessOptimumStarter.log
BOS_PID_FILE=/tmp/BusinessOptimumStarter.pid
BO_OUT_FILE=/var/log/BusinessOptimum.out
BO_PID_FILE=/tmp/BusinessOptimum.pid

MY_PID=$$

##############################################
# func_usage
# Pruefe Parameter
function func_usage ()
{
    if ( [ $# -ne 1 ] ); then 
	   	echo "usage: $0 [start|stop|status|status_fhem]" >&2
		exit 3
    fi 
}


##############################################
# func_exit
# Schreibe log Eintrag, beende BusinessOptimum, loesche pid Datei und exit
function func_exit ()
{
	DATE=`date +"%a %F %T" `
	echo "BOS: Stoppe BusinessOptimumStarter  : $DATE" >> $BOS_LOG_FILE
    func_delete_BOS_PID_file

#    if ( [ -f $BO_PID_FILE ] ) ; then
#        BO_PID=`head -1 $BO_PID_FILE`
        BO_IS_RUNNING=`ps -ef | grep -v grep | grep "$BO_PID" | grep "BusinessOptimum.sh"| wc -l`
        if ( [ $BO_IS_RUNNING -eq 1 ] ) ; then
            kill -9 $BO_PID
	        DATE=`date +"%a %F %T" `
            echo "BOS: BusinessOptimum gestoppt : $DATE (PID=$BO_PID)" >> $BOS_LOG_FILE
        fi
        func_delete_BO_PID_file
#    fi     
}


##############################################
# func_is_script_startet
# Wenn BusinessOptimumStarte noch laeuft return 1 ansonsten 0
function func_is_script_startet ()
{
    declare -n ret=$1
    declare -n pid=$2
    
    ret=0
    pid=0

    if ( [ -f $BOS_PID_FILE ] ) ; then
        ret=2
        BOS_RUN_PID=`head -1 $BOS_PID_FILE`
        BOS_IS_RUNNING=`ps -ef | grep -v grep | grep "$BOS_RUN_PID" | grep "BusinessOptimumStarter.sh"| wc -l`
        if ( [ $BOS_IS_RUNNING -ge 1 ] ) ; then
            ret=1
            pid=$BOS_RUN_PID
        fi 
    fi    
}

##############################################
# func_delete_BOS_PID_file
# Loesche BOS_PID_FILE=/tmp/BusinessOptimumStarter.pid
function func_delete_BOS_PID_file ()
{
    [ -f $BOS_PID_FILE ] && rm $BOS_PID_FILE
}

##############################################
# func_delete_BO_PID_file
# Loesche BO_PID_FILE=/tmp/BusinessOptimumStarter.pid
function func_delete_BO_PID_file ()
{
    [ -f $BO_PID_FILE ] && rm -f $BO_PID_FILE
}



##############################################
# MAIN
##############################################

trap 'func_exit' 1 2 15

func_usage $*

case $1 in 
    start )
        # Laeuft das Script evtl. noch?
        func_is_script_startet DO_I_RUN BOS_RUN_PID
        if ( [ "$DO_I_RUN" -eq 1 ] ) ; then
            echo -e "\nBOS: BusinessOptimumStarter is already running (PID=$BOS_RUN_PID)\n"
            exit 1
        fi

        # Sichere PID 
        echo $MY_PID > $BOS_PID_FILE

        # Vermerke Start des BOS im log
        DATE=`date +"%a %F %T"`
        echo -e "\nBOS: BusinessOptimumStarter startet: $DATE (PID=$MY_PID)\n" >> $BOS_LOG_FILE

        COUNT=1

        #Starte das BO Script
        while [ -f $BOS_PID_FILE ]
        do
            # Sollte aus irgendeinem Grund das Script nicht laufen wird mit dem sleep sicher 
            # gestellt, dass das System nicht ueberlastet wird.
            [ $COUNT -gt 1 ] && sleep 5
            DATE=`date +"%a %F %T" `
            echo -n "BOS: BusinessOptimum.sh gestartet: $DATE ($COUNT)" >> $BOS_LOG_FILE
            touch $BO_PID_FILE
            # Script wird im Hintergrund gestartet, damit ist die PID bekannt
            if ( [ -f $BOS_PID_FILE ] ) ; then
                /home/admin/bin/BusinessOptimum.sh  1>>$BO_OUT_FILE 2>&1 &
                BO_PID=$!
                echo $BO_PID > $BO_PID_FILE
                echo " (PID=$BO_PID)" >> $BOS_LOG_FILE
                wait $BO_PID
                DATE=`date +"%a %F %T" `
                echo "BOS: BusinessOptimum.sh beendet  : $DATE ($COUNT) (PID=$BO_PID)" >> $BOS_LOG_FILE
                COUNT=$(expr "$COUNT" + 1)
            fi
            func_delete_BO_PID_file            
        done

        DATE=`date +"%a %F %T" `
        echo -e "\nBOS: BusinessOptimumStarter beendet: $DATE (PID=$MY_PID)\n" >> $BOS_LOG_FILE
        ;;
    stop )
        func_is_script_startet DO_I_RUN BOS_RUN_PID
        case $DO_I_RUN in
            0 ) 
                echo -e "\nBOS: BusinessOptimumStarter is not running\n" 
                exit $DO_I_RUN
                ;;
            1 )
                DATE=`date +"%a %F %T" `
                echo -e "\nBOS: BusinessOptimumStarter wird gestoppt: $DATE (PID=$BOS_RUN_PID)\n"
                kill -1 $BOS_RUN_PID
                exit 0
                ;;
            2 )
                echo -e "\nBOS: BusinessOptimumStarter status is unknown"
                echo -e "BOS: $BOS_PID_FILE exists, but no running process found (PID=BOS_RUN_PID)\n"
                exit $DO_I_RUN
                ;;
        esac
        ;;
    status )
        func_is_script_startet DO_I_RUN BOS_RUN_PID
        case $DO_I_RUN in
            0 ) 
                echo -e "\nBOS: BusinessOptimumStarter is not running\n" 
                exit $DO_I_RUN
                ;;
            1 )
                echo -e "\nBOS: BusinessOptimumStarter is running (PID=$BOS_RUN_PID)\n"
                exit $DO_I_RUN
                ;;
            2 )
                echo -e "\nBOS: BusinessOptimumStarter status is unknown"
                echo -e "BOS: $BOS_PID_FILE exists, but no running process found (PID=BOS_RUN_PID)\n"
                exit $DO_I_RUN
                ;;
        esac
        ;;
    status_fhem )
        func_is_script_startet DO_I_RUN BOS_RUN_PID
        case $DO_I_RUN in
            0 ) 
                echo $DO_I_RUN
                exit $DO_I_RUN
                ;;
            1 )
                echo $DO_I_RUN
                exit $DO_I_RUN
                ;;
            2 )
                echo $DO_I_RUN
                exit $DO_I_RUN
                ;;
        esac
        ;;
    * ) 
        echo "$0: wrong parameter: $1"
        func_usage
        ;;    
esac