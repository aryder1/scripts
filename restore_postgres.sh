#!/bin/bash

################################################################################################################
## Script Name: restore_postgres.sh                                                                           ##
## Description: Restore a Docker PostgreSQL database from a sqlc backup file. Backup files created by         ##
##              backup_postgres.sh                                                                            ##
## Author:      Ryder                                                                                         ##
## Version:     1.0                                                                                           ##
## VersionDate: 9 June 2024                                                                                   ##
################################################################################################################

help() {
cat << EOF
Usage: restore_postgres.sh <wiki|redmine|mattermost> [filepath to sqlc backup]
Restore a PostgreSQL database for Wiki.js, Redmine, and Mattermost.

*IMPORTANT: If the backup file is not included as the second argument, the script will automatically grab
the most recent backup from the directory itself.

POSTGRES BACKUP LOCATIONS:
 - Wiki.js:    /opt/docker-apps/wiki/backup/_postgres
 - Redmine:    /opt/docker-apps/redmine/backup
 - Mattermost: /opt/docker-apps/mattermost/backup

EXAMPLE:
restore_postgres.sh wiki /opt/docker-apps/wiki/backup/_postgres/wiki-backup-2024-06-06.04:00:02.sqlc
restore_postgres.sh redmine
EOF
}

restore() {
        echo "Restoring ${postgres_name^^} database"
        docker exec -i $(docker ps -aqf "name=^postgres-${postgres_name}$") /usr/local/bin/pg_restore -U ${dbuser} -d ${database} -1 --clean --verbose --no-acl --no-owner < ${filepath}
        echo "=============Restore Complete================="
        echo "Restarting ${app^^}..."
        docker restart $(docker ps -aqf "name=^${app}$") > /dev/null
        echo "Complete!"
}

check_filepath(){
        if [ -z $filepath ]
        then
                echo "No file provided. Defaulting to the most recent backup."
                return 1
        fi
}

get_filepath() {
        case $app in
                wiki)
                        dir="/opt/docker-apps/wiki/backup/_postgres"
                ;;
                redmine)
                        dir="/opt/docker-apps/redmine/backup"
                ;;
                mattermost)
                        dir="/opt/docker-apps/mattermost/backup"
                ;;
        esac
        echo $(find ${dir} -type f -printf "%T@ %Tc %p\n" | sort -nr | awk 'NR==1 {print $NF}')
}

app=$1
filepath=$2


case $app in
        wiki)
                app="wikijs"
                postgres_name="wiki"
                dbuser="wiki"
                database="wiki"
                check_filepath
                chk=$?
                if [ $chk == 1 ]; then filepath=$(get_filepath); fi
                echo "Backup File Selected: ${filepath}"
                restore
        ;;
        redmine)
                app="redmine"
                postgres_name="redmine"
                dbuser="redmine"
                database="redmine"
                check_filepath
                chk=$?
                if [ $chk == 1 ]; then filepath=$(get_filepath); fi
                echo "Backup File Selected: ${filepath}"
                restore
        ;;
        mattermost)
                app="mattermost"
                postgres_name="mattermost"
                dbuser="mmuser"
                database="mattermost"
                check_filepath
                chk=$?
                if [ $chk == 1 ]; then filepath=$(get_filepath); fi
                echo "Backup File Selected: ${filepath}"
                restore
        ;;
        *)
                help
        ;;
esac
