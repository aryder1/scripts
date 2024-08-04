#!/bin/bash

################################################################################################################
## Script Name: backup_postgres.sh                                                                            ##
## Description: Script run daily via cron to backup all PostgreSQL databases running in docker containers     ##
## Author:      Ryder                                                                                         ##
## Version:     1.0                                                                                           ##
## VersionDate: 9 June 2024                                                                                   ##
################################################################################################################

backup() {
	
	local container_name=$1
	local database=$2
	local user=$3
	local file_path=$4
	
	echo "$(date): Exporting ${database^^} database..." >> $logfile

	docker exec $(docker ps -aqf "name=^${container_name}$") /usr/local/bin/pg_dump -d ${database} -U ${user} -Fc > ${file_path}/${database}-backup-$(date +"%F").$(date +"%H:%M:%S").sqlc 2>> $logfile
	
	echo "$(date): ${database^^} export complete." >> $logfile
}


logfile=/opt/docker-apps/backup-restore/logs/backup_script.log

#FUNCTION	CONTAINER_NAME		DATABASE	USER		PATH_TO_BACKUP_DIRECTORY
backup		postgres-redmine	redmine		redmine		/opt/docker-apps/redmine/backup
backup		postgres-mattermost	mattermost	mmuser		/opt/docker-apps/mattermost/backup
backup		postgres-wiki		wiki		wiki		/opt/docker-apps/wiki/backup/_postgres
