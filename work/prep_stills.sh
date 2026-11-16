#!/bin/bash
# Imports the Gemini stills, strips the corner watermarks, and builds the posters and
# the exact start frames for the dive clips (16:9 landscape + 9:16 portrait).
set -e
D="$HOME/Downloads/Gemini_Generated_Image_ofsfsmofsfsmofsf"
WM="delogo=x=2225:y=1390:w=140:h=140,delogo=x=2345:y=1515:w=145:h=140"
imp(){ ffmpeg -v error -y -i "$1" -vf "$WM" "still_$2.png"; }
imp "$D.png" 2_haldi; imp "$D (1).png" 3_mehendi; imp "$D (2).png" 4_djnight
imp "$D (3).png" 5_baraat; imp "$D (4).png" 6_wedding
mkdir -p start ../assets/img
for n in 1_welcome 2_haldi 3_mehendi 4_djnight 5_baraat 6_wedding; do
  # landscape start frame: centre-crop 3:2 -> 16:9, 1920x1080
  ffmpeg -v error -y -i still_$n.png -vf "crop=2528:1422:0:137,scale=1920:1080:flags=lanczos" start/start_$n.png
  # portrait start frame: island strip scaled to 1080 wide, backdrop extended above/below
  ffmpeg -v error -y -i still_$n.png -vf "crop=1280:1696:640:0,scale=1080:1431:flags=lanczos,pad=1080:1920:0:77,fillborders=top=79:bottom=414:mode=smear" start/start_$n-m.png
  ffmpeg -v error -y -i start/start_$n.png -q:v 3 ../assets/img/still_$n.jpg
  ffmpeg -v error -y -i start/start_$n-m.png -q:v 3 ../assets/img/still_$n-m.jpg
done
