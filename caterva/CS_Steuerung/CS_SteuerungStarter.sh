#!/bin/bash

# Starte CS_Steuerung.sh beim booten via crontab des Benutzers admin, dabei
#  wird CS_Steuerung.sh gestartet
# Stoppe CS-Steuerung.sh, wenn die STOPP-Datei angelegt wurde
# Starte CS_STeuerung.sh, wenn die START-Datei angelegt wurde

# Crontab Benutzer admin
# @reboot /home/admin/bin/CS_SteuerungStarter.sh start


CS_STRG_S_LOG_FILE=/var/log/CS_SteuerungStarter.log
CS_STRG_S_PID_FILE=/tmp/CS_SteuerungStarter.pid
CS_STRG_S_STOP_FILE=/tmp/CS_SteuerungStarterStop
CS_STRG_S_START_FILE=/tmp/CS_SteuerungStarterStart
CS_STRG_OUT_FILE=/var/log/CS_Steuerung.out
CS_STRG_PID_FILE=/tmp/CS_Steuerung.pid
CS_STRG_STOP_FILE=/tmp/CS_SteuerungStop

MY_PID=$$

##############################################
# func_usage
# Pruefe Parameter
function func_usage ()
{
    if ( [ $# -ne 1 ] ); then 
	   	echo "usage: $0 [start|stop|status]" >&2
		exit 3
    fi 
}


##############################################
# func_exit
# Schreibe log Eintrag, beende CS_Steuerung, loesche pid Datei und exit
function func_exit ()
{
	DATE=`date +"%a %F %T" `
	echo "CS_STRG_S: Stoppe CS_SteuerungStarter  : $DATE" >> $CS_STRG_S_LOG_FILE

    touch $CS_STRG_S_STOP_FILE
    touch $CS_STRG_STOP_FILE

    sleep 120 
    DATE=`date +"%a %F %T" `
    CS_STRG_IS_RUNNING=`ps -ef | grep -v grep | grep "$CS_STRG_PID" | grep "CS_Steuerung.sh"| wc -l`
    if ( [ "$CS_STRG_IS_RUNNING" -eq 1 ] ) ; then
        echo "CS_STRG_S: CS_Steuerung Fehler beim Stoppen : $DATE (PID = $CS_STRG_PID)" >> $CS_STRG_S_LOG_FILE
        kill -1 $CS_STRG_PID
        DATE=`date +"%a %F %T" `
        echo "CS_STRG_S: CS_Steuerung gestoppt : $DATE (PID = $CS_STRG_PID)" >> $CS_STRG_S_LOG_FILE
    fi

    func_cleanup
}



##############################################
# func_cleanup
# Loesche pid und stop Dateien und exit
function func_cleanup ()
{
    func_delete_CS_STRG_PID_file
    func_delete_CS_STRG_S_PID_file
    #func_delete_CS_STRG_STOP_file
}

##############################################
# func_is_script_startet
# Wenn CS_SteuerungStarter noch laeuft return 1 ansonsten 0
function func_is_script_startet ()
{
    declare -n ret=$1
    declare -n CS_STRG_S_pid=$2
    declare -n CS_STRG_pid=$3
    
    ret=0
    CS_STRG_S_pid=0
    CS_STRG_pid=0

    if ( [ -f $CS_STRG_S_PID_FILE ] ) ; then
        ret=2
        CS_STRG_S_RUN_PID=`head -1 $CS_STRG_S_PID_FILE`
        CS_STRG_S_IS_RUNNING=`ps -ef | grep -v grep | grep "$CS_STRG_S_RUN_PID" | grep "CS_SteuerungStarter.sh"| wc -l`
        if ( [ "$CS_STRG_S_IS_RUNNING" -ge 1 ] ) ; then
            ret=1
            CS_STRG_S_pid=$CS_STRG_S_RUN_PID
        fi 
    fi    
    if ( [ -f $CS_STRG_PID_FILE ] ) ; then
        CS_STRG_RUN_PID=`head -1 $CS_STRG_PID_FILE`
        CS_STRG_IS_RUNNING=`ps -ef | grep -v grep | grep "$CS_STRG_RUN_PID" | grep "CS_Steuerung.sh"| wc -l`
        if ( [ "$CS_STRG_IS_RUNNING" -ge 1 ] ) ; then
            CS_STRG_pid=$CS_STRG_RUN_PID
        fi 
    fi     
}


##############################################
# func_delete_CS_STRG_S_PID_file
# Loesche CS_STRG_S_PID_FILE
function func_delete_CS_STRG_S_PID_file ()
{
    [ -f $CS_STRG_S_PID_FILE ] && rm $CS_STRG_S_PID_FILE
}


##############################################
# func_delete_CS_STRG_PID_file
# Loesche CS_STRG_PID_FILE
function func_delete_CS_STRG_PID_file ()
{
    [ -f $CS_STRG_PID_FILE ] && rm -f $CS_STRG_PID_FILE
}


##############################################
# func_delete_CS_STRG_STOP_file
# Loesche CS_STRG_STOP_FILE
function func_delete_CS_STRG_STOP_file ()
{
    [ -f $CS_STRG_STOP_FILE ] && rm -f $CS_STRG_STOP_FILE
}    

##############################################
# func_delete_CS_STRG_START_file
# Loesche CS_STRG_START_FILE
function func_delete_CS_STRG_START_file ()
{
    [ -f $CS_STRG_START_FILE ] && rm -f $CS_STRG_START_FILE
}

##############################################
# func_delete_CS_STRG_S_STOP_file
# Loesche CS_STRG_S_STOP_FILE
function func_delete_CS_STRG_S_STOP_file ()
{
    [ -f $CS_STRG_S_STOP_FILE ] && rm -f $CS_STRG_S_STOP_FILE
} 

##############################################
# func_delete_CS_STRG_S_START_file
# Loesche CS_STRG_S_START_FILE
function func_delete_CS_STRG_S_START_file ()
{
    [ -f $CS_STRG_S_START_FILE ] && rm -f $CS_STRG_S_START_FILE
} 

##############################################
# MAIN
##############################################

trap 'func_exit' 1 2 15

func_usage $*

case $1 in 
    start )
        # Laeuft das Starter Script evtl. noch?
        func_is_script_startet DO_I_RUN CS_STRG_S_RUN_PID CS_STRG_RUN_PID
        if ( [ "$DO_I_RUN" -eq 1 ] ) ; then
            echo -e "\nCS_STRG_S: CS_SteuerungStarter is already running (PID = $CS_STRG_S_RUN_PID)"
            echo -e "CS_STRG_S: CS_Steuerung.sh (PID = $CS_STRG_RUN_PID)\n"
            exit 1
        fi

        func_delete_CS_STRG_S_STOP_file

        # Sichere PID vom Starter Script
        echo $MY_PID > $CS_STRG_S_PID_FILE

        # Vermerke Start des CS_STRG_S im log
        DATE=`date +"%a %F %T"`
        echo -e "\nCS_STRG_S: CS_SteuerungStarter startet: $DATE (PID = $MY_PID)\n" >> $CS_STRG_S_LOG_FILE

        COUNT=1

        while [ ! -f $CS_STRG_S_STOP_FILE ]
        do
        # Starte das CS_STRG Script
            if ( [ -f $CS_STRG_STOP_FILE ] ); then
                # CS_STRG soll nicht gestartet werden
                DATE=`date +"%a %F %T"`
                echo -e "CS_STRG_S: CS_Steuerung.sh soll nicht gestartet werden: $DATE\n" >> $CS_STRG_S_LOG_FILE
                sleep 60
                continue
            fi
            DATE=`date +"%a %F %T" `
            echo -n "CS_STRG_S: CS_Steuerung.sh gestartet: $DATE ($COUNT)" >> $CS_STRG_S_LOG_FILE
            touch $CS_STRG_PID_FILE
            # Script wird im Hintergrund gestartet, damit ist die PID bekannt
            if ( [ ! -f $CS_STRG_S_STOP_FILE ] ) ; then
                /home/admin/bin/CS_Steuerung.sh  1>>$CS_STRG_OUT_FILE 2>&1 &
                CS_STRG_PID=$!
                echo $CS_STRG_PID > $CS_STRG_PID_FILE
                echo " (PID = $CS_STRG_PID)" >> $CS_STRG_S_LOG_FILE
                wait $CS_STRG_PID
                DATE=`date +"%a %F %T" `
                echo "CS_STRG_S: CS_Steuerung.sh beendet  : $DATE ($COUNT) (PID = $CS_STRG_PID)" >> $CS_STRG_S_LOG_FILE
                # Sollte aus irgendeinem Grund das Script nicht laufen wird mit dem sleep sicher 
                # gestellt, dass das System nicht ueberlastet wird.
                [ $COUNT -gt 1 ] && sleep 30
                COUNT=$(expr "$COUNT" + 1)
            fi
            func_delete_CS_STRG_PID_file            
        done
        # Starter Script soll gestoppt werden
        DATE=`date +"%a %F %T" `
        echo -e "\nCS_STRG_S: CS_SteuerungStarter beendet: $DATE (PID = $MY_PID)\n" >> $CS_STRG_S_LOG_FILE
        func_cleanup
        func_delete_CS_STRG_S_STOP_file
        exit
        ;;
    stop )
        func_is_script_startet DO_I_RUN CS_STRG_S_RUN_PID CS_STRG_RUN_PID
        case $DO_I_RUN in
            0 ) 
                echo -e "\nCS_STRG_S: CS_SteuerungStarter is not running\n" 
                exit $DO_I_RUN
                ;;
            1 )
                DATE=`date +"%a %F %T" `
                echo -e "\nCS_STRG_S: CS_SteuerungStarter wird gestoppt: $DATE (PID = $CS_STRG_S_RUN_PID)"
                echo -e "CS_STRG_S: CS_Steuerung.sh: $DATE (PID = $CS_STRG_RUN_PID)\n"
                touch $CS_STRG_S_STOP_FILE
                touch $CS_STRG_STOP_FILE
                exit 0
                ;;
            2 )
                echo -e "\nCS_STRG_S: CS_SteuerungStarter status is unknown"
                echo -e "CS_STRG_S: $CS_STRG_S_PID_FILE exists, but no running process found (PID = $CS_STRG_S_RUN_PID)\n"
                exit $DO_I_RUN
                ;;
        esac
        exit
        ;;
    status )
        func_is_script_startet DO_I_RUN CS_STRG_S_RUN_PID CS_STRG_RUN_PID
        case $DO_I_RUN in
            0 ) 
                echo -e "\nCS_STRG_S: CS_SteuerungStarter is not running\n" 
                exit $DO_I_RUN
                ;;
            1 )
                echo -e "\nCS_STRG_S: CS_SteuerungStarter is running (PID = $CS_STRG_S_RUN_PID)"
                case $CS_STRG_RUN_PID in
                    0 ) 
                        echo -e "CS_STRG_S: CS_Steuerung.sh ist gestoppt\n"
                        ;;
                    * )
                        echo -e "CS_STRG_S: CS_Steuerung.sh (PID = $CS_STRG_RUN_PID)\n"
                        ;;
                esac        
                exit $DO_I_RUN
                ;;
            2 )
                echo -e "\nCS_STRG_S: CS_SteuerungStarter status is unknown"
                echo -e "CS_STRG_S: $CS_STRG_S_PID_FILE exists, but no running process found (PID = $CS_STRG_S_RUN_PID)\n"
                exit $DO_I_RUN
                ;;
        esac
        exit
        ;;
    * ) 
        echo "$0: wrong parameter: $1"
        func_usage
        exit
        ;;    
esac
