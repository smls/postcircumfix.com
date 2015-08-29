#!/bin/bash
set -e

say() {
    echo -e "\033[34m$1\033[0m"
}

percentage() {
    echo "$(echo "scale=2; ($2 * 100) / $1" | bc)%"
}

filesize() {
    stat --printf="%s" "$1"
}

checktargetfile() {
    if [[ ! -s $1 ]]; then
        echo " - Error: $1 resulted in an empty file."
        return 1
    fi
}

copy() {
    say "Creating copy "${@: -1}""
    cp "$@"
    checktargetfile "${@: -1}"
}

png_convert() {
    say "Generating "${@: -1}""
    convert "$@"
    checktargetfile "${@: -1}"
}

png_optimize() {
    say "Optimizing $1"
    oldsize=$(filesize "$1")
    
    if [[ -z $TINIFY_API_KEY ]]; then
        echo " - Skipping tinify.com optimizeion because TINIFY_API_KEY is not set"
    else
        response="$(curl -sS -D - -o /dev/null \
                         --user        api:$TINIFY_API_KEY \
                         --data-binary @"$1" \
                         https://api.tinify.com/shrink)"
        count="$(echo "$response" | grep -Po "Compression-Count: \K[^\x0d]+")"
        echo " - Monthly quota: $count/500"
        newurl="$(echo "$response" | grep -Po "Location: \K[^\x0d]+")"
        if [[ ! -z $newurl ]]; then
            curl -sS "$newurl" > "$1"
        fi
    fi
    
    if [[ -z $(type optipng) ]]; then
        echo " - Skipping optipng optimizeion because it is not installed"
    else
        optipng -q "$1"
    fi
    
    checktargetfile "$1"
    
    newsize=$(filesize "$1")
    echo " - Compressed to $(percentage $oldsize $newsize) of original."
}

svg_render() {
    say "Rendering $2"
    inkscape "$1" --export-png="$2" >&-
    checktargetfile "$2"
}

svg_optimize() {
    say "Optimizing $1"
    
    new="$(mktemp).svg"
    scour -i "$1" -o "$new" -q \
        --create-groups --enable-comment-stripping --enable-id-stripping \
        --enable-viewboxing --indent=none --remove-metadata --set-precision=4 \
        --shorten-ids
    
    checktargetfile "$new"
    
    echo " - Compressed to $(percentage $(filesize "$1") $(filesize "$new"))" \
         "of original."
    mv "$new" "$1"
}
