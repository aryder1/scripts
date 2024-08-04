#!/bin/bash

help() {
cat << EOF
Usage: restore_script.sh <wiki|redmine|mattermost> <filepath to sqlc backup>
Restore a PostgreSQL database for Wiki.js, Redmine, and Mattermost

POSTGRES BACKUP LOCATIONS:
 - Wiki.js:    /opt/docker-apps/wiki/backup/_postgres
 - Redmine:    /opt/docker-apps/redmine/backup
 - Mattermost: /opt/docker-apps/mattermost/backup

EXAMPLE:
restore_script.sh wiki /opt/docker-apps/wiki/backup/_postgres/wiki-backup-2024-06-06.04:00:02.sqlc
EOF
}

restore() {
        echo "container: ${container}"
        echo "dbuser: ${dbuser}"
        echo "database: ${database}"
        echo "filepath: ${filepath}"
        echo "docker exec -i $(docker ps -aqf "name=^postgres-${container}$") /usr/local/bin/pg_restore -U ${dbuser} -d ${database} -1 --clean --verbose --no-acl --no-owner < ${filepath}"
}

filepath=$2

case $1 in
        wiki)
                echo "Restoring Wiki.js database"
                container="wiki"
                dbuser="wiki"
                database="wiki"
                restore
        ;;

        redmine)
                echo "Restoring Redmine"
                container="redmine"
                dbuser="redmine"
                database="redmine"
                restore
        ;;

        mattermost)
                echo "Restoring Mattermost..."
                container="mattermost"
                dbuser="mmuser"
                database="mattermost"
                restore
        ;;
        
        *)
                help
        ;;

esac