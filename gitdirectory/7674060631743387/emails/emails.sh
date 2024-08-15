#!/usr/bin/env bash
RED='\033[0;31m'
NC='\033[0m' # No Color
# This script will send an email to each student or a particular student
# With their grades and marks for each quiz
# First cli is all then sends mail to all students with marks from all quizzes (Also grade if grades.csv exists), in this case second cli is course name and third cli is sender name
# If the first cli is the not all then it is taken to be sending mail to a particular student
# In this case the second cli is the roll number of the student and the third cli is the course name, fourth is sender name
# Last cli indicates weather to send email to all quizes or a particular quiz
if [[ "$1" == "all" ]]
then
    coursename="$2"
    sendername="$3"
    quizzes="$4"
    # Send the email to all students
    touch temp_mail.txt
    exams=($(head -n 1 main.csv | tr "," "\n" | tail -n +3 | head -n -1))
    while read -r line || [[ -n "$line" ]]
    do
        if [[ "$line" =~ "Roll_Number" ]]
        then
            continue
        fi
        IFS=',' read -r -a array <<< "$line"
        roll_number=${array[0]}
        name=${array[1]}
        email="$roll_number@iitb.ac.in"
        cp ./emails/email_format temp_mail.txt
        sed -i "s/{name}/$name/g" temp_mail.txt
        sed -i "s/{coursename}/$coursename/g" temp_mail.txt
        if [[ -e ./Grading/grades.csv ]]
        then
            fingrade=$(grep $roll_number ./Grading/grades.csv | cut -d',' -f4)
        fi
        for ((i=2;i<${#array[@]};i++))
        do
            exam=${exams[$i-2]}
            grade=${array[$i]}
            if [[ $exam == "$quizzes" || $quizzes == "all" ]]
            then
                echo "$exam: $grade" >> temp_mail.txt
            fi
        done
        if [[ $quizzes == "all" ]]
        then
            echo "Your grade for the entire course is $fingrade" >> temp_mail.txt
        fi

        echo "Regards," >> temp_mail.txt
        echo "$sendername" >> temp_mail.txt
       # mail -s "$coursename Your Grades for the entire course" -a "From: $sendername" $email < temp_mail.txt
        cat temp_mail.txt
        rm temp_mail.txt
        break

    done < main.csv

else

    roll_number="$1"
    # Converts roll_number to lowercase
    roll_number=$(echo "$roll_number" | tr '[:upper:]' '[:lower:]')
    coursename="$2"
    sendername="$3"
    quizzes="$4"
    # Send the email to a particular student
    touch temp_mail.txt
    exams=($(head -n 1 main.csv | tr "," "\n" | tail -n +3 | head -n -1))
    line=$(grep $roll_number main.csv)
    IFS=',' read -r -a array <<< "$line"
    name=${array[1]}
    email="$roll_number@iitb.ac.in"
    cp ./emails/email_format temp_mail.txt
    sed -i "s/{name}/$name/g" temp_mail.txt
    sed -i "s/{coursename}/$coursename/g" temp_mail.txt
    if [[ -e ./Grading/grades.csv ]]
    then
        fingrade=$(grep $roll_number ./Grading/grades.csv | cut -d',' -f4)
    fi
    for ((i=2;i<${#array[@]};i++))
    do
        exam=${exams[$i-2]}
        grade=${array[$i]}
        if [[ $exam == "$quizzes" || $quizzes == "all" ]]
        then
            echo "$exam: $grade" >> temp_mail.txt
            sentgrade=$grade
        fi
    done
    if [[ $quizzes == "all" && -e ./Grading/grades.csv ]]
    then
        echo "Your grade for the entire course is $fingrade" >> temp_mail.txt
    fi
    echo "Regards," >> temp_mail.txt
    echo "$sendername" >> temp_mail.txt
    sentmail="$roll_number"
    if [[ $quizzes == "all" ]]
    then
        sentmail+=":all"
        for ((i=2;i<${#array[@]};i++))
        do
            exam=${exams[$i-2]}
            grade=${array[$i]}
            sentmail+=":$exam:$grade"
            if [[ -e ./Grading/grades.csv ]]
            then
                sentmail+=":$fingrade"
            fi
        done
    else
        sentmail+=":$quizzes:$sentgrade"
    fi
    if [[ $(grep $sentmail ./emails/sentmails.txt) != "" ]] || [[ $(grep "$roll_number.*$quizzes:$sentgrade:.*" ./emails/sentmails.txt) != "" ]]
    then
        echo -e "${RED}The email you are sending contains information the student already knows. Do you wish to send it anyways?${NC}"
        select yn in "Yes" "No"; do
        if [[ $yn == "Yes" ]]
        then
            mail -s "$coursename Your Grades for the entire course" -a "From: $sendername" $email < temp_mail.txt
            echo $sentmail >> ./emails/sentmails.txt
            rm temp_mail.txt
            exit 0
        else
            rm temp_mail.txt
            exit 0
        fi
        break
        done

    fi
    if [[ $(grep "$roll_number.*$quizzes.*" ./emails/sentmails.txt) != "" ]]
    then
        mail -s "$coursename Your Grades for the entire course following re-evaluation" -a "From: $sendername" $email < temp_mail.txt
        #The string added to sentmails.txt is of the folllowing format
        #RollNo:Quiz:Quiz_marks:Grade (If grade is sent in the mail that is)
        echo $sentmail >> ./emails/sentmails.txt        
        rm temp_mail.txt
        exit 0
    fi

    mail -s "$coursename Your Grades for the entire course" -a "From: $sendername" $email < temp_mail.txt
    #The string added to sentmails.txt is of the folllowing format
    #RollNo:Quiz:Quiz_marks:Grade (If grade is sent in the mail that is)
    echo $sentmail >> ./emails/sentmails.txt
    
    rm temp_mail.txt
fi