#!/bin/bash


cd data
for grid in $(ls -1 *.grd);
do
	echo ${grid:0:-4}
done