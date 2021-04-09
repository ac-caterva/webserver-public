#!/bin/bash

# Automtisches Update der Pi und der Caterva
# 
# Sobald /opt/fhem/Update_Pi vorhanden wird der update der Pi durchgefuehrt
# - lock datei anlegen um zu verhinden, dass das Script mehrmals laeuft
# - /opt/fhem/Update_Pi loeschen
# - Aenderung vom github Repo pullen
# - Aenderungen verteilen
# - lock date loeschen
#



LOCK_FILE=/tmp/Update_Pi.lock
TRIGGER_FILE=/opt/fhem/Update_Pi
REPO_DIR=/home/pi/Git-Clones/webserver-public


##############################################
# func_exit
function func_exit ()
{
    rm $LOCK_FILE
    exit 0
}    

##############################################
# func_rm_trigger_file
function func_rm_trigger_file ()
{
    sudo rm -f $TRIGGER_FILE
}   


##############################################
# MAIN
##############################################


trap 'func_exit' 1 2 15

if ( [ -f ${TRIGGER_FILE} ] ) ; then
	[ -f $LOCK_FILE ] && exit
	echo $$ > $LOCK_FILE
	func_rm_trigger_file
	$REPO_DIR/GetChangesFromGitHub.sh
	$REPO_DIR/Copy2PiVerteilung.sh
	$REPO_DIR/Copy2CatervaVerteilung.sh
fi	

func_exit
