#!/bin/bash

if [ $# -eq 0 ]; then
	echo ""
	echo " profile_multiple.sh"
	echo ""
	echo " Create 2 profile comparison from a pair of given coordinates and with input .grd data"
	echo ""
	echo "      Usage:   profile_multiple.sh \$input_grd1 \$input_grd2 "
	echo ""
	echo "      Example: profile_multiple.sh asc.grd dsc.grd "
	echo ""
	exit 1
fi


make_profile.py --a $1
compare_profiles.sh $1 $2 coords.txt comp

x1=$(cat coords.txt | head -1 | awk '{print $1}')
y1=$(cat coords.txt | head -1 | awk '{print $2}')
x2=$(cat coords.txt | tail -1 | awk '{print $1}')
y2=$(cat coords.txt | tail -1 | awk '{print $2}')

num=$RANDOM
mv comp.png comp_$num.png

echo "Profile beginning: "
echo $x1 $y1
echo "Profile end: "
echo $x2 $y2
echo "Output file: comp_$num.png"

rm coords.txt gmt.conf gmt.history