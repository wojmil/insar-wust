#!/bin/bash

intf_dir=$(zenity --file-selection --directory --title="Select directory with interferograms")

cd $intf_dir

for intf in $(ls -d -1 2*);
do
	cd $intf
	proj_ra2ll.csh trans.dat corr.grd corr_ll.grd
	gmt grdsample corr_ll.grd -Gcorr_ll_sam.grd -Runwrap_ll.grd
	gmt grdcut corr_ll_sam.grd -R15.547/16.421/50.913/51.741 -Gcorr_ll_cut.grd
	gmt grdcut unwrap_ll.grd -R15.547/16.421/50.913/51.741 -Gunwrap_ll_cut.grd
	mv corr.grd corr_org.grd
	mv unwrap.grd unwrap_org.grd
	mv corr_ll_cut.grd corr.grd
	mv unwrap_ll_cut.grd unwrap.grd
	cd ..
done
