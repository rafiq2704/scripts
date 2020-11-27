#!/bin/sh

pid=$(ps -ef | grep tomcat | grep java | awk ' { print $2 } ')

do
    kill -9 ${pid}
    mv catalina.out /backup
    tar catalina.out.$(date '+%Y%m%d').tar
    rm -rf catalina.out
    echo "Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)" | tee >> ~/healthcheck/archive_tomcat_$(date '+%Y%m%d').log
done