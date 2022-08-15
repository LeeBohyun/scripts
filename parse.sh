#!/bin/bash

data_dir="/home/lbh/test_data"
log_dir="/home/lbh/test_log/org"
backup_dir="/home/lbh/backup/5.6-16k/tpcc1000"
result_dir="/home/lbh/result/buf/5.6/intel/1000/vanilla"

mysql_dir="/home/lbh/mysql-5.6.26"
tpcc_dir="/home/lbh/tpcc-mysql"

current_dir="/home/lbh/scripts"

pct=(  1  )
buffer_size=( "5G" "10G" "15G" "20G" "25G" "30G" "35G" "40G" )
thread=( 32 64 128 )
device="nvme0n1"


for j in "${buffer_size[@]}"
do

    for k in "${thread[@]}"
    do
    
        for i in "${pct[@]}"
        do
            result_file=${result_dir}/${j}/${k}/${i}/result.txt
            if [ -f "$result_file" ]
            then
                rm $result_file
            fi
            
            cd ${result_dir}/${j}/${k}/${i}

            echo ${result_dir}/${j}/${k}/${i} >> ${result_dir}/result.txt

            total_trx=`(cat trx.log | grep "trx" | awk '{ print $3 } '| tr -d , | awk '{ sum+=$1} END {print sum;}')`

            # TPS
            cat trx.log | grep "trx" | awk '{ print $3 } '| tr -d , | awk '{ sum+=$1} END {print "TPS: " sum/1800;}' >> ${result_dir}/result.txt

            # 95% latency
            cat trx.log | grep "trx" | awk '{ print $5 } '| tr -d , | awk '{ sum+=$1} END {print "95% latency: " sum/180;}' >> ${result_dir}/result.txt
            
            # 99% latencly
            cat trx.log | grep "trx" | awk '{ print $7 } '| tr -d , | awk '{ sum+=$1} END {print "99% latency: " sum/180;}' >> ${result_dir}/result.txt

            cat iostat.out | grep $device | awk '{ sum+=$4} END {print "read/s: " sum/1800;}' >> ${result_dir}/result.txt

            cat iostat.out | grep $device | awk '{ sum+=$5} END {print "write/s: " sum/1800;}' >> ${result_dir}/result.txt

            cat iostat.out | grep $device | awk '{ sum+=$6; sum1+=$7} END {print "rMB/wMB: " sum/1800/1000 "/" sum1/1800/1000;}' >> ${result_dir}/result.txt

            #cat iostat.out | grep $device | awk '{ sum+=$7} END {print "wMB/s: " sum/1800/1000;}' >> ${result_dir}/result.txt

            #CPU util
            cat iostat.out | grep -A 1 "idle" | awk '{ sum+=$6} END {print "CPU util(%): " 100-sum/1800;}' >> ${result_dir}/result.txt

            #Device util
            cat iostat.out | grep $device |  awk '{ sum+=$14} END {print "Device util(%): " sum/1800;}' >> ${result_dir}/result.txt
           
            total_io_wait_time=`(grep "data" io_wait.out | tail -1 | awk ' { print $3}' )`

            awk -v var1="$total_io_wait_time" -v var2="$total_trx"  'BEGIN{print "io_wait/trx: " var1/var2}'>> ${result_dir}/result.txt
           
            total_lock_time=`( tail lock_wait.out | grep "Innodb_row_lock_time" | head -1 | awk  '{ print $2}' )`

            awk -v var1="$total_lock_time" -v var2="$total_trx" 'BEGIN{print "lock wait/trx: " var1/var2}' >> ${result_dir}/result.txt

            spf_cnt=`(cat mysql_error.log | grep -c "single page flush")`
            free_cnt=`(cat mysql_error.log | grep -c "free block")`

            awk -v var1="$spf_cnt" -v var2="$free_cnt" 'BEGIN{print "spf ratio(%): " var1/var2*100}' >> ${result_dir}/result.txt

            # hit ratio
            cat innodb-status.txt | grep -oP '(?<=hit rate )[^ ]*' | awk '{sum+=$1} END {print "hit ratio: " sum/NR/10;}' >> ${result_dir}/result.txt

            echo "########################################" >> ${result_dir}/result.txt
            echo "" >> ${result_dir}/result.txt

        done       
    done
done



