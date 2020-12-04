#!/bin/sh

# A table that contains the path of directories to clean
rep_log=("/opt/tomcat/logs/backup")
echo "Cleaning logs - $(date)." | tee >> ~/healthcheck/old_logs_housekeeping_$(date '+%Y%m%d').log

#loop for each path provided by rep_log 
for element in "${rep_log[@]}"
do
   #display the directory
    echo "$element";
    nb_log=$(find "$element" -type f -mtime +2 -name "*.tar*"| wc -l)
    if [[ $nb_log != 0 ]] 
    then
            find "$element" -type f -mtime +2 -delete 
            echo "Successfully cleaned old logs." | tee >> ~/healthcheck/old_logs_housekeeping_$(date '+%Y%m%d').log
    else
            echo "No logs to clean!" | tee >> ~/healthcheck/old_logs_housekeeping_$(date '+%Y%m%d').log
    fi
done