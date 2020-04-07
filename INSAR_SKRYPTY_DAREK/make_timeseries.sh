#!/bin/bash


gmt set MAP_TICK_LENGTH_PRIMARY	5p/10p 
gmt set MAP_TICK_LENGTH_SECONDARY 10p/1.5p


profile_interval=1e
profile_xy_data=$2
input_grd_dir=$1
psout=$3.ps


x1=$(cat $2 | head -1 | awk '{print $1}')
y1=$(cat $2 | head -1 | awk '{print $2}')
x2=$(cat $2 | tail -1 | awk '{print $1}')
y2=$(cat $2 | tail -1 | awk '{print $2}')
length=$(echo "(sqrt( ( ($x2*c($y2*0.0174533)*111321) - ($x1*c($y1*0.0174533)*111321) )^2 + ( ($y2*111321) - ($y1*111321) )^2 ))" | bc -l)
profile_extent=0/$length/-1300/100
echo "Profile length: $length"

gmt sample1d $profile_xy_data -I$profile_interval > cross_profile
gmt psbasemap -R$profile_extent -JX10i/6i -Bxafg+l"Profile length [m]" -Byaf+l"LOS displacement [mm]" -BWSne -K > $psout

cd $input_grd_dir
for file in $(ls -1 *.grd); do
	gmt grdtrack ../cross_profile -G$file > profile.xyz
	gmt mapproject profile.xyz -Ge -o3,2 > track_xyz
	if [[ $file = 'disp_2016000_ll.grd' ]]
	then
		gmt psxy track_xyz -R$profile_extent -JX10i/6i -Bxafg+l"Profile length [m]" -Byaf+l"LOS displacement [mm]" -BWSne -W1p,blue -K -O -V >> ../$psout
	elif [[ $file = 'disp_2017000_ll.grd' ]]
	then
		gmt psxy track_xyz -R$profile_extent -JX10i/6i -Bxafg+l"Profile length [m]" -Byaf+l"LOS displacement [mm]" -BWSne -W1p,red -K -O -V >> ../$psout
	elif [[ $file = 'disp_2018001_ll.grd' ]]
	then
		gmt psxy track_xyz -R$profile_extent -JX10i/6i -Bxafg+l"Profile length [m]" -Byaf+l"LOS displacement [mm]" -BWSne -W1p,orange -K -O -V >> ../$psout
	elif [[ $file = 'disp_2019002_ll.grd' ]]
	then
		gmt psxy track_xyz -R$profile_extent -JX10i/6i -Bxafg+l"Profile length [m]" -Byaf+l"LOS displacement [mm]" -BWSne -W1p,green -K -O -V >> ../$psout
	else
		gmt psxy track_xyz -R$profile_extent -JX10i/6i -Bxafg+l"Profile length [m]" -Byaf+l"LOS displacement [mm]" -BWSne -W0.1p,gray -K -O -V >> ../$psout
	fi
done

gmt psxy track_xyz -R$profile_extent -JX10i/6i -Bxafg+l"Profile length [m]" -Byaf+l"LOS displacement [mm]" -BWSne -Wthinnest,gray -O -V >> ../$psout
cd ..

gmt psconvert $psout -P -D. -A -E300 -Tg






#gmt sample1d $profile_xy_data -I$profile_interval > cross_profile
#gmt grdtrack cross_profile -G$input_grd > profile.xyz
#gmt mapproject profile.xyz -Ge -o3,2 > track_xyz


#x1=$(cat $2 | head -1 | awk '{print $1}')
#y1=$(cat $2 | head -1 | awk '{print $2}')
#x2=$(cat $2 | tail -1 | awk '{print $1}')
#y2=$(cat $2 | tail -1 | awk '{print $2}')
#length=$(echo "(sqrt( ( ($x2*c($y2*0.0174533)*111321) - ($x1*c($y1*0.0174533)*111321) )^2 + ( ($y2*111321) - ($y1*111321) )^2 ))" | bc -l)
#profile_extent=0/$length/-1300/200

#gmt psxy track_xyz -R$profile_extent -Bxafg+l"Profile length [m]" -Byaf+l"LOS displacement [mm]" -BWSne -JX10i/2i -W1p  -V > $psout
#gmt psxy -R -J -O  -W1p $in -V   >> $ps
#######################################################################################
#gmt psconvert $psout -P -D. -A -E300 -Tg
