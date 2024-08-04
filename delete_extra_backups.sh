#!/bin/bash

################################################################################################################
## Script Name: delete_extra_backups.sh                                                                       ##
## Description: Provide a file path and the number of backups to retain. Oldest files in the listed directory ##
##              will be deleted first.                                                                        ##
## Author:      Ryder                                                                                         ##
## Version:     1.0                                                                                           ##
## VersionDate: 9 June 2024                                                                                   ##
################################################################################################################

del_backups() {

	# Assign local variables
	local file_path=$1
	local num_backups=$2
	
	# Find files and create an array
	set -o noglob
	IFS=$'\n' files_list=($(find ${file_path} -type f -printf "%T@ %Tc %p\n" | sort -nr | awk -v num_backups="${num_backups}" 'NR>num_backups {print $NF}'))
	set +o noglob
	
	# Loop through array: log files to be deleted then delete them
	for i in ${!files_list[@]}; do
		echo "$(date): DELETING FILE: ${files_list[$i]}" >> $logfile
		rm -f ${files_list[$i]}
	done
}

logfile=/opt/docker-apps/backup-restore/logs/delete_extra_backups.log

#FUNCTION       PATH    					NUMBER_OF_BACKUPS_TO RETAIN
del_backups	/opt/docker-apps/wiki/backup/_daily 		7
del_backups	/opt/docker-apps/redmine/backup 		7
del_backups	/opt/docker-apps/wiki/backup/_postgres 		7
del_backups	/opt/docker-apps/mattermost/backup 		7
