#!/bin/sh
#Retrieve all running Process ID (PID)
pid=$(ps -ef | grep tomcat | grep java | awk ' { print $2 } ')

kill_pid()
{
  #Loop to kill all pid (if it has multiple instances)
    for i in "${pid}"
    do
      kill -9 ${pid}
    done
}

df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
do
  echo $output
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  partition=$(echo $output | awk '{ print $2 }' )
  if [ $usep -ge 80 ]; then
    kill_pid
    mv /opt/tomcat/logs/catalina.out /opt/tomcat/logs/backup
    sh /opt/tomcat/bin/startup.sh
    tar -czvf /opt/tomcat/logs/backup/catalina.out.$(date '+%Y%m%d').tar /opt/tomcat/logs/backup/catalina.out
    rm -rf /opt/tomcat/logs/backup/catalina.out
    echo "Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)" | tee >> ~/healthcheck/archive_tomcat_$(date '+%Y%m%d').log
     echo "Test"
  else
     echo "Usage space is less than 80%"
  fi
done
