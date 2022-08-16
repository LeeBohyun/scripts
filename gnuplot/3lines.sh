#!/bin/bash
#input=$1

gnuplot -persist <<EOF
    # setting
	set terminal pos eps enhanced size 4,2.4 font "Helvetica,20"
	set output "spfratio.eps"
	set boxwidth 0.9
    set ylabel "Read Stall Ratio(%)" offset 1.5
    set xlabel "Buffer / DB Size" offset 1.5
   
    set style line 1 lt 1 pt 4
    set style line 2 lt 2 pt 7
    set style line 3 lt 3 pt 2

    set pointsize 1.6
    set key at 8.5, 37
    set ytic 0,5,40
    set xtic 0,1,9
	set yrange [0:40]	
	set xrange [0:9]

    set xtics ("5%%"1,"10%%"2,"15%%"3,"20%%"4,"25%%"5,"30%%"6,"35%%"7,"40%%"8)
	# plot
	plot 'data.txt' using 1:2 ls 3 with linespoints title "32 threads",  'data1.txt' using 1:2 ls 1 with linespoints title "64 threads",  'data2.txt' using 1:2 ls 2 with linespoints title "128 threads"
EOF

