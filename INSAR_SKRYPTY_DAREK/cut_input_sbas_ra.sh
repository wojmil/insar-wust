#!/bin/bash

intf_dir=$(zenity --file-selection --directory --title="Select directory with interferograms to correct")

cd $intf_dir

cut_extent=13000/20000/4800/7000

for intf in $(ls -d -1 2*);
do
	cd $intf
#	gmt grdcut unwrap.grd -R$cut_extent -Gunwrap_cut.grd
#	mv unwrap.grd unwrap_orig.grd
#	mv unwrap_cut.grd unwrap.grd
	gmt grdcut corr.grd -R$cut_extent -Gcorr_cut.grd
	mv corr.grd corr_orig.grd
	mv corr_cut.grd corr.grd
	cd ..
done