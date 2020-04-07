#!/bin/bash
#
# Darek Głąbicki 2019
#
# Script to create 2D profile across given coordinates from input .grd data
#
#
# Usage: 	make_profile.sh $input_grd $profile_start-end $output
#			make_profile.sh disp_2018135_ll.grd profile.xy profileA
#
if [ $# -eq 0 ]; then
	echo ""
	echo " make_profile.sh"
	echo ""
	echo " Create 2D profile from a pair of coordinates and with input .grd data"
	echo ""
	echo "      Usage:   make_profile.sh \$input_grd \$profile_start-end_file \$output_name"
	echo ""
	echo "      Example: make_profile.sh disp_2018135_ll.grd profile.xy profileA "
	echo ""
	exit 1
fi


gmt set MAP_TICK_LENGTH_PRIMARY	5p/10p 
gmt set MAP_TICK_LENGTH_SECONDARY 10p/1.5p


profile_interval=1e
profile_xy_data=$2
input_grd=$1
psout=$3.ps


gmt sample1d $profile_xy_data -I$profile_interval > cross_profile
gmt grdtrack cross_profile -G$input_grd > profile.xyz
gmt mapproject profile.xyz -Ge -o3,2 > track_xyz


x1=$(cat $2 | head -1 | awk '{print $1}')
y1=$(cat $2 | head -1 | awk '{print $2}')
x2=$(cat $2 | tail -1 | awk '{print $1}')
y2=$(cat $2 | tail -1 | awk '{print $2}')
length=$(echo "(sqrt( ( ($x2*c($y2*0.0174533)*111321) - ($x1*c($y1*0.0174533)*111321) )^2 + ( ($y2*111321) - ($y1*111321) )^2 ))" | bc -l)
profile_extent=0/$length/-1300/200

gmt psxy track_xyz -R$profile_extent -Bxafg+l"Profile length [m]" -Byaf+l"LOS displacement [mm]" -BWSne -JX10i/2i -W1p  -V > $psout
#gmt psxy -R -J -O  -W1p $in -V   >> $ps
#######################################################################################
gmt psconvert $psout -P -D. -A -E300 -Tg

#rm -f cross_profile profile.xyz track_xyz $3.ps