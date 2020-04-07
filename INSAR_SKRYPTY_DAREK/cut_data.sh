#!/bin/bash

for file in $(ls -d -1 2*);
do
	cd $file
	gmt grdcut corr.grd -R$1 -Gcorr_patch.grd
	mv corr.grd corr_o.grd
	mv corr_patch.grd corr.grd
	cd ..
done