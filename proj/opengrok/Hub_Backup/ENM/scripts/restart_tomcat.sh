#!/bin/sh
#set -xv
/proj/opengrok/tools/tomcat/apache-tomcat-7.0.69/bin/shutdown.sh
sleep 1m
/proj/opengrok/tools/tomcat/apache-tomcat-7.0.69/bin/startup.sh
sleep 5m
/proj/opengrok/ENM-Repos/scripts/opengrok_health_check.sh
exeTime="$(date)"
printf "Last executed time %s\n" "$exeTime"
