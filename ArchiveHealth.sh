#!/bin/sh

#Commented because of script overlapping issue.
#check_after_minutes="1m"
#restart_after_minutes="1m"
ip=$(hostname -I)
pid=$(ps -ef | grep tomcat | grep java | awk ' { print $2 } ')
num_of_pid=$(ps -ef | grep tomcat | grep java | awk ' { print $2 } ' | wc -l)
status_code=$(curl --write-out %{http_code} --silent --output /dev/null "http://${ip}/hlmgtms/v0_1/lookup/getCommonStatus")

restart_tomcat()
{
   cd /opt/tomcat/bin/
   ./startup.sh
   echo "$(date +%H:%M) Server has been restarted." | tee >> ~/healthcheck/healthcheck_$(date '+%Y%m%d').log
}

archive_tomcat()
{
   cd ~/healthcheck
   ./tomcat_housekeeping.sh
}

multiple_pid()
{
   echo "$(date +%H:%M) PID is more than 1!" | tee >> ~/healthcheck/healthcheck_$(date '+%Y%m%d').log
   sleep $1
   for i in "${pid}"
   do
     kill -9 ${pid}
   done
   archive_tomcat
   restart_tomcat
}

no_pid()
{
   echo "$(date +%H:%M) Server ${ip} is down!" | tee >> ~/healthcheck/healthcheck_$(date '+%Y%m%d').log
   sleep $1
   archive_tomcat
   restart_tomcat
}

JSON_response()
{
   if [ ${status_code} -eq 200 ]; then
      echo "$(date +%H:%M) Health OK!"
      archive_tomcat
        if [ -z ${pid} ]; then
          restart_tomcat
        fi
   else
      echo "$(date +%H:%M) Server ${ip} is not responding!" | tee >> ~/healthcheck/healthcheck_$(date '+%Y%m%d').log
      sleep $1
      kill -9 ${pid}
      archive_tomcat
      restart_tomcat
   fi
}

if [ ${num_of_pid} -gt 1 ]; then
   multiple_pid 0
elif [ -z ${pid} ]; then
   no_pid 0
else
   JSON_response 0
fi

#sleep ${check_after_minutes}

#if [ ${num_of_pid} -gt 1 ]; then
  #multiple_pid ${restart_after_minutes}
#elif [ -z ${pid} ]; then
   #no_pid ${restart_after_minutes}
#else
   #JSON_response ${restart_after_minutes}
#fi
