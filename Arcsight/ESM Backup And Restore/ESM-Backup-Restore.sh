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


## Input Backup Path ## 
echo "Enter Bauckup Path"
read location

## Checking If all backup files exists
red='\033[0;31m'
green='\033[0;32m'
clear='\033[0m'

[ -f $location/arc_epd_stats.sql.gz ] &&  echo -e "arc_epd_stats.sql.gz ..... ${green}OK${clear}" || echo -e "arc_epd_stats.sql.gz ..... ${red}missing${clear}"
[ -f $location/arc_event_annotation_p.sql.gz ] && echo -e "arc_event_annotation_p.sql.gz ..... ${green}OK${clear}" || echo -e "arc_event_annotation_p.sql.gz ..... ${red}missing${clear}"
[ -f $location/arc_event_annotation.sql.gz ] && echo -e "arc_event_annotation.sql.gz ..... ${green}OK${clear}" || echo -e "arc_event_annotation.sql.gz ..... ${red}missing${clear}"
[ -f $location/arc_event_path_info.sql.gz ] && echo -e "arc_event_path_info.sql.gz ..... ${green}OK${clear}" || echo -e "arc_event_path_info.sql.gz ..... ${red}missing${clear}"
[ -f $location/arc_event_payload_p.sql.gz ] && echo -e "arc_event_payload_p.sql.gz ..... ${green}OK${clear}" || echo -e "arc_event_payload_p.sql.gz ..... ${red}missing${clear}"
[ -f $location/arc_event_payload.sql.gz ] && echo -e "arc_event_payload.sql.gz ..... ${green}OK${clear}" || echo -e "arc_event_payload.sql.gz ..... ${red}missing${clear}"
[ -f $location/arc_event_p.sql.gz ] && echo -e "arc_event_p.sql.gz ..... ${green}OK${clear}" || echo -e "arc_event_p.sql.gz ..... ${red}missing${clear}"
[ -f $location/configs.tar.gz ] && echo -e "configs.tar.gz ..... ${green}OK${clear}" || echo -e "configs.tar.gz ..... ${red}missing${clear}"
[ -f $location/user_sequences.sql.gz ] && echo -e "user_sequences.sql.gz ..... ${green}OK${clear}" || echo -e "user_sequences.sql.gz ..... ${red}missing${clear}"
[ -f $location/arcsight_dump_system_tables.sql.gz ] &&  echo -e "arcsight_dump_system_tables.sql.gz ..... ${green}OK${clear}" || echo -e "arcsight_dump_system_tables.sql.gz ..... ${red}missing${clear}"
[ -f $location/cacerts ] &&  echo -e "cacerts ..... ${green}OK${clear}" || echo -e "cacerts ..... ${red}missing${clear}"
[ -f $location/database.properties ] &&  echo -e "database.properties ..... ${green}OK${clear}" || echo -e "database.properties ..... ${red}missing${clear}"
[ -f $location/esm.properties ] &&  echo -e "esm.properties ..... ${green}OK${clear}" || echo -e "esm.properties ..... ${red}missing${clear}"
[ -d $location/jetty ] &&  echo -e "jetty ..... ${green}OK${clear}" || echo -e "jetty ..... ${red}missing${clear}"
[ -f $location/keystore.client ] &&  echo -e "keystore.client ..... ${green}OK${clear}" || echo -e "keystore.client ..... ${red}missing${clear}"
[ -f $location/keystore.client.bcfks ] &&  echo -e "keystore.client.bcfks ..... ${green}OK${clear}" || echo -e "keystore.client.bcfks ..... ${red}missing${clear}"
[ -f $location/keystore.tempca ] &&  echo -e "keystore.tempca ..... ${green}OK${clear}" || echo -e "keystore.tempca ..... ${red}missing${clear}"
[ -d $location/license ] &&  echo -e "license ..... ${green}OK${clear}" || echo -e "license ..... ${red}missing${clear}"
[ -f $location/logger.properties ] &&  echo -e "logger.properties ..... ${green}OK${clear}" || echo -e "logger.properties ..... ${red}missing${clear}"
[ -f $location/my.cnf ] &&  echo -e "my.cnf ..... ${green}OK${clear}" || echo -e "my.cnf ..... ${red}missing${clear}"
[ -f $location/server.properties ] &&  echo -e "server.properties ..... ${green}OK${clear}" || echo -e "server.properties ..... ${red}missing${clear}"
[ -f $location/server.wrapper.conf ] &&  echo -e "server.wrapper.conf ..... ${green}OK${clear}" || echo -e "server.wrapper.conf ..... ${red}missing${clear}"

echo
echo

while true; do
    read -p "Do you want to continue ?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n.";;
    esac
done

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
echo "Restoring Files .... "
gzip -d $location/arcsight_dump_system_tables.sql.gz
/opt/arcsight/manager/bin/arcsight import_system_tables arcsight $Pass arcsight $location/arcsight_dump_system_tables.sql

yes | cp -r $location/.bash_profile /home/arcsight/.bash_profile 
yes | cp -r  $location/logger.properties /opt/arcsight/logger/current/arcsight/logger/user/logger/logger.properties
yes | cp -r  $location/esm.properties /opt/arcsight/manager/config/esm.properties
yes | cp -r  $location/my.cnf /opt/arcsight/logger/data/mysql/my.cnf 
yes | cp -r  $location/keystore*  /opt/arcsight/manager/config/
yes | cp -r $location/license /opt/arcsight/manager/user/manager/license 
yes | cp -r $location/server.properties  /opt/arcsight/manager/config/server.properties 
yes | cp -r $location/database.properties  /opt/arcsight/manager/config/database.properties 
yes | cp -r $location/server.wrapper.conf /opt/arcsight/manager/config/server.wrapper.conf 
yes | cp -r $location/jetty  /opt/arcsight/manager/config/jetty 
yes | cp -r $location/cacerts /opt/arcsight/java/esm/current/jre/lib/security/cacerts 

yes | cp -r $location/configs.tar.gz /opt/arcsight/logger/current/backups/
/opt/arcsight/logger/current/arcsight/logger/bin/arcsight disasterrecovery start

gunzip < $location/user_sequences.sql.gz | /opt/arcsight/logger/current/arcsight/bin/mysql -uarcsight -p$Pass arcsight
gunzip < $location/arc_event_annotation.sql.gz | /opt/arcsight/logger/current/arcsight/bin/mysql -uarcsight -p$Pass arcsight
gunzip < $location/arc_event_annotation_p.sql.gz | /opt/arcsight/logger/current/arcsight/bin/mysql -uarcsight -p$Pass arcsight
gunzip < $location/arc_event_path_info.sql.gz | /opt/arcsight/logger/current/arcsight/bin/mysql -uarcsight -p$Pass arcsight
gunzip < $location/arc_event_payload.sql.gz | /opt/arcsight/logger/current/arcsight/bin/mysql -uarcsight -p$Pass arcsight
gunzip < $location/arc_event_payload_p.sql.gz | /opt/arcsight/logger/current/arcsight/bin/mysql -uarcsight -p$Pass arcsight
gunzip < $location/arc_event_p.sql.gz | /opt/arcsight/logger/current/arcsight/bin/mysql -uarcsight -p$Pass arcsight
gunzip < $location/arc_epd_stats.sql.gz | /opt/arcsight/logger/current/arcsight/bin/mysql -uarcsight -p$Pass arcsight



echo ""
echo ""
echo -n "Starting Arcsight Services ..."
/etc/init.d/arcsight_services start all
echo ""
echo ""
echo ""


