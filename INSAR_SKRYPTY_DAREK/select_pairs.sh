#!/bin/bash

file=$1
dt=$(echo $2 | awk '{print $0}')
db=$(echo $3 | awk '{printf $0}')

rm intf.in

gmt set PS_MEDIA A2
awk '{print 2014+$3/365.25, $5, $1}' < $1 > text

region1=$(gmt gmtinfo text -C | awk '{print $1-0.5}')
region2=$(gmt gmtinfo text -C | awk '{print $2+0.5}')
region3=$(gmt gmtinfo text -C | awk '{print $3-50}')
region4=$(gmt gmtinfo text -C | awk '{print $4+50}')

gmt pstext text -JX22i/6.8i -R$region1/$region2/$region3/$region4 -D0.2/0.2 -X1.5i -Y1i -K -N -F+f8,Helvetica+j5 > baseline.ps  

for line1 in $(awk '{print $1":"$2":"$3":"$4":"$5}' < $file); do
	for line2 in $(awk '{print $1":"$2":"$3":"$4":"$5}' < $file); do
		t1=$(echo $line1 | awk -F: '{print $3}')
		t2=$(echo $line2 | awk -F: '{print $3}')
        b1=$(echo $line1 | awk -F: '{print $5}')
        b2=$(echo $line2 | awk -F: '{print $5}')
        n1=$(echo $line1 | awk -F: '{print $1}')
        n2=$(echo $line2 | awk -F: '{print $1}')
        t21=$(($t2-$t1))
        if [[ $t1 -lt $t2 && $t21 -lt $dt ]]; then
        	db0=$(echo $b1 $b2 | awk '{printf "%d", sqrt(($1-$2)*($1-$2))}')
        	if [[ $db0 -lt $db ]]; then
        		echo $n1 $n2 | awk '{print $1":"$2}' >> intf.in
        		echo $t1 $b1 | awk '{print $1/365.25+2014, $2}' >> tmp
        		echo $t2 $b2 | awk '{print $1/365.25+2014, $2}' >> tmp
        		gmt psxy tmp -R -J -K -O >> baseline.ps
        		rm tmp
        	fi
        fi
    done
done

awk '{print $1,$2}' < text > text2
gmt psxy text2 -Sp0.2c -G0 -R -JX -Ba0.5:"year":/a50g00f25:"baseline (m)":WSen -O >> baseline.ps