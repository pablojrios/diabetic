#!/bin/bash -e 

# To run, this assumes that you are in the directory with the images
# unpacked into train/ and test/.  To run, it works best to use GNU
# parallel as
#
#   ls train/*.jpeg test/*.jpeg | parallel ./prep_image_rot.sh
#   
#   cd NN500/
#   ls train/*.jpeg | parallel ../diabetic-retinopathy-code/prep_image_regions.sh
#   cd NN1000/
#   ls test/*.jpeg | parallel ../diabetic-retinopathy-code/prep_image_regions.sh
#
#   ls -lR processed/ | grep jpeg | wc
#   
#
# Otherwise, it also works to do a bash for loop, but this is slower.
#
#   for f in `ls train/*.jpeg test/*.jpeg`; do ./prep_image_rot.sh $f; done
#

size=256x256
out_dir=processed
num_regions=12
out=$out_dir/run-reg1/$1
# creo los dir para las variaciones de imagenes
for i in $(seq 1 $num_regions); do mkdir -p $out_dir/run-reg$i/train; done
for i in $(seq 1 $num_regions); do mkdir -p $out_dir/run-reg$i/test; done
[ -e $out ] && echo "Skip $1" || echo "$1 -> $num_regions regions"
[ -e $out ] || \
convert $1 -fuzz 10% -trim +repage -resize 1024x1024 -gravity center -background black -extent 1024x1024 -equalize \
        \( +clone -crop 256x256-128-384 -write $out_dir/run-reg1/$1 \) -delete 1 \
        \( +clone -crop 256x256+128-384 -write $out_dir/run-reg2/$1 \) -delete 1 \
        \( +clone -crop 256x256-384-128 -write $out_dir/run-reg3/$1 \) -delete 1 \
        \( +clone -crop 256x256-128-128 -write $out_dir/run-reg4/$1 \) -delete 1 \
        \( +clone -crop 256x256+128-128 -write $out_dir/run-reg5/$1 \) -delete 1 \
        \( +clone -crop 256x256+384-128 -write $out_dir/run-reg6/$1 \) -delete 1 \
        \( +clone -crop 256x256-384+128 -write $out_dir/run-reg7/$1 \) -delete 1 \
        \( +clone -crop 256x256-128+128 -write $out_dir/run-reg8/$1 \) -delete 1 \
        \( +clone -crop 256x256+128+128 -write $out_dir/run-reg9/$1 \) -delete 1 \
        \( +clone -crop 256x256+384+128 -write $out_dir/run-reg10/$1 \) -delete 1 \
        \( +clone -crop 256x256-128+384 -write $out_dir/run-reg11/$1 \) -delete 1 \
        -crop 256x256+128+384 $out_dir/run-reg12/$1
