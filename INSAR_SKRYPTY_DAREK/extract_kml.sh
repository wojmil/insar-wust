#!/bin/bash

mkdir KML

extent=2/29/63/69

gmt pscoast -R$extent -JM9i -W0.1p -Df -K > KML/out.ps

for zip in $(ls -1 *.zip);
do
	unzip -j "$zip" "${zip:0:67}.SAFE/preview/map-overlay.kml" -d "./KML"
	unzip -j "$zip" "${zip:0:67}.SAFE/preview/quick-look.png" -d "./KML"

	mv KML/map-overlay.kml KML/${zip:17:8}'.kml'
	mv KML/quick-look.png KML/${zip:17:8}'.png'

	sed -i 's/quick-look/'${zip:17:8}'/g' KML/${zip:17:8}'.kml'

	cat KML/${zip:17:8}'.kml' | grep coordinates | cut -c 24- | rev | cut -c 15- | rev | awk '{print $1}' > KML/${zip:17:8}'.xy'
	cat KML/${zip:17:8}'.kml' | grep coordinates | cut -c 24- | rev | cut -c 15- | rev | awk '{print $2}' >> KML/${zip:17:8}'.xy'
	cat KML/${zip:17:8}'.kml' | grep coordinates | cut -c 24- | rev | cut -c 15- | rev | awk '{print $3}' >> KML/${zip:17:8}'.xy'
	cat KML/${zip:17:8}'.kml' | grep coordinates | cut -c 24- | rev | cut -c 15- | rev | awk '{print $4}' >> KML/${zip:17:8}'.xy'
	cat KML/${zip:17:8}'.kml' | grep coordinates | cut -c 24- | rev | cut -c 15- | rev | awk '{print $1}' >> KML/${zip:17:8}'.xy'

	gmt psxy -R -J -W0.5p,red KML/${zip:17:8}'.xy' -O -K >> KML/out.ps 

done

gmt psbasemap -R -J -Bag -O >> KML/out.ps
gmt psconvert KML/out.ps -A -Tg -P
