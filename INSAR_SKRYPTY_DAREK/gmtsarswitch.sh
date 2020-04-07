#!/bin/bash


version=`cat ~/.bashrc | grep GMT | awk -F'/' '{print $2}'`
echo $version

if [[ $version == 'GMT5SAR' ]]; then
	echo "GMTSAR version 5.5 changed to 5.7"
	sed -i "s/GMT5SAR/GMTSAR/g" ~/.bashrc
	source ~/.bashrc
elif [[ $version == 'GMTSAR' ]]; then
	echo "GMTSAR version 5.7 changed to 5.5"
	sed -i "s/GMTSAR/GMT5SAR/g" ~/.bashrc
	source ~/.bashrc
else
	echo "Something's wrong... :("
fi