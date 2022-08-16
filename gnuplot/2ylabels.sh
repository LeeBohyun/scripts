#!/bin/bash

gnuplot -persist <<EOF
    # setting
	set terminal pos eps enhanced size 4,2.4 font "Helvetica,20"
	set output "spf-wait-trx.eps"
	set boxwidth 0.9
    
    set xlabel "Buffer / DB Size" offset 1.5
   
    set style line 1 lt 1 pt 4
    set style line 3 lt 3 pt 2

    set pointsize 1.6
    set key at 8.5, 280

    set xtic 0,1,9
	set xrange [0:9]

    set ytics 0,40,280 nomirror tc lt 1
    set yrange [0:300]	
    set ylabel "I/O Wait Time / Trx (ms)" offset 1.5
    set y2tics 0,0.1,1 nomirror tc lt 2 
    set y2label 'Lock Wait Time / Trx (ms)' offset -0.5
    set y2range [0:1]	

    set xtics ("5%%"1,"10%%"2,"15%%"3,"20%%"4,"25%%"5,"30%%"6,"35%%"7,"40%%"8)
	# plot
	plot 'data3.txt' using 1:2 ls 3 with linespoints title "I/O Wait" ,  'data4.txt' using 1:2 ls 1 with linespoints title "Trx Lock Wait" axes x1y2;
EOF

