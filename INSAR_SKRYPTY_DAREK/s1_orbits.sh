#!/bin/bash
#
# Darek Głąbicki, 2019
#
# Copies Sentinel-1 orbit files from /home directory to current path, based on a list of Sentinel-1 acquisition dates
#
# Usage:    s1_orbits.sh safelist
#
# safelist --->   ls -d *.SAFE > safelist
if [ $# -eq 0 ]; then
	echo ""
	echo " s1_orbits.sh"
	echo ""
	echo " Copies Sentinel-1 orbit files from /home directory to current path, based on a list of Sentinel-1 acquisition dates"
	echo ""
	echo "      Usage:   s1_orbits.sh safelist"
	echo ""
	echo "      safelist - list of .SAFE directories, created with e.g. 'ls -1 -d *.SAFE > safelist' "
	echo ""
	exit 1
fi

sentinel1_orbit_downloader.sh
while read safe; do
	date=${safe:17:8}
	sat=${safe:0:3}
	dat=$(date -d "$date -1 days" +'%Y%m%d')
	echo 'Copying' $sat $dat 'orbit file...'
	cp /media/insarek1/INSAR_1/sentinel1_orbits/$sat*V$dat*.EOF .
	echo 'Done'
done < $1