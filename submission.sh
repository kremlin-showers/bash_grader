#!/usr/bin/env bash

RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[0;33m'


if [[ "$#" == "0" ]]
then
    echo "Usage: bash submission.sh <command> <arguments>"
    echo "For help run bash submission.sh help"
    exit 1
fi

if [[ "$1" == "email" ]]
then
    echo "Do you wish to send mail to all students or particular student"
    select student in "all" "particular"
    do
        if [[ $student == "all" ]]
        then
            echo "Enter the course name"
            read course
            echo "Enter the sender name"
            read sender
            echo "Select the quiz whose marks should be sent to student"
            # Send the email to all students
            select quiz in "all" $(head -n 1 main.csv | tr "," "\n" | tail -n +3 | head -n -1)
            do
                ./emails/emails.sh "all" "course" "sender" "$quiz"
                break
            done
            break
        else
            echo "Enter the roll number of the student"
            read roll
            roll=$(echo "$roll" | tr '[:upper:]' '[:lower:]')
            echo "Enter the Name of the student"
            read name
            echo "Enter the course name"
            read course
            echo "Enter the sender name"
            read sender
            # Checking valid name and roll number
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
                        echo "Name Does not match Roll No!"
                        exit 0
                    else
                        break
                    fi
                fi
            done
            test=$(grep -i "$roll" main.csv)
            if [[ $test == "" ]]
            then
                echo "Roll Number not found"
                exit 1
            fi
            echo "Select the quiz whose marks should be sent to student"
            select quiz in "all" $(head -n 1 main.csv | tr "," "\n" | tail -n +3 | head -n -1)
            do
                # Runs the emails script that deals with sending emails
                ./emails/emails.sh "$roll" "$course" "$sender" "$quiz"
                break
            done

                        
        fi
        break
    done
fi


if [[ "$1" == "combine" ]]
then
    ./core_scripts/combine_faster.sh "$@"
fi

if [[ "$1" == "update" ]]
then
    ./core_scripts/update.sh
fi

if [[ $1 == 'upload' ]]
then
    ./core_scripts/upload.sh "$@"
fi

if [[ $1 == 'git_init' ]]
then

    ./git_scripts/git_init.sh "$@"

fi

if [[ $1 == "total"  ]]
then
    ./core_scripts/total.sh
fi

if [[ $1 == "git_commit" ]]
then
    ./git_scripts/git_commit.sh "$@"
fi

if [[ $1 == "git_checkout" ]]
then
#Usage: ./submission.sh git_checkout <Hash_Value of Commit>
    ./git_scripts/git_checkout.sh "$2"
fi

if [[ $1 == "git_log" ]]
then
    ./git_scripts/git_log.sh
fi

if [[ "$1" == "print" || "$1" == "p" ]]
then
    echo "Select file whose statistics to be printed (main.csv prints total statistics) (Type number corresponding to file)"
    select file in *.csv
    do
        ./Statistics/basicstats.sh "$file"
        break
    done
    
fi

#Grades command creates a seperate file with Name, Roll No and grades: called grades.csv in the Grading directory
if [[ "$1" == "grade" ]]
then
    # if [[ $# -gt 2 ]]
    # then
    #     ./Grading/grades.sh "$2" "$3"
    # else
    #     ./Grading/grades.sh
    # fi
    echo "Do you wish to Use absolute or relative grading? (Absolute grading is done using the gardechart file in the Grading subdirectory by default, otherwise you can provide a file)"
    select choice in "abs" "rel"
    do
        if [[ $choice == "abs" ]]
        then
            if [[ -e "$2" ]]
            then
                ./Grading/grades.sh abs "$2"
            else
                ./Grading/grades.sh abs "./Grading/gradechart"
            fi
        elif [[ $choice == "rel" ]]
        then
            select type in "Grade By Standard Deviation" "Grade By K-Clusters"
            do
                if [[ $type == "Grade By Standard Deviation" ]]
                then
                    ./Grading/grades.sh rel
                elif [[ $type == "Grade By K-Clusters" ]]
                then
                    python3 ./Grading/kmeans_grading.py
                fi
                break

            done
        fi
        break
    done
fi  

#Implements a method to show various graphs.
if [[ "$1" == "graph" ]]
then
        # if [[ "$2" == "scatter" ]]
        # then
        #     python3 ./Graphing/Graphing.py scatter $3
        # elif [[ "$2" == "compare" ]]
        # then
        #     python3 ./Graphing/Graphing.py compare
        # fi
        echo "Do You wish to plot graphs for individual students or for the entire class?"
        select choice in "Individual" "Class"
        do
            if [[ $choice == "Individual" ]]
            then
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
                if [[ $(grep "$RollNo" ./main.csv) == "" ]]
                then
                    echo -e "${RED} This roll number does not exist! ${NC}"
                    exit 0;
                fi
                python3 ./Graphing/Graphing.py student $RollNo

            elif [[ $choice == "Class" ]]
            then
    
                echo "Select file whose marks to be graphed (main.csv prints total statistics) (Type number corresponding to file)"
                select file in *.csv
                do
                    echo "Select Type of Graph to Display"
                    if [[ $file == "main.csv" ]]
                    then
                        select graph in "histogram" "scatter" "histogram of grades" "scatter with grades"
                        do
                            python3 ./Graphing/Graphing.py "$graph" "$file"
                            break
                        done
                    else
                        select graph in "histogram" "scatter"
                        do
                            python3 ./Graphing/Graphing.py "$graph" "$file"
                            break
                        done
                    fi
                    break
                done
            fi
            break
        done
fi



if [[ "$1" == "help" ]]
then
    echo -e "${YELLOW}Usage:${NC} bash submission.sh <command> <arguments>"
    echo -e "${YELLOW}Commands:${NC}"
    echo -e "${YELLOW}combine <file1> <file2> <file3> ... :${NC} Combines all the files into a single file"
    echo -e "${YELLOW}update :${NC} Updates the main.csv file"
    echo -e "${YELLOW}upload <file1> <file2> <file3> ... :${NC} Uploads the files to the server"
    echo -e "${YELLOW}git_init <repo_name> :${NC} Initializes a git repository"
    echo -e "${YELLOW}git_commit <commit_message> :${NC} Commits the changes to the git repository"
    echo -e "${YELLOW}git_log:${NC} Gives the log of commits"
    echo -e "${YELLOW}total :${NC} Prints the total statistics of the main.csv file"
    echo -e "${YELLOW}print :${NC} Prints the statistics of a file"
    echo -e "${YELLOW}grade :${NC} Creates a file with Name, Roll No and grades"
    echo -e "${YELLOW}email :${NC} Used to send email with marks to students"
fi
