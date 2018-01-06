#!/usr/bin/env bash

# Author: Ket-Meng Cheng
# Github: http://www.github.com/Aeternitaas
# Dependencies: graphicsmagick, feh, 

# Create an folder to hold the wallpaper phases
img_folder="$HOME/.cache/i3snelock"

# Grabs the current background through feh
feh_image=$(cat ~/.fehbg | grep feh | grep -o \'/.*\' | grep -o [^\'].*[^\'])

dimblur() {
    cp 
}

case "$1" in 
    # Case in which no args are presented.
    "" | -h | --help)
        echo "Usage: i3snelock [OPTION]"
        echo
        echo "  -l, --lock [LOCKSTYLE]             locks the screen with the lock setting chosen; leave"
        echo "                                     may be left blank for default dimblur setting"
        echo "  -h, --help                         displays help prompt"
        echo "  -s, --startup [IMAGEFILE]          initializes i3snelock with a given background image;"
        echo "                                     to be run if being run for the first time or if a"
        echo "                                     custom background image is desired"
        exit 1
        ;;

    -l | --lock) 
        case "$2" in
            "")
                # If setup has not been run, exit and prompt the user to do so.
                if [ ! -d $img_folder ]; then 
                    echo "Please run \`i3snelock -s [IMGFILE]\` to set up i3snelock."
                    exit 2
                fi

                # Default configuration; dim + blur
                dimblur
                ;;
                # TODO: add other configurations.
        esac
    ;;
    -s | --startup)
        if [ ! -d $img_folder ]; then
            # Create the folder at img_folder if it does not exist.
            echo "Created file located at $img_folder"
            mkdir -p "$img_folder"
        fi
        
        case "$2" in
            "")
                # If no file is specified, copy feh_image.
                cp "$feh_image" "$img_folder/modified_file.png"
                ;;
        esac
esac
