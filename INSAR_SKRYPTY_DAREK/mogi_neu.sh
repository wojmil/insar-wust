#!/bin/bash

region=$1
x_src=$2
y_src=$3
dV=$4
d=$5
dem=$6
mst=$7
slv=$8

mkdir tmp
mkdir output

echo "Resample DEM"
gmt grdsample $dem -R$region -Gtmp/dem_res.grd

gmt grd2xyz tmp/dem_res.grd > tmp/grid.llt

echo "Calculate Looks"
SAT_look $mst < tmp/grid.llt > tmp/topo_asc.lltn
SAT_look $slv < tmp/grid.llt > tmp/topo_dsc.lltn

awk '{print $1 " " $2}' tmp/grid.llt > tmp/lonlat.xyz

awk '{print $1 " " $2 " " $4}' tmp/topo_asc.lltn > tmp/topo_asc.e
awk '{print $1 " " $2 " " $5}' tmp/topo_asc.lltn > tmp/topo_asc.n
awk '{print $1 " " $2 " " $6}' tmp/topo_asc.lltn > tmp/topo_asc.u

awk '{print $1 " " $2 " " $4}' tmp/topo_dsc.lltn > tmp/topo_dsc.e
awk '{print $1 " " $2 " " $5}' tmp/topo_dsc.lltn > tmp/topo_dsc.n
awk '{print $1 " " $2 " " $6}' tmp/topo_dsc.lltn > tmp/topo_dsc.u

gmt xyz2grd tmp/topo_asc.e -Rtmp/dem_res.grd `gmt grdinfo tmp/dem_res.grd -I` -Gtmp/topoeasc.grd
gmt xyz2grd tmp/topo_asc.n -Rtmp/dem_res.grd `gmt grdinfo tmp/dem_res.grd -I` -Gtmp/toponasc.grd
gmt xyz2grd tmp/topo_asc.u -Rtmp/dem_res.grd `gmt grdinfo tmp/dem_res.grd -I` -Gtmp/topouasc.grd

gmt xyz2grd tmp/topo_dsc.e -Rtmp/dem_res.grd `gmt grdinfo tmp/dem_res.grd -I` -Gtmp/topoedsc.grd
gmt xyz2grd tmp/topo_dsc.n -Rtmp/dem_res.grd `gmt grdinfo tmp/dem_res.grd -I` -Gtmp/topondsc.grd
gmt xyz2grd tmp/topo_dsc.u -Rtmp/dem_res.grd `gmt grdinfo tmp/dem_res.grd -I` -Gtmp/topoudsc.grd

echo "Calculate incidence angle grids"
gmt grdmath tmp/topoeasc.grd SQR tmp/toponasc.grd SQR ADD SQRT tmp/topouasc.grd DIV ATAN = tmp/iasc.grd
gmt grdmath tmp/iasc.grd 360 MUL 2 PI MUL DIV = tmp/inci_asc.grd

gmt grdmath tmp/topoedsc.grd SQR tmp/topondsc.grd SQR ADD SQRT tmp/topoudsc.grd DIV ATAN = tmp/idsc.grd
gmt grdmath tmp/idsc.grd 360 MUL 2 PI MUL DIV = tmp/inci_dsc.grd


awk -v y="$y_src" '{print ($1 - y)*69500}' tmp/grid.llt > tmp/lon.dat
awk -v x="$x_src" '{print ($2 - x)*111320}' tmp/grid.llt > tmp/lat.dat


echo "Measure distances from source point"
paste tmp/lonlat.xyz tmp/lon.dat > tmp/x.diff
paste tmp/lonlat.xyz tmp/lat.dat > tmp/y.diff
gmt xyz2grd tmp/x.diff -Rlos_ll.grd `gmt grdinfo los_ll.grd -I` -Gtmp/xdiff.grd
gmt xyz2grd tmp/y.diff -Rlos_ll.grd `gmt grdinfo los_ll.grd -I` -Gtmp/ydiff.grd

gmt grdmath tmp/xdiff.grd SQR tmp/ydiff.grd SQR ADD $d SQR ADD SQRT = tmp/R.grd


rx=tmp/xdiff.grd
ry=tmp/ydiff.grd

echo "Calculate XYZ displacements from Mogi Source Model"
gmt grdmath -3 $dV MUL 4 PI MUL tmp/R.grd 3 POW MUL DIV tmp/xdiff.grd MUL 1000 MUL = output/mogi_ew.grd
gmt grdmath -3 $dV MUL 4 PI MUL tmp/R.grd 3 POW MUL DIV tmp/ydiff.grd MUL 1000 MUL = output/mogi_ns.grd
gmt grdmath -3 $dV MUL 4 PI MUL tmp/R.grd 3 POW MUL DIV $d MUL 1000 MUL = output/mogi_u.grd


echo "Calculate LOS displacements from Mogi Source Model"
#gmt grdmath iasc.grd SIND -1 MUL -15 SIND MUL mogi_ew.grd MUL iasc.grd SIND -15 SIND MUL mogi_ns.grd MUL ADD iasc.grd COSD mogi_u.grd MUL ADD = model_asc.grd
gmt grdmath tmp/iasc.grd SIN -15 SIND MUL output/mogi_ns.grd MUL tmp/iasc.grd SIN -15 COSD MUL output/mogi_ew.grd MUL SUB tmp/iasc.grd COS output/mogi_u.grd MUL ADD = output/model_asc.grd
gmt grdmath tmp/idsc.grd SIN -165 SIND MUL output/mogi_ns.grd MUL tmp/idsc.grd SIN -165 COSD MUL output/mogi_ew.grd MUL SUB tmp/idsc.grd COS output/mogi_u.grd MUL ADD = output/model_dsc.grd

gmt grdmath -4 PI MUL 55.4658 DIV output/model_asc.grd MUL 2 PI MUL FMOD = output/wrapped_asc.grd
gmt grdmath -4 PI MUL 55.4658 DIV output/model_dsc.grd MUL 2 PI MUL FMOD = output/wrapped_dsc.grd


