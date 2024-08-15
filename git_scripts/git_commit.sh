#!/usr/bin/env bash
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[32m'
YELLOW='\033[0;33m'
BLUE='\033[34m'
scriptfiles=$(find . -type f -name "*.sh")

if [[ $1 == "git_commit" ]]
then
    # Since Only CSV files are important for our programme
    # Also assuming hashes don't collide (very low likeleyhood anyways)
    if [[ -e "./.mygit_config" ]] && [[ $(head -n1 ./.mygit_config ) =~ "PATH:" ]]
    then
        git=$(head -n1 ./.mygit_config)
        git=${git/#PATH:}
        git=$(echo "$git" | tr -d  "\n\r")
        hash=$(bash ./git_scripts/hashgenerator.sh)
        hashdir="$git"
        hashdir+="/"
        hashdir+="$hash"
        if [[ $# -eq 3 ]] && [[ $2 == "-m" ]]
        then
            commit_message=$3
        elif [[ $# -eq 2 ]] && [[ $2 == "-m" ]]
        then
            vi ./temp_message.tmp
            commit_message=$(head -n 1 temp_message.tmp | tr -d "\n\r")
            rm ./temp_message.tmp
        fi
        if [[ $2 != "-m" ]]
        then
            echo -e "${RED}Usage: ./submission.sh git-commit -m Message${NC}"
            exit 0
            
        fi

        if [[ ! -e $hashdir ]]
        then
            mkdir "$hashdir"
        fi
        cp ./*.csv "$hashdir"
        mkdir "$hashdir/emails"
        cp ./emails/* "$hashdir/emails"
        mkdir "$hashdir/Grading"
        cp ./Grading/* "$hashdir/Grading"
        commit_time=$(date)
        echo "COMMIT%$hash%$commit_message%$commit_time" >> ./.mygit_config
        echo -e "The hash for this commit is: ${GREEN}$hash${NC}"
        echo -e "Time: ${YELLOW}$commit_time${NC}"
    fi

fi