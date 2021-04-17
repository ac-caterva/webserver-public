#!/bin/bash

REPO_BASEDIR=/home/pi/Git-Clones/webserver-public
DISTRIB_DIR=$REPO_BASEDIR/Verteilung
CONFIG_FILE=$DISTRIB_DIR/Config/Copy2Caterva.config
CREA_DIR=$DISTRIB_DIR/CreateTargetDir
PRE_DIR=$DISTRIB_DIR/PreUpdate
UPD_DIR=$DISTRIB_DIR/Update 
POST_DIR=$DISTRIB_DIR/PostUpdate

LOCK_FILE=/tmp/Copy2CatervaVerteilung.lock 
LOG_FILE=/var/caterva/logs/Copy2CatervaVerteilung.log 

MY_PID=$$


exec 2>> $LOG_FILE

function DeleteRepoWebserver ()
{
	rm -rf /home/pi/Git-Clones/webserver
}

function CreateSymLinkRepoWebserver2WebserverPublic ()
{
	ln -s webserver-public /home/pi/Git-Clones/webserver
}

function SplitConfigLine ()
{
	# Array with all values form the LINE
	declare -a VALUES
	VALUES=( `echo $LINE | sed -e 's/:/ /g'` )

	# array with all given Parameters
	declare -a PARAMS
	PARAMS=( $@ )
	i=0
	for PARAM in "${PARAMS[@]}"; do
		eval ${PARAM}=${VALUES[$i]}
		i=`expr $i + 1`
	done

	LogMessageWithDate "Start processing of file: $SOURCE"
}

function CheckConfigFields ()
{
	if [ $COPY_WITH_RSYNC = "NO" ] && [ $UPD = "NONE" ] ; then
		LogError "Wrong paramters for file $SOURCE."
		LogError "Check parameters :UpdateScript: and :CopyWithRsync: in $CONFIG_FILE"
		LogFinishedFileMessage
		return 1 # NO_SUCCESS
	else	
		return 0 # SUCCESS
	fi 
}

