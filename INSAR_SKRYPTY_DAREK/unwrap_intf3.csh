#!/bin/csh -f
# intflist contains a list of all date1_date2 directories
# > ls -d -1 [0-9]* > intflist
# > split.sh intflist

set lines = `wc -l intflist1 | awk '{print $1}'`
set count = 0

foreach line (`awk '{print $1}' intflist3`)
	cd $line
	echo $line
#	rm corr.grd unwrap_orig.grd unwrap.grd mask2_patch.grd
#	mv corr_orig.grd corr.grd
##	ln -s ../mask_def.grd .
	snaphu.csh 0.00001 0 5000/11000/6000/10500
	gmt grdcut corr.grd -R5000/11000/6000/10500 -Gcorr_cut.grd
	mv corr.grd corr_orig.grd
	mv corr_cut.grd corr.grd
	@ count = $count + 1
	echo 'Finished' $count/$lines 'interferograms'
	cd ..
end

# Zakresy
#
# BogdankaA 	5000/11000/6000/10500
# BogdankaD		6000/15000/6000/9500
# LGOM 73A	6000/17000/4000/8000
# LGOM 22D 	6000/16000/1000/6000
# Zonguldak 13000/20000/4800/7000
# Zonguldak 2014-2019 13000/20000/3000/5200