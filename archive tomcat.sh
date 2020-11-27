#!/bin/sh
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
pid=$(ps -ef | grep tomcat | grep java | awk ' { print $2 } ')

do
  echo $output
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  partition=$(echo $output | awk '{ print $2 }' )
  if [ $usep -ge 70 ]; then
    kill -9 ${pid}
    mv catalina.out /backup
    tar catalina.out.$(date '+%Y%m%d').tar
    rm -rf catalina.out
    echo "Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)" | tee >> ~/healthcheck/archive_tomcat_$(date '+%Y%m%d').log
  fi
done
