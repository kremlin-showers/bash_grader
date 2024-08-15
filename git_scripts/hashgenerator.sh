#!/usr/bin/env bash


hash=""

for ((i=0;i<16;i++))
do
    hash+=$(shuf -i 0-9 -n 1)
done
echo $hash