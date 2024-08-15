#!/usr/bin/env bash

RED='\033[0;31m'
NC='\033[0m' # No Color

if [[ -e "main.csv" ]]
then
    #Check if total is shown in main.csv 
    #Checks first line of main.csv for total column
    line1=$(head -n 1 main.csv)
    line1=${line1##*,}

    if [[ $line1 == "Total" ]]
    then
        total=1
    else
        total=0
    fi
    rm main.csv
fi

#If main.csv does not exist, this means that the command is being run for the first time. In this case we first standardize all csv files to lowercase
if [[ ! -e main.csv ]]
then
        for i in *.csv
        do
            paste -d, <(cut -d',' -f1 <"$i" | tr [:upper:] [:lower:]) <(cut -d',' -f2- <"$i") > temp
            mv temp "$i"
        done
fi

#If no arguments are provided, then all csv files in the current directory are considered
if [[ $# == "1" ]]
then
# Array of all the csv files in current directory
    declare -a csvs=(*.csv)
else
    for ((i=2;i<=$#;i++))
    {
        if [[ -e ${!i} ]]
        then
            csvs[i - 1]=${!i}
        else
            echo -e "${RED}The file ${!i} does not exist${NC}"
        fi  
    }
    if [[ ${#csvs[@]} -eq 0 ]]
    then
        echo -e "${RED}No valid files found${NC}"
        exit 1
    fi
fi

awk -f ./core_scripts/combining.awk "${csvs[@]}" > main.csv

#If total is shown in main.csv then calculate new total
if [[ total -eq 1 ]]
then
        awk -f ./core_scripts/Totalling.awk main.csv > main_temp.csv
        mv main_temp.csv main.csv
fi