#!/bin/bash

# GACOS correction for single interferogram


if [ -f "*.tar.gz" ]; then
	tar -xvf *.tar.gz
	rm -d *.tar.gz ReadMe.pdf
fi

master_ztd=$(ls -1 *.ztd | head -1)
slave_ztd=$(ls -1 *.ztd | tail -1)

gacos_refpoint_single.py

ref_x=$(cat coords.txt | awk '{print $1}')
ref_y=$(cat coords.txt | awk '{print $2}')

gmt grdsample unwrap_ll.grd -Gphase.grd -I0.0008333333/0.0008333333
gacos_rsc.sh phase.grd
make_correction.gmt phase.grd $master_ztd $slave_ztd $ref_x $ref_y
gmt grdmath corrected_detrend.grd -1 MUL = displacement.grd
gmt grdmath displacement.grd 0.012565971 MUL -18.0291278 MUL = corrected_phase.grd