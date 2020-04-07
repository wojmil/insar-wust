#!/bin/bash

# mogi_point.sh region_grid source_x source_y volume_difference depth 

region=$1
x_src=$2
y_src=$3
dV=$4
d=$5


# For asc/dsc modeling

gmt grd2xyz $region > grid.llt

awk '{print $1 " " $2}' grid.llt > lonlat.xyz

echo `gmt grdinfo $region | grep x_min | awk '{print $3}'`' '`gmt grdinfo $region | grep y_min | awk '{print $3}'` > x.line
echo `gmt grdinfo $region | grep x_min | awk '{print $3}'`' '`gmt grdinfo $region | grep y_min | awk '{print $5}'` >> x.line
echo `gmt grdinfo $region | grep x_min | awk '{print $3}'`' '`gmt grdinfo $region | grep y_min | awk '{print $3}'` > y.line
echo `gmt grdinfo $region | grep x_min | awk '{print $5}'`' '`gmt grdinfo $region | grep y_min | awk '{print $3}'` >> y.line

gmt mapproject -R$region -JM6i lonlat.xyz -Lx.line > dist_x.xyz
gmt mapproject -R$region -JM6i lonlat.xyz -Ly.line > dist_y.xyz

awk '{print $1 " " $2 " " $3}' dist_x.xyz > x.dat
awk '{print $1 " " $2 " " $3}' dist_y.xyz > y.dat

gmt xyz2grd -R$region `gmt grdinfo $region -I` x.dat -Gr_x.grd
gmt xyz2grd -R$region `gmt grdinfo $region -I` y.dat -Gr_y.grd


gmt grdmath -R$region `gmt grdinfo $region -I` $x_src $y_src SDIST 1000 MUL = r.grd

r=r.grd
rx=r_x.grd
ry=r_y.grd

gmt grdmath -3 $dV MUL $d MUL 4 PI MUL $d SQR $r SQR ADD 1.5 POW MUL DIV 1000 MUL = mogi_u.grd
gmt grdmath -3 $dV MUL $rx MUL 4 PI MUL $d SQR $r SQR ADD 1.5 POW MUL DIV = mogi_ew.grd
gmt grdmath -3 $dV MUL $ry MUL 4 PI MUL $d SQR $r SQR ADD 1.5 POW MUL DIV = mogi_ns.grd

gmt grdmath $1 mogi_u.grd SUB = res_u.grd

#rm -f r.grd 