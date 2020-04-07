#!/bin/bash

# 2019 Darek Glabicki

# Get a list of Sentinel-1 image dates from a directory with data


rm dates.txt
for file in $(ls -d */);
	do
		echo ${file:17:8} >> dates.txt
done

sort -n -k1.1,1.8 dates.txt > dates.txt2
rm dates.txt
mv dates.txt2 dates.txt