#!/bin/bash
#
# Script to compare 2 2D profiles created across given coordinates from input .grd data
#
#
# Usage: 	make_profile.sh $input_grd1 $input_grd2 $profile_start-end $output
#			make_profile.sh disp_2018135_corr.grd disp_2018135_nocorr.grd profile.xy profilecomp
#
gmt set MAP_TICK_LENGTH_PRIMARY	5p/10p 
gmt set MAP_TICK_LENGTH_SECONDARY 10p/1.5p
gmt set FONT_ANNOT_PRIMARY 14p,Helvetica-Bold

profile_interval=10e
profile_xy_data=$3
input_grd1=$1
input_grd2=$2
psout=$4.ps


gmt sample1d $profile_xy_data -I$profile_interval > cross_profile
gmt grdtrack cross_profile -G$input_grd1 > profile1.xyz
gmt grdtrack cross_profile -G$input_grd2 > profile2.xyz
gmt mapproject profile1.xyz -Ge -o3,2 > track1_xyz
gmt mapproject profile2.xyz -Ge -o3,2 > track2_xyz


x1=$(cat $3 | head -1 | awk '{print $1}')
y1=$(cat $3 | head -1 | awk '{print $2}')
x2=$(cat $3 | tail -1 | awk '{print $1}')
y2=$(cat $3 | tail -1 | awk '{print $2}')
length=$(echo "(sqrt( ( ($x2*c($y2*0.0174533)*111321) - ($x1*c($y1*0.0174533)*111321) )^2 + ( ($y2*111321) - ($y1*111321) )^2 ))" | bc -l)
profile_extent=0/$length/-1300/200


gmt psxy track1_xyz -R$profile_extent -Bxafg+l"Profile length [m]" -Byaf+l"LOS displacement [mm]" -BWSne -JX10i/2i -W1p,red -K -V > $psout
gmt psxy track2_xyz -R$profile_extent -Bxafg+l"Profile length [m]" -Byaf+l"LOS displacement [mm]" -BWSne -JX10i/2i -W1p,blue -O -K -V >> $psout
gmt pslegend -R$profile_extent -J -DjBR+w1.2i+o0.2i -F+glightgray+pthicker -O << EOF >> $psout
S 0.1i C 0.07i red - 0.3i $1
S 0.1i C 0.07i blue - 0.3i $2
EOF
#gmt psxy -R -J -O  -W1p $in -V   >> $ps
#######################################################################################
gmt psconvert $psout -P -A -E300 -Tg

rm -f cross_profile profile1.xyz profile2.xyz track1_xyz track2_xyz $4.ps
