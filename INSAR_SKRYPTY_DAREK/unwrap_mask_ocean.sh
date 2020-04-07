#!/bin/bash

for intf in $(ls -1 -d 2*);
do
	cd $intf
	echo $intf 
	ln -s ../mask_def.grd
	snaphu.csh 0.0000001 0 13000/20000/4800/7000
	gmt grdcut corr.grd -R13000/20000/4800/7000 -Gcorr_cut.grd
	mv corr.grd corr_orig.grd
	mv corr_cut.grd corr.grd
	cd ..
done