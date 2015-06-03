#!/bin/bash -e 

# To run, this assumes that you are in the directory with the images
# unpacked into train/ and test/.  To run, it works best to use GNU
# parallel as
#
#   ls train/*.jpeg test/*.jpeg | parallel ./prep_image_rot.sh
#   
#   ls test/*.jpeg | head -20000| tail -3000 | parallel ../diabetic-retinopathy-code/prep_image_rot.sh
#
#   ls -lR processed/ | grep jpeg | wc
#   
#
# Otherwise, it also works to do a bash for loop, but this is slower.
#
#   for f in `ls train/*.jpeg test/*.jpeg`; do ./prep_image_rot.sh $f; done
#

size=256x256

out_dir=processed/run-normal
mkdir -p $out_dir/train
mkdir -p $out_dir/test
out=$out_dir/$1
out_dir_rot=processed/run-normal-rot
mkdir -p $out_dir_rot/train
mkdir -p $out_dir_rot/test
out_rot=$out_dir_rot/$1
[ -e $out ] && echo "Skip $1" || echo "$1 -> $out -> $out_rot"
[ -e $out ] || \
    convert -fuzz 10% -trim +repage -resize $size -gravity center -background black -extent $size -equalize $1 -write $out \( -rotate 180 \) $out_rot

out_dir=processed/run-stretch
mkdir -p $out_dir/train
mkdir -p $out_dir/test
out=$out_dir/$1
out_dir_rot=processed/run-stretch-rot
mkdir -p $out_dir_rot/train
mkdir -p $out_dir_rot/test
out_rot=$out_dir_rot/$1
[ -e $out ] && echo "Skip $1" || echo "$1 -> $out -> $out_rot"
[ -e $out ] || \
    convert -fuzz 10% -trim +repage -transparent black -contrast-stretch 2x2% -resize $size -gravity center -background black -extent $size -equalize $1 -write $out \( -rotate 180 \) $out_rot

out_dir=processed/run-hue-1
mkdir -p $out_dir/train
mkdir -p $out_dir/test
out=$out_dir/$1
out_dir_rot=processed/run-hue-1-rot
mkdir -p $out_dir_rot/train
mkdir -p $out_dir_rot/test
out_rot=$out_dir_rot/$1
[ -e $out ] && echo "Skip $1" || echo "$1 -> $out -> $out_rot"
[ -e $out ] || \
    convert -fuzz 10% -trim +repage -modulate 100,100,80 -resize $size -gravity center -background black -extent $size -equalize $1 -write $out \( -rotate 180 \) $out_rot

out_dir=processed/run-hue-2
mkdir -p $out_dir/train
mkdir -p $out_dir/test
out=$out_dir/$1
out_dir_rot=processed/run-hue-2-rot
mkdir -p $out_dir_rot/train
mkdir -p $out_dir_rot/test
out_rot=$out_dir_rot/$1
[ -e $out ] && echo "Skip $1" || echo "$1 -> $out -> $out_rot"
[ -e $out ] || \
    convert -fuzz 10% -trim +repage -modulate 100,100,120 -resize $size -gravity center -background black -extent $size -equalize $1 -write $out \( -rotate 180 \) $out_rot

out_dir=processed/run-sat-1
mkdir -p $out_dir/train
mkdir -p $out_dir/test
out=$out_dir/$1
out_dir_rot=processed/run-sat-1-rot
mkdir -p $out_dir_rot/train
mkdir -p $out_dir_rot/test
out_rot=$out_dir_rot/$1
[ -e $out ] && echo "Skip $1" || echo "$1 -> $out -> $out_rot"
[ -e $out ] || \
    convert -fuzz 10% -trim +repage -modulate 100,80,100 -resize $size -gravity center -background black -extent $size -equalize $1 -write $out \( -rotate 180 \) $out_rot

out_dir=processed/run-sat-2
mkdir -p $out_dir/train
mkdir -p $out_dir/test
out=$out_dir/$1
out_dir_rot=processed/run-sat-2-rot
mkdir -p $out_dir_rot/train
mkdir -p $out_dir_rot/test
out_rot=$out_dir_rot/$1
[ -e $out ] && echo "Skip $1" || echo "$1 -> $out -> $out_rot"
[ -e $out ] || \
    convert -fuzz 10% -trim +repage -modulate 100,120,100 -resize $size -gravity center -background black -extent $size -equalize $1 -write $out \( -rotate 180 \) $out_rot

out_dir=processed/run-contrast-1
mkdir -p $out_dir/train
mkdir -p $out_dir/test
out=$out_dir/$1
out_dir_rot=processed/run-contrast-1-rot
mkdir -p $out_dir_rot/train
mkdir -p $out_dir_rot/test
out_rot=$out_dir_rot/$1
[ -e $out ] && echo "Skip $1" || echo "$1 -> $out -> $out_rot"
[ -e $out ] || \
    convert -fuzz 10% -trim +repage -sigmoidal-contrast 5,75% -resize $size -gravity center -background black -extent $size -equalize $1 -write $out \( -rotate 180 \) $out_rot

out_dir=processed/run-contrast-2
mkdir -p $out_dir/train
mkdir -p $out_dir/test
out=$out_dir/$1
out_dir_rot=processed/run-contrast-2-rot
mkdir -p $out_dir_rot/train
mkdir -p $out_dir_rot/test
out_rot=$out_dir_rot/$1
[ -e $out ] && echo "Skip $1" || echo "$1 -> $out -> $out_rot"
[ -e $out ] || \
    convert -fuzz 10% -trim +repage -sigmoidal-contrast 10,50% -resize $size -gravity center -background black -extent $size -equalize $1 -write $out \( -rotate 180 \) $out_rot

