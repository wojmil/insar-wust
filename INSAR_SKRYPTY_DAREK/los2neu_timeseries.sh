#!/bin/bash
# los2neu_timeseries.sh


ascdir=$(zenity --file-selection --directory --title="Choose the directory with ASCENDING data")
dscdir=$(zenity --file-selection --directory --title="Choose the directory with DESCENDING data")
asc_prm=$1
dsc_prm=$2


for date in $(ls $ascdir/);
do
	if [[ $date = disp_*.grd ]]
	then
		echo ${date:5:7}
	fi
done > asc.txt

for date in $(ls $dscdir/);
do
	if [[ $date = disp_*.grd ]]
	then
		echo ${date:5:7}
	fi
done > dsc.txt

paste -d'_' asc.txt dsc.txt > dates.txt
rm -f asc.txt dsc.txt

for entry in $(cat dates.txt);
do
	mkdir $entry
	cd $entry
	cp $ascdir/disp_${entry:0:7}.grd .
	mv disp_${entry:0:7}.grd asc.grd
	cp $dscdir/disp_${entry:8:7}.grd .
	mv disp_${entry:8:7}.grd dsc.grd
	ln -s ../dem.grd .
	ln -s ../S1_$asc_prm*.PRM .
	ln -s ../S1_$asc_prm*.LED .
	ln -s ../S1_$dsc_prm*.PRM .
	ln -s ../S1_$dsc_prm*.LED .
	los2neu.sh S1_$asc_prm*.PRM S1_$dsc_prm*.PRM asc.grd dsc.grd dem.grd
	cd ..
done
rm -f dates.txt