#!/bin/bash

if [ $# -eq 0 ]; then
	echo ""
	echo " profile_timeseries.sh"
	echo ""
	echo " Create a time series profile based on a set of .grd data, across given coordinates"
	echo ""
	echo "      Usage:   profile_timeseries.sh \$data_dir "
	echo ""
	echo "      Example: profile_timeseries.sh data "
	echo ""
	exit 1
fi

make_profile_timeseries.py --a $1
make_timeseries.sh $1 coords.txt profil
num=$RANDOM
mv profil.png profil_$num.png