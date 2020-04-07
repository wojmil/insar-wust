#!/home/insarek1/anaconda3/bin/python3

import numpy as np
import matplotlib.cm as cm
import matplotlib.pyplot as plt
from osgeo import gdal
import glob
import subprocess
import argparse


parser = argparse.ArgumentParser(description="Make profile from selected coordinates.")
parser.add_argument("--a", default=1, type=str, required=True, help="Input grid file")
args = parser.parse_args()

inputgrid = args.a

grid = gdal.Open(inputgrid)
x_min = float(subprocess.getoutput("gmt grdinfo " + inputgrid + " | grep x_min | awk '{print $3}'"))
x_max = float(subprocess.getoutput("gmt grdinfo " + inputgrid + " | grep x_min | awk '{print $5}'"))
y_min = float(subprocess.getoutput("gmt grdinfo " + inputgrid + " | grep y_min | awk '{print $3}'"))
y_max = float(subprocess.getoutput("gmt grdinfo " + inputgrid + " | grep y_min | awk '{print $5}'"))
x_step = float(subprocess.getoutput("gmt grdinfo " + inputgrid + " | grep x_min | awk '{print $7}'"))
y_step = float(subprocess.getoutput("gmt grdinfo " + inputgrid + " | grep y_min | awk '{print $7}'"))
z_1 = float(subprocess.getoutput("gmt grdinfo " + inputgrid + " | grep z_min | awk '{print $3}'"))
z_2 = float(subprocess.getoutput("gmt grdinfo " + inputgrid + " | grep z_min | awk '{print $5}'"))
z_min = z_1 - 50
z_max = z_2 + 50

X = np.arange(x_min, x_max, x_step)
Y = np.arange(y_min, y_max, y_step)
X, Y = np.meshgrid(X, Y)
Z = np.array(grid.GetRasterBand(1).ReadAsArray())

# Function for getting x,y data from clicks
def onclick(event):
    global ix, iy
    ix, iy = event.xdata, event.ydata
    global coords
    coords.append((ix, iy))
    if len(coords) == 2:
        fig.canvas.mpl_disconnect(cid)
        plt.close()
    return

# Showing plot
fig, ax = plt.subplots()
im = ax.imshow(Z, interpolation='bilinear', cmap=cm.RdYlGn, extent=[x_min, x_max, y_min, y_max],
               vmax=z_max, vmin=z_min)
plt.title("Choose beginning and end of cross-section")
coords = []

cid = fig.canvas.mpl_connect('button_press_event', onclick)

plt.show()

outfile = open('coords.txt','w')
print(coords[0][0], coords[0][1], file=outfile)
print(coords[1][0], coords[1][1], file=outfile)

