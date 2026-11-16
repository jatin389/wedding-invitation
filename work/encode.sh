#!/bin/bash
# Encodes every finished clip in work/ for scroll-scrubbing (audio stripped, Gemini's
# corner sparkle removed) and refreshes the portrait posters from each clip's first frame.
cd "$(dirname "$0")"; mkdir -p ../assets/vid ../assets/img
for f in dive_*-m.mp4 conn_*-m.mp4; do [ -f "$f" ] || continue
  ffmpeg -v error -y -i "$f" -an -vf "delogo=x=570:y=1130:w=60:h=60,scale=720:-2,unsharp=5:5:0.6:5:5:0.0" \
    -c:v libx264 -preset slow -crf 23 -pix_fmt yuv420p -g 4 -keyint_min 4 -sc_threshold 0 -movflags +faststart "../assets/vid/$f"
done
for f in dive_*.mp4 conn_*.mp4; do [ -f "$f" ] || continue; case "$f" in *-m.mp4) continue;; esac
  ffmpeg -v error -y -i "$f" -an -vf "delogo=x=1129:y=570:w=60:h=60,unsharp=5:5:0.8:5:5:0.0" \
    -c:v libx264 -preset slow -crf 20 -pix_fmt yuv420p -g 8 -keyint_min 8 -sc_threshold 0 -movflags +faststart "../assets/vid/$f"
done
for f in ../assets/vid/dive_*-m.mp4; do [ -f "$f" ] || continue
  n=$(basename "$f" -m.mp4); n=${n#dive_}
  ffmpeg -v error -y -i "$f" -frames:v 1 -q:v 3 "../assets/img/still_$n-m.jpg"
done
ls -la ../assets/vid | awk '{print $5, $9}'
