#!/bin/bash

level0_size=( 4 8 16 32 64 )

for i in "${level0_size[@]}"
do
    mkdir /home/vldb/result/cns/${i}

    rm -r /home/vldb/CNS/*

    RESULT=/home/vldb/result/cns/${i}
    IOSTAT_RESULT=${RESULT}/iostat.out
    MPSTAT_RESULT=${RESULT}/mpstat.out


    echo "vldb#7988" | sudo -S iostat -x 10 &> ${IOSTAT_RESULT} &
    echo "vldb#7988" | sudo -S mpstat 10 &> ${MPSTAT_RESULT} &

    ./db_bench -db=/home/vldb/CNS --benchmarks=fillrandom \
        -use_direct_reads -key_size=16 -value_size=800 \
        -target_file_size_base=2147483648 \
        -use_direct_io_for_flush_and_compaction \
        -max_bytes_for_level_multiplier=4 -write_buffer_size=2147483648 \
        -level0_file_num_compaction_trigger=${i} \
        -target_file_size_multiplier=1 -duration=1800 -threads=48 \
        -max_background_jobs=32 -statistics=true -stats_level=5 \
        -stats_interval_seconds=60 | tee ${RESULT}/log.out

    echo "vldb#7988" | sudo -S pkill -15 iostat
    echo "vldb#7988" | sudo -S pkill -15 mpstat
    sleep 10s

done
