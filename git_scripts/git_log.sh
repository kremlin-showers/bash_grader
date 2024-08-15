#!/usr/bin/env bash
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[32m'
YELLOW='\033[0;33m'
BLUE='\033[34m'

tail -n +2 ./.mygit_config | nl | sort -nr | cut -f 2- >> temp.txt
# Reverses the output using nl (adds numbering) sort (in reverse using that numbering) and cut (removes said numbering)
awk -f ./git_scripts/logprinter.awk temp.txt
rm temp.txt