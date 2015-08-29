#!/bin/bash
set -e
source ../../style/_src/functions.sh

svg_fix_fonts() {
    say "Fixing fonts in $1"
    ./svg_fix_fonts.pl "$1"
}

for src in *.svg; do
    name="${src%.svg}"
    png="../$name.png"
    svg="../$name.svg"
    
    if [ "$src" -nt "$svg" ]; then
        copy "$src" "$svg"
        svg_optimize "$svg"
        svg_fix_fonts "$svg"
    fi
    
    if [ "$src" -nt "$png" ]; then
        svg_render "$src" "$png"
        png_optimize "$png"
    fi
done
