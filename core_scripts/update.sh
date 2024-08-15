#!/usr/bin/env bash

RED='\033[0;31m'
NC='\033[0m' # No Color

#This first edits all the required csv files using sed
#Followed by running combine again to generate proper main.csv

#Current Functionality: If roll no exists then checks for match in name. If roll no does not exist (present in none of the csv files) then adds new column
#IE update can be used to "add" a new student as well

declare -a csvs
csvs=(*.csv)
echo "Enter the RollNo of the student"
read -r RollNo
echo "Enter the Name of the student"
read -r name
#Standardizes RollNo to lowercase
RollNo=$(echo "$RollNo" | tr '[:upper:]' '[:lower:]')
# Checks if the rollNo,name is valid or not
for i in "${csvs[@]}"
do
    test1=$(grep -i "$RollNo" "$i")
    if [[ $test1 == "" ]]
    then
        continue
    else
        test2=$(grep -i "$RollNo,$name" "$i")
        if [[ $test2 == "" ]]
        then
            echo -e "${RED}Name Does not match Roll No!${NC}"
            exit 1
        else
            break
        fi
    fi
done


for i in "${csvs[@]}"
do
    if [[ $i != "main.csv" ]]
    then
        echo "Do you wish to modify marks in $i (1 or 2)"
        select yn in "Yes" "No"; do
        if [[ $yn == "Yes" ]]
        then
            echo "Enter the marks received by student in $i:"
            read -r marks
            # Checks if marks is a number
            if [[ ! $marks =~ ^[0-9\.]+$ ]] ; then
                echo -e "${RED}Invalid format for marks!${NC}"
                exit 1
            fi
            #If RollNo present in current file then uses sed, otherwise appends RollNo to the list
            test1=$(grep -i "$RollNo,$name" $i)
            if [[ $test1 == "" ]]
            then
                echo "$RollNo,$name,$marks" >> $i
            else
                sed -i "s/$RollNo,$name.*/$RollNo,$name,$marks/" $i
            fi

            break
        else
            break
        fi
        done
    fi
done

# Runs combine again just to properly modify main.csv
if [[ -e main.csv ]]
then
    ./core_scripts/combine_faster.sh combine
fi