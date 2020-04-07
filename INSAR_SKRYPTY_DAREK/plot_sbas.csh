#!/bin/csh -f
#       $Id$

# Prepare the input tables for sbas processing

# Xiaohua(Eric) Xu, Jan 25 2016
#

  if ($#argv != 0) then
    echo ""
    echo "Usage: plot_sbas.csh"
    echo ""
    echo "  outputs: "
    echo "    disp_#_ll.grd disp_#_ll.png disp_#_ll.kml"
    echo ""
    exit 1
  endif

  ln -s ../topo/trans.dat .
  rm *ll*
  ls disp* > tmp.dat

  proj_ra2ll.csh trans.dat vel.grd vel_ll.grd

  gmt grd2cpt vel_ll.grd -T= -Z -Cjet > vel_ll.cpt
  grd2kml.csh vel_ll vel_ll.cpt
  
  foreach line (`awk '{print $0}' tmp.dat`)
    set stem = `echo $line | awk -F. '{print $1}'` 
    proj_ra2ll.csh trans.dat $line $stem"_"ll.grd
    grd2kml.csh $stem"_"ll vel_ll.cpt
  end

  proj_ra2ll.csh trans.dat dem.grd dem_ll.grd
  gmt grd2cpt dem_ll.grd -T= -Z -Cpolar > dem_ll.cpt
  grd2kml.csh dem_ll dem_ll.cpt
  
  proj_ra2ll.csh trans.dat rms.grd rms_ll.grd
  gmt grd2cpt rms_ll.grd -T= -Z -Cpolar > rms_ll.cpt
  grd2kml.csh rms_ll rms_ll.cpt

  rm tmp.dat raln.grd ralt.grd *.bb *.eps
