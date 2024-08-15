#!/usr/bin/env bash
RED='\033[0;31m'
NC='\033[0m' # No Color
    if [[ $# -eq 2 ]]
    then
        if [[ -d $2 ]]
        then
            echo "PATH:$(realpath "$2")" > ./.mygit_config
        elif [[ -f "$2"  ]]
        then
            echo "Usage: bash submission.sh git_init Path_To_Folder"
        else
            mkdir "$2"
            echo "PATH:$(realpath "$2")" > ./.mygit_config
        fi

        
    else
        echo -e "${RED}Usage: bash submission.sh git_init Path_To_Folder${NC}"
    fi
