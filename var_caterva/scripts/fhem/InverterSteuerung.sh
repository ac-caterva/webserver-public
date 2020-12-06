#!/bin/bash
#
# Steuerung des Inverters
# 	Datei noPVBuffering wird angelegt oder geloescht.
#	Ist die Datei angelegt wird der Inverter nicht mehr gestartet
# 	Ist die Datein nicht vorhanden wird der Inverter durch die Business Logik gesteuert
#
# Parameter:
#	status: return 0: Datei existiert
#		return 1: Datei existiert nicht
#	on: Datei wird geloescht
#	off: Datei wird angelegt
#	'kein Parameter': verhaelt sich wie Parameter status

FILENAME=/home/admin/registry/noPVBuffering
SCRIPTNAME="${0##*/}"

get_status() {
	rsh admin@caterva  test -f $FILENAME 
	return $?
}
set_on() {
	rsh admin@caterva rm $FILENAME
	return 1
}
set_off() {
	rsh admin@caterva touch $FILENAME
	return 0
}

if [ $# = 0 ] ;then
	get_status
	exit $?
else	
	case "$1" in
		status)
			get_status
			exit $?
		;;
		on)
			get_status
			if [ $? = 0 ] ;then
				set_on
			fi	
			exit 1
		;;
		off)
			set_off
			exit 0
		;;
	esac
	echo "Usage: $SCRIPTNAME {status|on|off}" >&2
	exit 3
fi
