#!/bin/python3

import os
import numpy as np
from osgeo import gdal
import math

los_asc = gdal.Open('los_asc_res.grd')
los_dsc = gdal.Open('los_dsc_res.grd')
off_asc = gdal.Open('off_asc_res.grd')
off_dsc = gdal.Open('off_dsc_res.grd')
inci_asc = gdal.Open('inci_asc_res.grd')
inci_dsc = gdal.Open('inci_dsc_res.grd')

d_asc = np.array(los_asc.GetRasterBand(1).ReadAsArray())
d_dsc = np.array(los_dsc.GetRasterBand(1).ReadAsArray())

o_asc = np.array(off_asc.GetRasterBand(1).ReadAsArray())
o_dsc = np.array(off_dsc.GetRasterBand(1).ReadAsArray())

i_asc = np.array(inci_asc.GetRasterBand(1).ReadAsArray())
i_dsc = np.array(inci_dsc.GetRasterBand(1).ReadAsArray())

#print(d_asc[1,1])
#print(d_dsc[1,1])
#print(i_asc[1,1])
#print(i_dsc[1,1])

#A = np.array([[-np.sin(i_asc[1,1]*0.01745329)*np.cos(0.96592583), np.cos(i_asc[1,1]*0.01745329)], [-np.sin(i_dsc[1,1]*0.01745329)*np.cos(0.96592583), np.cos(i_dsc[1,1]*0.01745329)]])
#v = np.array([[d_asc[1,1]], [d_dsc[1,1]]])
#
#Ainv = np.linalg.inv(A)
#
#print(A)
#print(v)
#
#x = Ainv @ v

dispE = []
dispU = []
dispN = []

for a, b, c, d, e, f in np.nditer([d_asc, d_dsc, o_asc, o_dsc, i_asc, i_dsc]):
	A = np.array([	[-np.sin(e*0.01745329)*0.96592583, np.sin(e*0.01745329)*(-0.25881904), np.cos(e*0.01745329)],
					[-np.sin(f*0.01745329)*(-0.96592583), np.sin(f*0.01745329)*(-0.25881904), np.cos(f*0.01745329)],
					[-0.25881904, 0.96592583, 0],
					[-0.25881904, -0.96592583, 0] ])
	v = np.array([[a], [b], [c], [d]])
#	Ainv = np.linalg.inv(A)
	x, s1, s2, s3 = np.linalg.lstsq(A, v)
	dispE.append(x[0])
	dispN.append(x[1])
	dispU.append(x[2])

E = np.vstack(dispE)
U = np.vstack(dispU)
N = np.vstack(dispN)

np.savetxt('dispEW.xyz', E)
np.savetxt('dispUD.xyz', U)
np.savetxt('dispNS.xyz', N)