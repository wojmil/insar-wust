#!/bin/bash
# Provide dem.grd!

workdir=$(zenity --file-selection --directory --title="Choose your working directory")
ascdir=$(zenity --file-selection --directory --title="Choose directory with (GACOS-corrected) ascending data")
dscdir=$(zenity --file-selection --directory --title="Choose directory with (GACOS-corrected) descending data")
prmdir=$(zenity --file-selection --directory --title="Choose directory with PRM files")

DEM=dem.grd

if [[ -f "$DEM" ]]; then
	cd $ascdir
	ascdate=$(ls -1 S1* | head -1 | awk -F_ '{print $2}')
	echo $ascdate
	cd $dscdir
	dscdate=$(ls -1 S1* | head -1 | awk -F_ '{print $2}')
	echo $dscdate
	cd $workdir
	cp $ascdir/unwrap.grd .
	mv unwrap.grd asc.grd
	cp $dscdir/unwrap.grd .
	mv unwrap.grd dsc.grd
	ln -s ../dem.grd .
	cp $prmdir/*$ascdate* .
	cp $prmdir/*$dscdate* .
	ascprm=$(ls *$ascdate*.PRM)
	dscprm=$(ls *$dscdate*.PRM)
	los2neu.sh $ascprm $dscprm asc.grd dsc.grd dem.grd
else
	echo "$DEM not available. Please provide $DEM file."
fi