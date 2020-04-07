#!/home/insarek1/anaconda3/bin/python3

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import argparse
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

parser = argparse.ArgumentParser(description="Select reference point in stack of interferograms")
parser.add_argument("--D", default=1, type=str, required=True, help="Directory with input grid files")
args = parser.parse_args()
inputdir = args.D

list_of_files = glob.glob(inputdir + '/*/phase.grd')
last_file = max(list_of_files)

grid = gdal.Open(last_file)
x_min = float(subprocess.getoutput("gmt grdinfo " + last_file + " | grep x_min | awk '{print $3}'"))
x_max = float(subprocess.getoutput("gmt grdinfo " + last_file + " | grep x_min | awk '{print $5}'"))
y_min = float(subprocess.getoutput("gmt grdinfo " + last_file + " | grep y_min | awk '{print $3}'"))
y_max = float(subprocess.getoutput("gmt grdinfo " + last_file + " | grep y_min | awk '{print $5}'"))
x_step = float(subprocess.getoutput("gmt grdinfo " + last_file + " | grep x_min | awk '{print $7}'"))
y_step = float(subprocess.getoutput("gmt grdinfo " + last_file + " | grep y_min | awk '{print $7}'"))

X = np.arange(x_min, x_max, x_step)
Y = np.arange(y_min, y_max, y_step)
X, Y = np.meshgrid(X, Y)

intflist = []
for i in range(0, len(list_of_files)):
    intf = gdal.Open(list_of_files[i])
    phase = np.array(intf.GetRasterBand(1).ReadAsArray())
    intflist.append(phase)

phase_mean = np.nanmean(np.array(intflist), axis=0)
phase_std = np.nanstd(np.array(intflist), axis=0)

phase_mean = np.abs(phase_mean)

mean_10p = np.nanpercentile(phase_mean, 10)
std_10p = np.nanpercentile(phase_std, 10)

phase_min = phase_mean < mean_10p
std_min = phase_std < std_10p

phase = phase_mean * phase_min
phase *= std_min

fig, ax = plt.subplots()
im = ax.imshow(phase, interpolation='bilinear', extent=[x_min, x_max, y_min, y_max])
plt.title("Choose reference point (click)")
coords = []

cid = fig.canvas.mpl_connect('button_press_event', onclick)

plt.show()

outfile = open('coords.txt', 'w')
print(coords[0][0], coords [0][1], file=outfile)


