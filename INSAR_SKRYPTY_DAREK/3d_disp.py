#!/bin/python3

import os
import numpy as np
from osgeo import gdal
import math

los_asc = gdal.Open('los_asc_res.grd')
los_dsc = gdal.Open('los_dsc_res.grd')
inci_asc = gdal.Open('inci_asc_res.grd')
inci_dsc = gdal.Open('inci_dsc_res.grd')

d_asc = np.array(los_asc.GetRasterBand(1).ReadAsArray())
d_dsc = np.array(los_dsc.GetRasterBand(1).ReadAsArray())
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

for a, b, c, d in np.nditer([d_asc, d_dsc, i_asc, i_dsc]):
	A = np.array([[-np.sin(c*0.01745329)*0.96592583, np.cos(c*0.01745329)], [-np.sin(d*0.01745329)*(-0.96592583), np.cos(d*0.01745329)]])
	v = np.array([[a], [b]])
	Ainv = np.linalg.inv(A)
	x = Ainv @ v
	dispE.append(x[0])
	dispU.append(x[1])

E = np.vstack(dispE)
U = np.vstack(dispU)

np.savetxt('dispEW.xyz', E)
np.savetxt('dispUD.xyz', U)