#!/usr/bin/env bash

standard_deviation () {
    awk -F, '{sum+=$NF; array[NR]=$NF} END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);} print sqrt(sumsq/NR)}' $1
}
mean() {
    awk -F, '{sum+=$NF} END {print sum/NR}' $1
}
# Uses a basic relative grading scheme taken from here (used earlier in IITR)
relgrade() {
    if [[ ! -e main.csv ]]
    then        
        echo "Combine first before using grades!"
        exit 1
    fi

    #Checks if Total is shown in main.csv
    if [[ $(grep "Total" main.csv) == "" ]]
    then
        echo "First use Total"
        exit 1
    fi
    echo "Roll Number,Name,Marks,Grade" > ./Grading/grades.csv
    std_dev=$(standard_deviation main.csv)
    mean=$(mean main.csv)
    while read -r line 
    do
        roll=$(echo "$line" | cut -d, -f1,2)
        marks=${line##*,}
        if [[ $marks == "Total" ]]
        then
            continue
        fi
        if [[ $(echo "$marks >= $(echo "$mean+1.5*$std_dev" | bc -l)" | bc -l) == "1" ]]
        then
            grade="AA"
        elif [[ $(echo "$marks >= $(echo "$mean+$std_dev" | bc -l)" | bc -l) == "1" ]]
        then
            grade="AB"
        elif [[ $(echo "$marks >= $(echo "$mean+0.5*$std_dev" | bc -l)" | bc -l) == "1" ]]
        then   
            grade="BB"
        elif [[ $(echo "$marks >= $(echo "$mean" | bc -l)" | bc -l) == "1" ]]
        then
            grade="BC"
        elif [[ $(echo "$marks >= $(echo "$mean-0.5*$std_dev" | bc -l)" | bc -l) == "1" ]]
        then
            grade="CC"
        elif [[ $(echo "$marks >= $(echo "$mean-$std_dev" | bc -l)" | bc -l) == "1" ]]
        then
            grade="CD"
        elif [[ $(echo "$marks >= $(echo "$mean-1.5*$std_dev" | bc -l)" | bc -l) == "1" ]]
        then
            grade="DD"
        else
            grade="FR"
        fi

        echo "$roll,$marks,$grade" >> ./Grading/grades.csv
    done < main.csv

}
# Uses the provided file as a key for the grading.
# Format of grading file:
# Grade: Marks
# All students with marks >= Marks will be given Grade



if [[ $# -ge 1 ]]
then
    if [[ "$1" == "rel" ]]
    then
        relgrade

    elif [[ "$1" == "abs" ]]
    then

            if [[ ! -e main.csv ]]
            then        
                echo "Combine first before using grades!"
                exit 1
            fi

            #Checks if Total is shown in main.csv
            if [[ $(grep "Total" main.csv) == "" ]]
            then
                echo "First use Total"
                exit 1
            fi

            if [[ ! -e "$2" ]]
            then
                echo "File $2 does not exist"
                exit 1
            fi
            declare -a markarr
            declare -a gradearr
            while read -r line 
            do
                grade=$(echo "$line" | cut -d: -f1)
                marks=$(echo "$line" | cut -d: -f2)
                marks=${marks//[$'\n\r']/}
                if [[ ! $marks =~ [0-9]+ ]]
                then
                    echo "Invalid format for marks!"
                    exit 1
                fi
                if [[ $grade == "" ]]
                then
                    echo "Invalid format for grades!"
                    exit 1
                fi
                markarr+=("$marks")
                gradearr+=("$grade")
            done < "$2"
            echo "Roll Number,Name,Marks,Grade" > ./Grading/grades.csv

            while read -r line 
            do
                roll=$(echo "$line" | cut -d, -f1,2)
                marks=${line##*,}
                if [[ $marks == "Total" ]]
                then
                    continue
                fi
                for ((i=0;i<${#markarr[@]};i++))
                do
                    if [[ $(echo "$marks >= ${markarr[i]}" | bc -l) == "1" ]]
                    then
                        grade=${gradearr[i]}
                        break
                    fi
                done
                echo "$roll,$marks,$grade" >> ./Grading/grades.csv
            done < main.csv


    fi
else
    relgrade
fi