function FileExistsAndExectbl ()
{
	RETURN=0
	if [ ! -f $1 ] ; then
		RETURN=1
		LogError "File $1 does not exist."
	else
		if [ ! -x $1 ] ; then
			RETURN=1
			LogError "File $1 is not executable."
		fi
	fi

	if [ $# -eq 2 ] && [ $2 = AND_FINISH ] ; then
		LogFinishedFileMessage
	fi	

	return $RETURN	
}

function CreateTargetDir ()
{
	LogMessage "Create target directory of file $TARGET"
	COMMAND=$CREA_DIR/$CREA
	FileExistsAndExectbl $COMMAND AND_FINISH
	if [ $? = 0 ] ; then 
		RESULT=`eval $COMMAND`
		if [ "$RESULT" = "SUCCESS" ] ; then
			return 0 # SUCCESS
		fi
	fi	
	return 1 # NO_SUCCESS
}

function TargetDirExists ()
{
	TARGET_DIR=`dirname $TARGET`
	TARGET_DIR_EXISTS=`ssh -n admin@caterva "if [ -d $TARGET_DIR ] ; then echo 1; else echo 0; fi "`
	if  [ "$TARGET_DIR_EXISTS" = 1 ]  ; then
		return 0
	else
		if [ "$TARGET_DIR_EXISTS" = 0 ]  ; then
			LogError "Target directory of file $TARGET does not exist"
			LogMessage "Datei $SOURCE wird nicht kopiert"
			LogFinishedFileMessage
		else 
			if [ "$TARGET_DIR_EXISTS" = "" ]  ; then
				LogError "Caterva is not reachable"
				LogFinishedFileMessage	
			fi	
		fi	
		return 1
	fi
}

function RsyncCheckForUpdate ()
{
	FILENAME=`basename $SOURCE`
	FILE_TO_COPY=`rsync -n -i --checksum $REPO_BASEDIR/$SOURCE admin@caterva:$TARGET | cut -d" " -f2`
	if [ "$FILENAME" = "$FILE_TO_COPY" ] ; then
		LogMessage "File $SOURCE differs from $TARGET"
		return 0 # DO_UPDATE
	else
		LogMessage "File $SOURCE is identical to $TARGET"
	    LogFinishedFileMessage
		return 1 # DO_NOT_UPDATE
	fi	
}

function RunPreUpdate ()
{
	LogMessage "Starting pre-update"
	COMMAND=$PRE_DIR/$PRE
	FileExistsAndExectbl $COMMAND
	if [ $? = 0 ] ; then 
		RESULT=`eval $COMMAND`
		[ "$RESULT" = "SUCCESS" ] && return 0
	fi
	return 1 # NO_SUCCESS
}

function RunRSYNC ()
{
	LogMessage "Starting rsync"
	rsync $REPO_BASEDIR/$SOURCE admin@caterva:$TARGET
}

function RunUpdate ()
{
	LogMessage "Starting update"
	COMMAND=$UPD_DIR/$UPD
	FileExistsAndExectbl $COMMAND
	if [ $? = 0 ] ; then 
		eval $COMMAND	
	fi
}

function RunPostUpdate ()
{
	LogMessage "Starting post-update"
	COMMAND=$POST_DIR/$POST
	FileExistsAndExectbl $COMMAND
	if [ $? = 0 ] ; then 
		RESULT=`eval $COMMAND`
	fi	
	if [ "$RESULT" = "NO_SUCCESS" ] ; then
		LogError "Post Processing failed."
	fi
}

function LogSpeparetorLine ()
{
	LogMessage "=========================================================" 
}

function LogMessageWithDate ()
{
	DATE=`date +%F_%T:`
	echo "$DATE $@" | tee -a $LOG_FILE
}

function LogError ()
{
	echo "ERROR: $@" | tee -a $LOG_FILE
}

function LogMessage ()
{
	echo "$@" | tee -a $LOG_FILE
}

function CleanUp ()
{
	rm -f $LOCK_FILE
}

function LogStartUpdateMessage ()
{
	LogSpeparetorLine
	LogMessageWithDate "Update started"
	LogMessage "             REPO_BASEDIR: $REPO_BASEDIR"
	LogSpeparetorLine
}

function LogFinishedUpdateMessage ()
{
	LogMessageWithDate "Update finished"
	LogSpeparetorLine
}

function LogFinishedFileMessage ()
{
	LogMessageWithDate "Finish processing of file: $SOURCE"
	LogSpeparetorLine
}


##################################################
# MAIN
#

if [ -f $LOCK_FILE ] ; then
	LogSpeparetorLine
	LogError "An update is already running."
	LogMessage "Wait a minute for the update to be finished."
	LogMessage "If the problem persists please reboot the pi."
	LogSpeparetorLine
	exit 
fi	

echo $MY_PID > $LOCK_FILE

LogStartUpdateMessage

DeleteRepoWebserver

CreateSymLinkRepoWebserver2WebserverPublic

declare -a CONFIG_FILE_FIELDS
CONFIG_FILE_FIELDS=( "SOURCE" "TARGET" "CREA" "PRE" "UPD" "POST" "COPY_WITH_RSYNC" )

cat $CONFIG_FILE | grep -v "^#" | \
while read LINE ; do 
	SplitConfigLine ${CONFIG_FILE_FIELDS[@]}

	CheckConfigFields || continue

	if [ $CREA != "NONE" ] ; then
		CreateTargetDir || continue
	fi
	
	TargetDirExists || continue

	RsyncCheckForUpdate && {
		RUN_UPDATE=YES
		if [ $PRE != "NONE" ] ; then 
			RunPreUpdate || RUN_UPDATE=NO
		fi	
		if [ "$RUN_UPDATE" = "YES" ] ; then
			if [ "$COPY_WITH_RSYNC" = "YES" ] ; then
				RunRSYNC
			fi	 
			[ $UPD != "NONE" ] && RunUpdate
		fi
		[ $POST != "NONE" ] && RunPostUpdate
		LogFinishedFileMessage
	}
done

LogFinishedUpdateMessage

CleanUp
