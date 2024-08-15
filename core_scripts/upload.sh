#!/usr/bin/env bash
RED='\033[0;31m'
NC='\033[0m' # No Color

for (( i=2; i<=$#; i++ ))
do
# Moves the files to the current directory, Throws error if they don't exit
# For all files being inputted it standardizes rollnumber to lowercase
    if [[ -e "${!i}" ]]
    then
            paste -d, <(cut -d',' -f1 <"${!i}" | tr [:upper:] [:lower:]) <(cut -d',' -f2- <"${!i}") > temp
            mv temp "${!i}"
            mv "${!i}" .

    else
        echo -e "${RED}The file ${!i} does not exist${NC}"
    fi


done