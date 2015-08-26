#!/bin/bash

#---------- functions ----------#

say() {
    echo -e "\033[34m$1\033[0m"
}

svg_render() {
    say "Rendering $1"
    inkscape "$1" --export-png="$2"
}

png_convert() {
    say "Generating "${@: -1}""
    convert "$@"
}

png_compress() {
    say "Compressing $1"
    oldsize=$(stat --printf="%s" "$1")
    
    if [[ -z $TINIFY_API_KEY ]]; then
        say " - Skipping tinify.com compression because TINIFY_API_KEY is not set"
    else
        response="$(curl -# -D - -o /dev/null \
                         --user        api:$TINIFY_API_KEY \
                         --data-binary @"$1" \
                         https://api.tinify.com/shrink)"
        newurl="$(echo "$response" | grep -Po "Location: \K[^\x0d]+")"
        echo $newurl;
        if [[ ! -z $newurl ]]; then
            curl -# "$newurl" > "$1"
        fi
    fi
    
    if [[ -z $(type optipng) ]]; then
        say " - Skipping optipng compression because it is not installed"
    else
        optipng -q "$1"
    fi
    
    newsize=$(stat --printf="%s" "$1")
    echo "Compressed to $(echo "scale=2; $newsize/$oldsize*100" | bc)% of original size."
}

#---------- main code ----------#

original="$(mktemp).png"
svg_render icon.svg "$original"

adjusted="$(mktemp).png"
png_convert "$original"  -level 7%,65%  "$adjusted"
rm "$original"

png_convert "$adjusted"  -gravity Center -crop 96x96+0+0 +repage \
            ../favicon.png
png_compress ../favicon.png

small="$(mktemp).png"
png_convert ../favicon.png  -filter Lanczos -resize 16x16  "$small"
png_compress "$small"
png_convert "$small" ../favicon.ico
rm "$small"

png_convert "$adjusted"  -filter Lanczos -resize 76x76 \
            ../apple-touch-icon.png
png_compress ../apple-touch-icon.png
rm "$adjusted"

