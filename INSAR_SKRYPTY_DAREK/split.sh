#!/bin/bash
#
# Split input file into 4 equal files (for multiple core processing)
#

split -n l/3 $1

mv xaa $1'1'
mv xab $1'2'
mv xac $1'3'
#mv xad $1'4'