#!/usr/bin/env bash
RED='\033[0;31m'
NC='\033[0m' # No Color
#Used to checkout a commit by providing the commit's hash value
if [[ ! -e ./.mygit_config ]]   
then
    echo -e "${RED}Initialize reposetory first!${NC}"
    exit 1
fi
GIT_DIR=$(head -n1 ./.mygit_config | cut -d: -f2)
if [[ $(grep -c "COMMIT%$1" ./.mygit_config) == "1" ]] 
then
    line=$(grep "COMMIT%$1" ./.mygit_config)
    commit=$(echo "$line" | cut -d "%" -f 2)
    find "$GIT_DIR/$commit" -name "*.csv" -exec cp {} . \;
    rm ./grades.csv
    cp "$GIT_DIR/$commit/Grading/gradechart" ./Grading/gradechart
    cp "$GIT_DIR/$commit/Grading/grades.csv" ./Grading/grades.csv
    cp "$GIT_DIR/$commit/emails/email_format" ./emails/email_format
    cp "$GIT_DIR/$commit/emails/sentmails.txt" ./emails/sentmails.txt
else
    echo -e "${RED}Commit Not found or not unique for hash provided${NC}"

fi