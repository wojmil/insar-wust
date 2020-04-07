#!/bin/bash

gacos_dir=$(zenity --file-selection --directory --title="Select directory with GACOS data (.ztd format)")
intf_dir=$(zenity --file-selection --directory --title="Select directory with interferograms to correct")

cd $intf_dir
cd ..
mkdir intf_gacos
cd $intf_dir

# convert GACOS ZTD files from meters into radians

for intf in $(ls -d -1 2*);
do
	cd $intf
	mstr=`ls -1 *.PRM | head -1 | awk '{print $1}'`
	slav=`ls -1 *.PRM | tail -1 | awk '{print $1}'`
	cd ../../intf_gacos
	mkdir $intf
	cd $intf
	cp $intf_dir/$intf/corr.grd .
	cp $intf_dir/$intf/unwrap.grd .
	ln -s $gacos_dir/${mstr:3:8}'.ztd' .
	ln -s $gacos_dir/${mstr:3:8}'.ztd.rsc' .
	ln -s $gacos_dir/${slav:3:8}'.ztd' .
	ln -s $gacos_dir/${slav:3:8}'.ztd.rsc' .
	ln -s ../../topo/trans.dat .
	proj_ra2ll.csh trans.dat unwrap.grd unwrap_ll.grd
	gmt grdsample unwrap_ll.grd -Gunwrap.phs -I0.0008333333/0.0008333333
	mv unwrap_ll.grd unwrap_ll_noncorrected.grd
#   Use when phase is already georeferenced
#	gmt grdsample unwrap.grd -Gunwrap.phs -I0.0008333333/0.0008333333
#	mv unwrap.grd unwrap_noncorrected.grd
	gacos_rsc.sh unwrap.phs
	make_correction.gmt unwrap.phs ${mstr:3:8}.ztd ${slav:3:8}.ztd
	gmt grdmath corrected_detrend.grd 12.566371 MUL 0.18029128 MUL = unwrap.grd

	gmt grdsample corr.grd -Gcorr_sam.grd -Runwrap.grd
	mv corr.grd corr_org.grd
	mv corr_sam.grd corr.grd

	cd $intf_dir
done