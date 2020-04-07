#!/bin/bash

for file in $(ls -d -1 2*);
do
	cd $file
	mv corr.grd corr_patch.grd
	mv corr_o.grd corr.grd
	cd ..
done