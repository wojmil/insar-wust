#!/bin/bash

if [ $# != 5 ]; then
	echo ""
	echo " los2neu.sh"
	echo ""
	echo " Convert LOS displacements from ascending and descending passes to E-W and U-D values"
	echo ""
	echo "      Usage:   los2neu.sh asc_master.PRM dsc_master.PRM asc_los dsc_los DEM"
	echo ""
	echo "      Example: los2neu.sh S1_20190628_015000_F1.PRM S1_20190704_135200_F1.PRM los_asc.grd los_dsc.grd dem.grd"
	echo ""
	exit 1
fi


echo "Resample DEM to los grid"
gmt grdsample $5 -R$3 -Gdem_res.grd


echo "Convert DEM from .grd to .xyz"
gmt grd2xyz dem_res.grd > topo.llt


echo "Calculate Looks using SAT_look"
SAT_look $1 < topo.llt > topo_asc.lltn
SAT_look $2 < topo.llt > topo_dsc.lltn


echo "Extract E, N, U looks and save as xyz files"
awk '{print $1 " " $2 " " $4}' topo_asc.lltn > topo_asc.e
awk '{print $1 " " $2 " " $5}' topo_asc.lltn > topo_asc.n
awk '{print $1 " " $2 " " $6}' topo_asc.lltn > topo_asc.u

awk '{print $1 " " $2 " " $4}' topo_dsc.lltn > topo_dsc.e
awk '{print $1 " " $2 " " $5}' topo_dsc.lltn > topo_dsc.n
awk '{print $1 " " $2 " " $6}' topo_dsc.lltn > topo_dsc.u


echo "Convert xyz of looks to grd"
gmt xyz2grd topo_asc.e -Rdem_res.grd `gmt grdinfo $3 -I` -Gtopoeasc.grd
gmt xyz2grd topo_asc.n -Rdem_res.grd `gmt grdinfo $3 -I` -Gtoponasc.grd
gmt xyz2grd topo_asc.u -Rdem_res.grd `gmt grdinfo $3 -I` -Gtopouasc.grd

gmt xyz2grd topo_dsc.e -Rdem_res.grd `gmt grdinfo $3 -I` -Gtopoedsc.grd
gmt xyz2grd topo_dsc.n -Rdem_res.grd `gmt grdinfo $3 -I` -Gtopondsc.grd
gmt xyz2grd topo_dsc.u -Rdem_res.grd `gmt grdinfo $3 -I` -Gtopoudsc.grd


echo "Calculate Incidence angle grids"
gmt grdmath topoeasc.grd SQR toponasc.grd SQR ADD SQRT topouasc.grd DIV ATAN = iasc.grd
gmt grdmath iasc.grd 360 MUL 2 PI MUL DIV = inci_asc.grd

gmt grdmath topoedsc.grd SQR topondsc.grd SQR ADD SQRT topoudsc.grd DIV ATAN = idsc.grd
gmt grdmath idsc.grd 360 MUL 2 PI MUL DIV = inci_dsc.grd

rm -f dem_res.grd topo* iasc.grd idsc.grd

echo "Resample LOS and incidence grids to common grid"
gmt grdsample $3 -R$4 -Glos_asc_res.grd
gmt grdsample $4 -Rlos_asc_res.grd -Glos_dsc_res.grd
gmt grdsample inci_asc.grd -Rlos_asc_res.grd -Ginci_asc_res.grd
gmt grdsample inci_dsc.grd -Rlos_asc_res.grd -Ginci_dsc_res.grd

echo "Create 'Lon Lat' ASCII file"
gmt grd2xyz los_asc_res.grd > los_asc.xyz
awk '{print $1 " " $2}' los_asc.xyz > lonlat.xyz

echo "Calculate East-West and Vertical displacement"
3d_disp.py

paste lonlat.xyz dispEW.xyz > EW.xyz
paste lonlat.xyz dispUD.xyz > UD.xyz

echo "Create E-W and U-D grids"
gmt xyz2grd EW.xyz -Rlos_asc_res.grd `gmt grdinfo $3 -I` -GdispEW.grd
gmt xyz2grd UD.xyz -Rlos_asc_res.grd `gmt grdinfo $3 -I` -GdispUD.grd

gmt grd2cpt dispEW.grd -Cpolar -T= -Z > dispEW.cpt
gmt grd2cpt dispUD.grd -Cpolar -T= -Z > dispUD.cpt

grd2kml.csh dispEW dispEW.cpt
grd2kml.csh dispUD dispUD.cpt

rm los_asc_res.grd los_dsc_res.grd inci_asc_res.grd inci_dsc_res.grd los_asc.xyz lonlat.xyz EW.xyz UD.xyz dispEW.xyz dispUD.xyz