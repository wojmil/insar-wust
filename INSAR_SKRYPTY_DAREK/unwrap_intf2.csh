#!/bin/csh -f
# intflist contains a list of all date1_date2 directories
# > ls -d -1 [0-9]* > intflist
# > split.sh intflist

set lines = `wc -l intflist1 | awk '{print $1}'`
set count = 0

foreach line (`awk '{print $1}' intflist2`)
	cd $line
	echo $line
#	rm corr.grd unwrap_orig.grd unwrap.grd mask2_patch.grd
#	mv corr_orig.grd corr.grd
#	ln -s ../mask_def.grd .
	snaphu.csh 0.00001 0 5000/11000/6000/10500
	gmt grdcut corr.grd -R5000/11000/6000/10500 -Gcorr_cut.grd
	mv corr.grd corr_orig.grd
	mv corr_cut.grd corr.grd
	@ count = $count + 1
	echo 'Finished' $count/$lines 'interferograms'
	cd ..
end
