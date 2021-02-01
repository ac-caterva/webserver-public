#!/bin/sh

# Stop BOS and BO on shutdown of Caterva
#
# as user root
# cd /etc/init.d
# ln -s /home/admin/bin/BusinessOptimumStop.sh
# cd /etc/rc0.d 
# ln -s ../init.d/BusinessOptimumStop.sh K01BusinessOptimumStop.sh
# create this symb. link in all rc*.d directories


##############################################
# func_usage
# Check parameter
func_usage () {
    if ( [ $# -ne 1 ] ); then 
	   	echo "Usage: $0 [stop]" >&2
		exit 3
    fi 
}


##############################################
# MAIN
##############################################

func_usage $*

case "$1" in
  stop)
	sudo -u admin /home/admin/bin/BusinessOptimumStarter.sh stop
	sleep 20 # BusinessOptimum needs some time to stop
	;;
  *)

        echo "$0: wrong parameter: $1"
        func_usage
	exit 1
	;;
esac

exit
