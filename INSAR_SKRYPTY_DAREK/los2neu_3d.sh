#!/bin/bash

if [ $# != 7 ]; then
	echo ""
	echo " los2neu_3d.sh"
	echo ""
	echo " Convert LOS displacements from 2 path LOS displacements and azimuth offsets to E-W, N-S and U-D components"
	echo ""
	echo "      Usage:   los2neu_3d.sh asc.PRM dsc.PRM asc_los dsc_los asc_offset dsc_offset DEM"
	echo ""
	exit 1
fi


echo "Resample DEM to los grid"
gmt grdsample $7 -R$3 -Gdem_res.grd

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
gmt grdsample $3 -Rdsc.grd -Glos_asc1_res.grd
gmt grdsample $4 -Rlos_asc1_res.grd -Glos_dsc1_res.grd
gmt grdsample $5 -Rlos_asc1_res.grd -Goff_asc1_res.grd
gmt grdsample $6 -Rlos_asc1_res.grd -Goff_dsc1_res.grd
gmt grdsample inci_asc.grd -Rlos_asc1_res.grd -Ginci_asc1_res.grd
gmt grdsample inci_dsc.grd -Rlos_asc1_res.grd -Ginci_dsc1_res.grd

gmt grdmath los_asc1_res.grd 0 AND = los_asc_res.grd
gmt grdmath los_dsc1_res.grd 0 AND = los_dsc_res.grd
gmt grdmath off_asc1_res.grd 0 AND = off_asc_res.grd
gmt grdmath off_dsc1_res.grd 0 AND = off_dsc_res.grd
gmt grdmath inci_asc1_res.grd 0 AND = inci_asc_res.grd
gmt grdmath inci_dsc1_res.grd 0 AND = inci_dsc_res.grd

echo "Create 'Lon Lat' ASCII file"
gmt grd2xyz los_asc_res.grd > los_asc.xyz
awk '{print $1 " " $2}' los_asc.xyz > lonlat.xyz

echo "Calculate East-West, North-South and Vertical displacement"
los2neu.py

paste lonlat.xyz dispEW.xyz > EW.xyz
paste lonlat.xyz dispUD.xyz > UD.xyz
paste lonlat.xyz dispNS.xyz > NS.xyz

echo "Create E-W, N-S and U-D grids"
gmt xyz2grd EW.xyz -Rlos_asc_res.grd `gmt grdinfo $4 -I` -GdispEW.grd
gmt xyz2grd UD.xyz -Rlos_asc_res.grd `gmt grdinfo $4 -I` -GdispUD.grd
gmt xyz2grd NS.xyz -Rlos_asc_res.grd `gmt grdinfo $4 -I` -GdispNS.grd

gmt grd2cpt dispEW.grd -Cpolar -T= -Z > dispEW.cpt
gmt grd2cpt dispUD.grd -Cpolar -T= -Z > dispUD.cpt
gmt grd2cpt dispNS.grd -Cpolar -T= -Z > dispNS.cpt

grd2kml.csh dispEW dispEW.cpt
grd2kml.csh dispUD dispUD.cpt
grd2kml.csh dispNS dispNS.cpt

#rm los_1_res.grd los_2_res.grd los_3_res.grd inci_1_res.grd inci_2_res.grd inci_3_res.grd los_1.xyz lonlat.xyz EW.xyz UD.xyz NS.xyz dispEW.xyz dispUD.xyz dispNS.xyz,