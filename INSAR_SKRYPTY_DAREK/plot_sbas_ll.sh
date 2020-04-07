#!/bin/bash

gmt grd2cpt disp_2019274_ll.grd -T= -Z -Cjet > los.cpt

  
for line in $(ls -1 disp*ll.grd);
do
  stem=`echo $line | awk -F. '{print $1}'`
  grd2kml.csh $stem los.cpt
done