#!/bin/bash

intf_dir=$(zenity --file-selection --directory --title="Select directory with interferograms")

cd $intf_dir

rm -f avg_coh.txt
touch avg_coh.txt
printf "interferogram \t Avg Coherence \t Coh STD \n" > avg_coh.txt

echo "Calculating average coherence..."
for intf in $(ls -d -1 2*);
do
	cd $intf
	meancorr=$(gmt grdinfo -L2 corr.grd | grep mean | awk '{print $3}')
	stdcorr=$(gmt grdinfo -L2 corr.grd | grep mean | awk '{print $5}')
	if (( $(echo "$meancorr < 0.15" | bc -l) ));
	then
		printf "$intf \t $meancorr \t $stdcorr \t *\n" >> ../avg_coh.txt
	else
		printf "$intf \t $meancorr \t $stdcorr \t\n" >> ../avg_coh.txt
	fi
	cd ..
done
echo "All OK"