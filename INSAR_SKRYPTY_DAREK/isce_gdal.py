#!/home/insarek1/anaconda3/bin/python3


from osgeo import gdal
import matplotlib.pyplot as plt
import numpy as np

gdal.UseExceptions()

def loadData(infile, band=1):
	ds = gdal.Open(infile, gdal.GA_ReadOnly)
	data = ds.GetRasterBand(band).ReadAsArray()
	trans = ds.GetGeoTransform()
	xsize = ds.RasterXSize
	ysize = ds.RasterYSize
	extent = [trans[0], trans[0] + xsize * trans[1], trans[3] + ysize * trans[5], trans[3]]

	ds = None
	return data, extent

azi, aziext = loadData('merged/filt_topophase.flat.geo')

plt.figure('Unwrapped phase')
plt.subplot(1,1,1)
plt.imshow(azi, clim=[-50, 190], extent=aziext, cmap='jet')
plt.show()
azi=None





# ---- Transformacja wyniku z formatu VRT do GTIFF
# gdal_translate -of GTiff -b 2 -a_nodata 0 merged/topophase.cor.geo.vrt merged/coherence.geo.tif