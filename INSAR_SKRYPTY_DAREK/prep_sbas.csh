#!/bin/csh -f
#       $Id$

# Prepare the input tables for sbas processing

# Xiaohua(Eric) Xu, Jan 25 2016
#

  if ($#argv != 2) then
    echo ""
    echo "Usage: prep_sbas.csh intf.in baseline_table.dat"
    echo ""
    echo "  outputs: "
    echo "    intf.tab scene.tab"
    echo ""
    echo "  Command to run sbas will be echoed"
    echo ""
    exit 1
  endif

  set file = $1
  set table = $2

  rm intf.tab scene.tab
  touch intf.tab scene.tab
  
  set ni = "0"
  set ns = "0"
  
  foreach line (`awk '{print $0}' $1`) 
    set ref = `echo $line | awk -F: '{print $1}'`
    set rep = `echo $line | awk -F: '{print $2}'`
    set ref_id  = `grep $ref $table | awk '{printf("%d",int($2))}' `
    set rep_id  = `grep $rep $table | awk '{printf("%d",int($2))}' `
    set b1 = `grep $ref $table | awk '{print $5}'`
    set b2 = `grep $rep $table | awk '{print $5}'`
    set bp = `echo $b1 $b2 | awk '{print ($2-$1)}'`
    echo "../intf_all/$ref_id"_"$rep_id/unwrap.grd ../intf_all/$ref_id"_"$rep_id/corr.grd $ref_id $rep_id $bp" >> intf.tab
    set ntmp = `echo $ni`
    set ni = `echo $ntmp | awk '{print ($1+1)}'`
  end

  foreach line  (`awk '{print $1":"$2":"$3":"$4":"$5}' < $table`)
    set sc = `echo $line | awk -F: '{print $1}'`
    set sc_id = `echo $line | awk -F: '{printf "%d", int($2)}'`
    set dy = `echo $line | awk -F: '{print $3}'`
    echo "$sc_id $dy" >> scene.tab
    set ntmp = `echo $ns`
    set ns = `echo $ntmp | awk '{print ($1+1)}'`
  end

  set xdim = `gmt grdinfo -C ../intf_all/$ref_id"_"$rep_id/unwrap.grd | awk '{print $10}'`
  set ydim = `gmt grdinfo -C ../intf_all/$ref_id"_"$rep_id/unwrap.grd | awk '{print $11}'`
   
  echo ""
  echo "sbas intf.tab scene.tab $ni $ns $xdim $ydim"
  echo ""

