#!/bin/bash

gnuplot -persist <<EOF
    # setting
	set terminal pos eps enhanced size 4,2.4 font "Helvetica,20"
	set output "spf-cpu-util.eps"
	set boxwidth 0.9
    
    set xlabel "Buffer / DB Size" offset 1.5
   
    set style line 1 lt 1 pt 4
    set style line 3 lt 3 pt 2

    set pointsize 1.6
    set key at 8.5, 52

    set xtic 0,1,9
	set xrange [0:9]

    set ytics 20,5,55 nomirror tc lt 1
    set yrange [20:55]	
    set ylabel "CPU Utilization (%)" offset 1.5

    set xtics ("5%%"1,"10%%"2,"15%%"3,"20%%"4,"25%%"5,"30%%"6,"35%%"7,"40%%"8)
	# plot
	plot 'data3.txt' using 1:2 ls 3 with linespoints title "CPU Util" ;
EOF

