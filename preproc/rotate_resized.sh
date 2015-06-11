convert 19920_left.jpeg -fuzz 10% -trim +repage -resize 256x256 -gravity center -background black -extent 256x256 -equalize -write 19920_left_normal.jpeg \( +clone -rotate 5 \) -compose Src -composite 19920_left_rot5.jpeg

# si no quiero escribir 19920_left_normal.jpeg entonces remover -write <image filename>>
convert 19920_left.jpeg -fuzz 10% -trim +repage -resize 256x256 -gravity center -background black -extent 256x256 -equalize \( +clone -rotate 5 \) -compose Src -composite 19920_left_rot5.jpeg
