#!/bin/bash
#
# Create .rsc file based on phase data
#
# gacos_rsc.sh unwrap_ll.grd
#
#
rm $1.rsc
touch $1.rsc
OUT=$1.rsc

WIDTH=`gmt grdinfo $1 | grep 'n_columns' | awk '{print $12}'`
FILE_LENGTH=`gmt grdinfo $1 | grep 'n_rows' | awk '{print $12}'`
XMAX=$WIDTH
YMAX=$FILE_LENGTH
X_FIRST=`gmt grdinfo $1 | grep 'x_min' | awk '{print $3}'`
Y_FIRST=`gmt grdinfo $1 | grep 'y_max' | awk '{print $5}'`
X_STEP=`gmt grdinfo $1 | grep 'x_inc' | awk '{print $7}'`
Y_STEP=`gmt grdinfo $1 | grep 'y_inc' | awk '{print $7}'`

echo WIDTH $'\t' $WIDTH >> $OUT
echo FILE_LENGTH $'\t' $FILE_LENGTH >> $OUT
echo XMIN $'\t' 1 >> $OUT
echo XMAX $'\t' $XMAX >> $OUT
echo YMIN $'\t' 1 >> $OUT
echo YMAX $'\t' $YMAX >> $OUT
echo X_FIRST $'\t' $X_FIRST >> $OUT
echo Y_FIRST $'\t' $Y_FIRST >> $OUT
echo X_STEP $'\t' $X_STEP >> $OUT
echo Y_STEP $'\t' '-'$Y_STEP >> $OUT
echo X_UNIT $'\t' degrees >> $OUT
echo Y_UNIT $'\t' degrees >> $OUT
echo Z_OFFSET $'\t' 0 >> $OUT
echo Z_SCALE $'\t' 1 >> $OUT
echo PROJECTION $'\t' LATLON >> $OUT
echo DATUM $'\t' WGS84 >> $OUT