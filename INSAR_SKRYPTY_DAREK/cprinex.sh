#!/bin/bash

awk '{print $2}' 95 > 1.tmp
awk -F'.' '{print $1=$1+1"0."}' 1.tmp > 11.tmp
awk '{print $1}' 11.tmp | cut -c5-9 > 111.tmp
awk '{print $1}' 11.tmp | cut -c3-4 > 2.tmp
paste -d'\0' 111.tmp 2.tmp > 3.tmp

rm 1.tmp 2.tmp 11.tmp 111.tmp

mv 3.tmp okfg
cd okfg

filename='3.tmp'
file=`cat $filename`

for line in $file;
do
	cp *$line'd.Z' ../OKFG1
done


