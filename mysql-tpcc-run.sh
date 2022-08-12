#!/bin/bash

data_dir="/home/lbh/test_data"
log_dir="/home/lbh/test_log/org"
backup_dir="/home/lbh/backup/5.6-16k/tpcc1000"
result_dir="/home/lbh/result/buf/5.6/intel/1000/war"

mysql_dir="/home/lbh/mysql-5.6.26"
tpcc_dir="/home/lbh/tpcc-mysql"

current_dir="/home/lbh/scripts"

pct=(  1  )
buffer_size=( "5G" "10G" "15G" "20G" "25G" "30G" )
thread=( 64  )


echo "Start TPCC to test mutex contention"

cp my.cnf mutex_run_tpcc.sh ${result_dir}

for j in "${buffer_size[@]}"
do
    
    mkdir ${result_dir}/${j}

    for k in "${thread[@]}"
    do
    
    mkdir ${result_dir}/${j}/${k}

        for i in "${pct[@]}"
        do
            mkdir ${result_dir}/${j}/${k}/${i} 
            result_file=${result_dir}/${j}/${k}/${i}/mutex_buf.out
            if [ -f "$result_file" ]
            then
                rm $result_file
            fi

            cd /home/lbh

            echo "Start DD of SSD"
            echo "evia6587" | sudo -S umount test_data
            echo "evia6587" | sudo -S blkdiscard /dev/nvme0n1           
          
            echo "evia6587" | sudo -S dd if=/dev/zero of=/dev/nvme0n1 bs=1024k status=progress
            echo "evia6587" | sudo -S dd if=/dev/zero of=/dev/nvme0n1 bs=1024k status=progress
            sleep 3s            

            ./fdisk.sh

            sleep 1s
            echo "evia6587" | sudo -S mkfs.ext4 /dev/nvme0n1p1 
            echo "evia6587" | sudo -S mount /dev/nvme0n1p1 test_data
            echo "evia6587" | sudo chown -R lbh:lbh test_data


            echo "Start TPCC to test mutex contention"
            # Remove existing data
            rm -rf ${data_dir}/*
            rm -rf ${log_dir}/*

            # Copy data
            cp -r ${backup_dir}/data/* ${data_dir}/
            cp -r ${backup_dir}/log/* ${log_dir}/


            # Run MySQL server
            echo "RUN MYSQL SERVER"
            cd ${mysql_dir}
            ./bin/mysqld --defaults-file=${current_dir}/my.cnf --innodb_buffer_pool_size=${j}  & >/dev/null &disown
            #./bin/mysqld --defaults-file=${current_dir}/my.cnf --innodb_page_cleaners=${i} --innodb_buffer_pool_size=${j}  --skip-log-bin & >/dev/null &disown
        
            sleep 60s

            # Run TPC-C benchmark
            echo "START TPCC BENCHMARK"
            #echo "evia6587" | sudo -S service sysstat restart

            mount >  ${result_dir}/${j}/${k}/${i}/mountinfo.out

            sleep 60s
                
            iostat -x 1 >> ${result_dir}/${j}/${k}/${i}/iostat.out &
            
            cd ${current_dir}
            ./mutex_contention_monitoring.sh ${j}/${k}/${i} &

            #echo "evia6587" | sudo -S btrace /dev/nvme1n1 | grep "D\s\+W\|D\s\+R\|A\s\+F|C\s\+W\|C\s\+R\|A\s\+F" > ${result_dir}/btrace.out &

            cd ${tpcc_dir}
            ./tpcc_start -h127.0.0.1 -S/tmp/mysql.sock -P3306 -dtpcc1000 -uroot -pevia6587 -w1000 -c${k} -r10 -l1800 > ${result_dir}/${j}/${k}/${i}/trx.log 

            ${mysql_dir}/bin/mysql -uroot -pevia6587\
                -e "SELECT EVENT_NAME, COUNT_STAR, SUM_TIMER_WAIT/1000000000 SUM_TIMER_WAIT_MS, \
                 AVG_TIMER_WAIT/1000000000 AVG_TIMER_WAIT_MS \
                FROM performance_schema.events_waits_summary_global_by_event_name \
                WHERE SUM_TIMER_WAIT > 0 AND \
                EVENT_NAME LIKE 'wait/io/file/%' \
                ORDER BY SUM_TIMER_WAIT_MS DESC;" >> ${result_dir}/${j}/${k}/${i}/io_wait.out

            ${mysql_dir}/bin/mysql -uroot -pevia6587\
                -e "SHOW STATUS LIKE '%row_lock%';" >> ${result_dir}/${j}/${k}/${i}/lock_wait.out


            ${mysql_dir}/bin/mysql -uroot -pevia6587\
			-e "show engine innodb status;" >> ${result_dir}/${j}/${k}/${i}/innodb-status.txt

            killall -9 iostat mysqld tpcc_start
            sleep 60s
            killall -9 iostat mysqld 
            killall -9 iostat mysqld 

            cp ${data_dir}/mysql_error.log ${result_dir}/${j}/${k}/${i}
            
            cd $current_dir
            ./parse.sh ${result_dir}/${j}/${k}/${i}
	    
        
            echo "DONE SINGLE TEST"

            sleep 60s

        done
        
    done
done
