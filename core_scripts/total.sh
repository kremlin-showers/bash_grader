#!/usr/bin/env bash
RED='\033[0;31m'
NC='\033[0m' # No Color

if [[ -e main.csv ]]
then
    awk -f ./core_scripts/Totalling.awk main.csv > main_temp.csv
    mv main_temp.csv main.csv
else
    echo -e "${RED}Combine first before using total!${NC}"
fi
