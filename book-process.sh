#!/bin/bash

# Example cd Documents/books/Edward_Teller; book-process.sh edward_teller;
#no periods allowed!
PREFIX=$1

mkdir unpaper
mkdir -p gocr/linedata
mkdir png

#unpaper does about 15seconds/page (400page book is 1.6 hours)
#deskew defaults to 1.0 standard deviation.  a couple pages are a little more skewed
#or unpaper is confused and trying to deskew it sideways?
time unpaper --layout single --deskew-scan-deviation 2.5 ${PREFIX}.%d.pnm unpaper/${PREFIX}.%d.pnm > unpaper_errors.txt

#Use the unpaper'd copies for post-processing
cd unpaper

#gocr 5secs/page (400page book is 33min)
#-v16 exports debug info about line recognition (to stderr)
# might be useful someday for integration of image/ocr
time for x in *.pnm;do gocr $x -v 16 -e ../gocr/linedata/$x.txt -o ../gocr/$x.txt;done;

#400 pngs of 282k is 112M book
#assumes PREFIX has NO DOTS (periods)
ls *.pnm |awk -F. '{print "pnmtopng " $0 " >../png/" $1 "." $2 ".png"}'|bash

#out of ./unpaper to home
cd ..

#once we know it works, we can get rid of the intermediate file
#rm unpaper/*
#then, after review of no errors, we can delete the original pnms (manually)

###EXTRA HELP
#
#####renaming as a number offset
####ls *.pnm |awk -F. '{print "mv " $0 " " $1"." $2+396 ".pnm"}'|bash
