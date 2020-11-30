#!/bin/sh
#export LD_LIBRARY_PATH="."
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
export OSG_FILE_PATH="../../data"
./JGOMAS_Render $@
