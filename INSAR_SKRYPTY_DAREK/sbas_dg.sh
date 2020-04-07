#!/bin/bash

work_dir=$(zenity --file-selection --directory --title="Choose your working directory")
data_dir=$(zenity --file-selection --directory --title="Select your folder with Sentinel-1 data")
dem_dir=$(zenity --file-selection --directory --title="Select your folder with DEM and Orbits")

cd $work_dir
mkdir raw raw_orig topo
cd raw_orig

swath=$(zenity --entry --title="SWATH" --text="Enter IW SWATH number (4/5/6)")																				# tutaj numer swatha 1 = 4 / 2 = 5 / 3 = 6, żeby wyciągało dobre tify i xmle

cp $DEBIAN_INSAR/GMTSAR/preproc/S1A_preproc/src_tops/s1a-aux-cal.xml .              # tutaj trzeba wprowadzić ścieżkę do pliku s1a-aux-cal

for data in $(ls $data_dir/);
do
	cp $data_dir/$data/manifest.safe ${data:17:8}_manifest.safe

	cd ../raw/
	ln -s $data_dir/$data/measurement/*$swath.tiff .
	cd ../raw_orig
	cp $data_dir/$data/annotation/*$swath.xml .
done

for xml in $(ls -1 *$swath.xml);
do
	awk 'NR>1 {print $0}' < ${xml:15:8}_manifest.safe > ${xml:15:8}_tmp_file
	cat $xml ${xml:15:8}_tmp_file s1a-aux-cal.xml > ../raw/$xml
	rm ${xml:15:8}_tmp_file
done

cd ../raw
ln -s $dem_dir/dem.grd .
ln -s $dem_dir/dem.grd $work_dir/topo/dem.grd
ln -s $dem_dir/*.EOF .

touch data.1 data.2
for tif in $(ls -1 *.tiff);
do
	echo ${tif:0:-5} >> data.1
done
for eof in $(ls -1 *.EOF);
do
	echo $eof >> data.2
done
paste -d":" data.1 data.2 > data.in
rm data.1 data.2
cat data.in | sort -n -k1.19,1.23 > data.in2
rm data.in
mv data.in2 data.in

preproc_batch_tops_esd.csh data.in dem.grd 1

case $swath in
4)
sed -i 's/F/F1/g' baseline_table.dat
;;
5)
sed -i 's/F/F2/g' baseline_table.dat
;;
6)
sed -i 's/F/F3/g' baseline_table.dat
;;
esac

mv baseline_table.dat ../

echo "Continue with moving master to the first line in data.in, then execute command in */raw/ folder:"
echo "preproc_batch_tops_esd.csh data.in dem.grd 2"