#!/bin/sh

pid=$(ps -ef | grep tomcat | grep java | awk ' { print $2 } ')

kill -9 ${pid}
mv ~/opt/tomcat/logs/catalina.out ~/opt/tomcat/logs/backup
sh ~/opt/tomcat/bin/startup.sh
tar ~/opt/tomcat/logs/backup/catalina.out.$(date '+%Y%m%d').tar ~/opt/tomcat/logs/backup/catalina.out
rm -rf ~/opt/tomcat/logs/backup/catalina.out
echo "Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)" | tee >> ~/opt/tomcat/logs/archive_tomcat_$(date '+%Y%m%d').log
