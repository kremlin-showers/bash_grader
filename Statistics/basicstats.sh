#!/usr/bin/env bash

#Usage: input csv file as command line argument and takes last column of CSV file and calculates various statistics

mean() {
    awk -F, '{sum+=$NF} END {print sum/NR}' $1
}

median () {
    awk -F, '{print $NF}' $1 | sort -n | awk ' { a[i++]=$1; } END { x=int((i+1)/2); if (x < (i+1)/2) { print (a[x-1]+a[x])/2; } else { print a[x-1]; } }'
}

standard_deviation () {
    awk -F, '{sum+=$NF; array[NR]=$NF} END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);} print sqrt(sumsq/NR)}' $1
}

third_quartile () {
    awk -F, '{print $NF}' $1 | sort -n | awk ' { a[i++]=$1; } END { x=int((i+1)*3/4); if (x < (i+1)*3/4) { print (a[x-1]+a[x])/2; } else { print a[x-1]; } }'
}



echo "Mean: $(mean "$1")"
echo "Median: $(median "$1")"
echo "Standard Deviation: $(standard_deviation "$1")"
echo "Third Quartile: $(third_quartile "$1")"
