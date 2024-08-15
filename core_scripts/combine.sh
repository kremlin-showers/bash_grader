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


declare -A Rollkey 
for ((i=0; i < ${#csvs[@]}; i++))
do
    #append , to all existing Roll Numbers
    for k in "${!Rollkey[@]}"
    do
        Rollkey[$k]+=","
    done

    # Start Reading File
    while read -r Line || [ -n "$Line" ]
    do
        # Get Roll No and Marks from current line
        roll=${Line%,*}
        rollno=${Line%%,*}
        rollno=${rollno,,}
        name=${roll#*,}
        roll="$rollno,$name"

        # Since roll numbers are case insensitive, we standardize them to lowercase
        marks=${Line##*,}
        # Remove all problematic trailing charecters
        currentcommas=""
        #Ignoring the Labelling Column
        if [[ $marks != "Marks" ]]
        then
            for ((j=0; j<i ;j++))
            do
                currentcommas+=","
            done
            if [[ ${Rollkey[$roll]} == "" ]]
            then
                    Rollkey[$roll]=$currentcommas
            fi
            Rollkey[$roll]+="$marks"
        fi

        

    done < "${csvs[$i]}"
    # If current roll No exists in array then add marks to the value
    # If current roll No does not exist in array then add i number of , to its value and then add current marks to its value
done
# Addding header to main file
Header="Roll_Number,Name"
for x in "${csvs[@]}"
do
    Header+=",${x%.csv}"
done
echo "$Header" >> main.csv

for k in "${!Rollkey[@]}"
do
# Adding Appropriate absents
    current="$k,${Rollkey[$k]}"
    current=$(echo "$current" | sed 's/,$/,a/; s/,,/,a,/g')
    echo "$current" >> main.csv
done

#If total is shown in main.csv then calculate new total
if [[ total -eq 1 ]]
then
        awk -f ./core_scripts/Totalling.awk main.csv > main_temp.csv
        mv main_temp.csv main.csv
fi