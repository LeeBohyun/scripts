#!/bin/bash

mysql_dir="/home/lbh/mysql-5.6.26"
result_dir="/home/lbh/result/buf/5.6/intel/1000/war"

dir=$1

end=$((SECONDS+1800))

# Write mutex information to file every second
while [ $SECONDS -lt $end ]
do
    # Get mutex information and write it to the result file
    ${mysql_dir}/bin/mysql -uroot  \
        -e "SELECT EVENT_NAME, COUNT_STAR, SUM_TIMER_WAIT/1000000000 SUM_TIMER_WAIT_MS, \
            AVG_TIMER_WAIT/1000000000 AVG_TIMER_WAIT_MS \
            FROM performance_schema.events_waits_summary_global_by_event_name \
            WHERE SUM_TIMER_WAIT > 0 AND \
            EVENT_NAME LIKE 'wait/synch/mutex/innodb/%' \
            or EVENT_NAME LIKE 'wait/synch/sxlock/innodb/%' \
            ORDER BY SUM_TIMER_WAIT_MS DESC;" >> ${result_dir}/$dir/mutex_wait.out

    
            ${mysql_dir}/bin/mysql -uroot -pevia6587\
                -e "SHOW STATUS LIKE '%row_lock%';" >> ${result_dir}/$dir/lock_wait.out


            ${mysql_dir}/bin/mysql -uroot -pevia6587\
			-e "show engine innodb status;" >> ${result_dir}/$dir/innodb-status.txt

            ${mysql_dir}/bin/mysql -uroot -pevia6587\
            -e "SELECT EVENT_NAME, COUNT_STAR, SUM_TIMER_WAIT/1000000000 SUM_TIMER_WAIT_MS, \
            AVG_TIMER_WAIT/1000000000 AVG_TIMER_WAIT_MS \
            FROM performance_schema.events_waits_summary_global_by_event_name \
            WHERE SUM_TIMER_WAIT > 0 AND \
            EVENT_NAME LIKE 'wait/io/file/%' \
            ORDER BY SUM_TIMER_WAIT_MS DESC;" >> ${result_dir}/$dir/io_wait.out

    sleep 1
done
