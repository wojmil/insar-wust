intf_dir=$(zenity --file-selection --directory --title="Select directory with interferograms to correct")

cd $intf_dir

cut_extent=18.161/19.3/49.730/50.4

for intf in $(ls -d -1 2*);
do
	cd $intf
	ln -s ../../topo/trans.dat .
	proj_ra2ll.csh trans.dat unwrap.grd unwrap_ll.grd
#	proj_ra2ll.csh trans.dat corr.grd corr_ll.grd
	gmt grdcut unwrap_ll.grd -R$cut_extent -Gunwrap_ll_cut.grd
	mv unwrap.grd unwrap_orig.grd
	rm -f unwrap.grd
	mv unwrap_ll_cut.grd unwrap.grd
	gmt grdcut corr_ll.grd -R$cut_extent -Gcorr_ll_cut.grd
	rm -f corr.grd
	mv corr.grd corr_orig.grd
	mv corr_ll_cut.grd corr.grd
	cd ..
done

for plik in $(ls *);
do
	gmt grdcut $plik -R -G${plik:0:8}.nc


	1.grd