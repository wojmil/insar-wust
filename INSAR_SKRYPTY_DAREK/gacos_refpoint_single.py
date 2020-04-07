#!/home/insarek1/anaconda3/bin/python3

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import glob
import gdal
import subprocess


def onclick(event):
    global ix, iy
    ix, iy = event.xdata, event.ydata
    global coords
    coords.append((ix, iy))
    if len(coords) == 1:
        fig.canvas.mpl_disconnect(cid)
        plt.close()
    return

grid = gdal.Open('unwrap_ll.grd')
x_min = float(subprocess.getoutput("gmt grdinfo unwrap_ll.grd | grep x_min | awk '{print $3}'"))
x_max = float(subprocess.getoutput("gmt grdinfo unwrap_ll.grd | grep x_min | awk '{print $5}'"))
y_min = float(subprocess.getoutput("gmt grdinfo unwrap_ll.grd | grep y_min | awk '{print $3}'"))
y_max = float(subprocess.getoutput("gmt grdinfo unwrap_ll.grd | grep y_min | awk '{print $5}'"))
x_step = float(subprocess.getoutput("gmt grdinfo unwrap_ll.grd | grep x_min | awk '{print $7}'"))
y_step = float(subprocess.getoutput("gmt grdinfo unwrap_ll.grd | grep y_min | awk '{print $7}'"))

X = np.arange(x_min, x_max, x_step)
Y = np.arange(y_min, y_max, y_step)
X, Y = np.meshgrid(X, Y)

phase = np.array(grid.GetRasterBand(1).ReadAsArray())

fig, ax = plt.subplots()
im = ax.imshow(phase, interpolation='bilinear', extent=[x_min, x_max, y_min, y_max])
plt.title("Choose reference point (click)")
coords = []

cid = fig.canvas.mpl_connect('button_press_event', onclick)

plt.show()

outfile = open('coords.txt', 'w')
print(coords[0][0], coords [0][1], file=outfile)


