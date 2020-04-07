#!/bin/bash

if [ $# -eq 0 ]; then
	echo ""
	echo " profile_single.sh"
	echo ""
	echo " Create 2D profile from a pair of given coordinates and with input .grd data"
	echo ""
	echo "      Usage:   profile_single.sh \$input_grd "
	echo ""
	echo "      Example: profile_single.sh disp_2018135_ll.grd "
	echo ""
	exit 1
fi


make_profile.py --a $1
make_profile.sh $1 coords.txt profil

x1=$(cat coords.txt | head -1 | awk '{print $1}')
y1=$(cat coords.txt | head -1 | awk '{print $2}')
x2=$(cat coords.txt | tail -1 | awk '{print $1}')
y2=$(cat coords.txt | tail -1 | awk '{print $2}')

num=$RANDOM
mv profil.png profil_$num.png

echo "Profile beginning: "
echo $x1 $y1
echo "Profile end: "
echo $x2 $y2
echo "Output file: profil_$num.png"

rm coords.txt cross_profile gmt.conf gmt.history profil.ps profile.xyz track_xyz