#!/bin/bash

echo ""
echo ""
echo "###############################################"
echo "###### This script Created by Satius.io #######"
echo "###############################################"
echo ""
echo ""
echo ""



### Check if the user is Arcsight ###
if [ "$(whoami)" != "arcsight" ]; then
        echo "ERROR >>> The Script must be run as user: arcsight"
        echo ""
        echo ""
        exit 255
fi


## Create Backup Path ## 
if [ ! -d "/opt/arcsight/logger/data/archives/ESM-Backup/" ] 
then
    mkdir /opt/arcsight/logger/data/archives/ESM-Backup
fi
mkdir /opt/arcsight/logger/data/archives/ESM-Backup/Backup-$(date +"%d-%m-%Y-%H-%M")
location=/opt/arcsight/logger/data/archives/ESM-Backup/Backup-$(date +"%d-%m-%Y-%H-%M")



## Input Database Paasword ## 
echo "Enter Database Paasword"
read -s Pass

## Stopping Arcsight Services ##
echo ""
echo "Stopping Arcsight Services ..."
service arcsight_services stop all 
echo ""
echo "Arcsight Services Stopped."
service arcsight_services start mysqld
echo ""
echo "Starting mysqld Service ..."
service arcsight_services start postgresql
echo ""
echo "Starting postgresql Service ... "
sleep 60

echo ""
echo "Copying Files .... "
cp -r /home/arcsight/.bash_profile $location
cp -r /opt/arcsight/logger/current/arcsight/logger/user/logger/logger.properties $location
cp -r /opt/arcsight/manager/config/esm.properties $location
cp -r /opt/arcsight/logger/data/mysql/my.cnf $location
cp -r /opt/arcsight/manager/config/keystore* $location
cp -r /opt/arcsight/manager/user/manager/license $location
cp -r /etc/hosts $location
cp -r /opt/arcsight/manager/config/server.properties $location
cp -r /opt/arcsight/manager/config/database.properties $location
cp -r /opt/arcsight/manager/config/server.wrapper.conf $location
cp -r /opt/arcsight/manager/config/jetty $location
cp -r /opt/arcsight/java/esm/current/jre/lib/security/cacerts $location


/opt/arcsight/manager/bin/arcsight export_system_tables arcsight $Pass arcsight -s
rm /opt/arcsight/manager/tmp/arcsight_dump_system_tables.sql.gz
gzip /opt/arcsight/manager/tmp/arcsight_dump_system_tables.sql 
cp -r /opt/arcsight/manager/tmp/arcsight_dump_system_tables.sql.gz $location
/opt/arcsight/logger/current/arcsight/bin/mysqldump -uarcsight -p$Pass arcsight user_sequences| gzip > $location/user_sequences.sql.gz
/opt/arcsight/logger/current/arcsight/bin/mysqldump -uarcsight -p$Pass arcsight arc_event_annotation| gzip > $location/arc_event_annotation.sql.gz
/opt/arcsight/logger/current/arcsight/bin/mysqldump -uarcsight -p$Pass arcsight arc_event_annotation_p| gzip > $location/arc_event_annotation_p.sql.gz
/opt/arcsight/logger/current/arcsight/bin/mysqldump -uarcsight -p$Pass arcsight arc_event_path_info| gzip > $location/arc_event_path_info.sql.gz
/opt/arcsight/logger/current/arcsight/bin/mysqldump -uarcsight -p$Pass arcsight arc_event_payload| gzip > $location/arc_event_payload.sql.gz
/opt/arcsight/logger/current/arcsight/bin/mysqldump -uarcsight -p$Pass arcsight arc_event_payload_p| gzip > $location/arc_event_payload_p.sql.gz
/opt/arcsight/logger/current/arcsight/bin/mysqldump -uarcsight -p$Pass arcsight arc_event_p| gzip > $location/arc_event_p.sql.gz
/opt/arcsight/logger/current/arcsight/bin/mysqldump -uarcsight -p$Pass arcsight arc_epd_stats| gzip > $location/arc_epd_stats.sql.gz

/opt/arcsight/logger/current/arcsight/logger/bin/arcsight configbackup
cp /opt/arcsight/logger/current/arcsight/logger/tmp/configs/configs.tar.gz $location

echo ""
echo ""
echo -n "Starting Arcsight Services ..."
/etc/init.d/arcsight_services start all



echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "You can Find the Backup Folder at :"
echo "/opt/arcsight/logger/data/archives/ESM-Backup/"
echo ""
echo ""
echo ""

