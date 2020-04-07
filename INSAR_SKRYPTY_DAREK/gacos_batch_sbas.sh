#!/bin/bash
# Przetwarzanie zbioru interferogramów z uwzględnieniem poprawki GACOS (dla obliczeń SBAS)



intfdir=$(zenity --file-selection --directory --title="Choose the directory with interferograms (intf_all)")
gacosdir=$(zenity --file-selection --directory --title="Choose the directory with GACOS data (ztd)")

mkdir gacos_all
cd gacos_all

echo "Copying data....."
for intf in $(ls $intfdir/);
do
	mkdir $intf
	cd $intf
	cp $intfdir/$intf/unwrap_ll.grd .
	cp $intfdir/$intf/corr_ll.grd .
	cp $intfdir/$intf/*.PRM .
	master=$(ls -1 *.PRM | head -1 | awk -F_ '{print $2}')
	slave=$(ls -1 *.PRM | tail -1 | awk -F_ '{print $2}')
	cp $gacosdir/$master.ztd .
	cp $gacosdir/$master.ztd.rsc .
	cp $gacosdir/$slave.ztd .
	cp $gacosdir/$slave.ztd.rsc .
	cd ..
done
echo "Data copied!"

echo "Preparing data....."
lastfile=$(ls -1 -d 2* | tail -1)
cp $lastfile/unwrap_ll.grd .
for intf in $(ls $intfdir/);
do
	cd $intf
	gmt grdcut unwrap_ll.grd -R../unwrap_ll.grd -N -Gunwrap_cut.grd
	gmt grdcut corr_ll.grd -R../unwrap_ll.grd -N -Gcorr_cut.grd
	gmt grdsample unwrap_cut.grd -R../unwrap_ll.grd -Gtmp.grd
	gmt grdsample corr_cut.grd -R../unwrap_ll.grd -I0.0008333333/0.0008333333 -Gcorr.grd
	gmt grdsample tmp.grd -Gphase.grd -I0.0008333333/0.0008333333
	gacos_rsc.sh phase.grd
	rm -f unwrap_cut.grd tmp.grd corr_cut.grd
	cd ..
done
rm -f unwrap_ll.grd
echo "Data prepared!"

echo "Choosing reference point for GACOS correction....."
cd ..
gacos_refpnt.py --D gacos_all
echo "Point chosen!"
refX=$(awk '{print $1}' coords.txt)
refY=$(awk '{print $2}' coords.txt)
rm -f coords.txt
cd gacos_all
echo "Reference point X: $refX"
echo "Reference point Y: $refY"

echo ""
echo "Making correction....."
echo ""

for intf in $(ls $intfdir/);
do
	cd $intf
	master=$(ls -1 *.ztd | head -1)
	slave=$(ls -1 *.ztd | tail -1)
	make_correction.gmt phase.grd $master $slave $refX $refY
	gmt grdmath corrected_detrend.grd -1 MUL = displacement.grd
	gmt grdmath displacement.grd 0.012565971 MUL -18.0291278 MUL = unwrap.grd
	cd ..
done

echo ""
echo "Interferograms corrected!"
echo ""
