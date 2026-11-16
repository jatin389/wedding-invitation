#!/bin/bash
# usage: import_clip.sh <name> [start-image]  — copies the newest Gemini video from Downloads
# to <name>.mp4, reports size/duration and how closely frame 0 matches the start image.
set -e
S="${SHEETDIR:-/tmp}"; n="$1"; ref="${2:-start/start_$n.png}"
f=$(ls -t "$HOME"/Downloads/gemini_generated_video_*.mp4 | head -1)
if grep -qx "$f" .imported 2>/dev/null; then echo "ALREADY IMPORTED: $f"; exit 1; fi
cp "$f" "$n.mp4"; echo "$f" >> .imported
echo "$n <- $(basename "$f") $(ffprobe -v error -select_streams v -show_entries stream=width,height,duration -of csv=p=0 "$n.mp4")"
ffmpeg -v error -y -i "$n.mp4" -frames:v 1 "$S/f0.png"
ffmpeg -hide_banner -i "$S/f0.png" -i "$ref" -filter_complex "[1][0]scale2ref[r][v];[v][r]psnr" -f null - 2>&1 | grep -o "average:[0-9.]*"
ffmpeg -v error -y -i "$n.mp4" -vf "select='eq(n,0)+eq(n,60)+eq(n,120)+eq(n,180)+eq(n,239)',scale=-2:420,tile=5x1" -frames:v 1 -fps_mode passthrough -q:v 5 "$S/sheet_$n.jpg"
