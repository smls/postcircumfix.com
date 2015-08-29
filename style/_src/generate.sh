#!/bin/bash
set -e
source functions.sh

favico=../../favicon.ico
favpng=../../favicon.png
applepng=../../apple-touch-icon.png

if [ icon.svg -nt "$favico" ]; then
    
    original="$(mktemp).png"
    svg_render icon.svg "$original"

    adjusted="$(mktemp).png"
    png_convert "$original"  -level 7%,65%  "$adjusted"
    rm "$original"

    png_convert "$adjusted"  -gravity Center -crop 96x96+0+0 +repage  "$favpng"
    png_optimize "$favpng"

    small="$(mktemp).png"
    png_convert "$favpng"  -filter Lanczos -resize 16x16  "$small"
    png_optimize "$small"
    png_convert "$small" "$favico"
    rm "$small"

    png_convert "$adjusted"  -filter Lanczos -resize 76x76  "$applepng"
    png_optimize "$applepng"
    rm "$adjusted"
fi
