#!/usr/bin/env bash

# Author: Ket-Meng Cheng
# Github: http://www.github.com/Aeternitaas
# Dependencies: graphicsmagick, feh, xdpyinfo

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
        shift

        if [ ! -d $img_folder ]; then
            # Create the folder at img_folder if it does not exist.
            echo "Created directory located at $img_folder"
            mkdir -p "$img_folder"
        fi

        mod_file="$img_folder/modified_file.png"
        dimblur="$img_folder/dimblur.png"
        blur="$img_folder/blur.png"
        
        case "$1" in
            "")
                # If no file is specified, copy feh_image.
                cp "$feh_image" "$mod_file"
                ;;
            *)
                # Else, simply copy the specified file.
                cp "$1" "$mod_file"
                ;;
        esac


        # TODO: implement blur specification.

        # Sets up configuration types. 
        dim=$(xdpyinfo | grep dimensions | grep -o [0-9]*x[0-9]*\ pixels | grep -o [0-9][0-9]*x[0-9]*)

        # Converts the image to the screen's dimensions.
        gm convert -size "$dim" "$mod_file" -resize "$dim" \
            -gravity center "$mod_file"

        # Applies Gaussian blur at a radius of 10 with a SD of 2.
        gm convert -blur 10x2 "$mod_file" "$blur"

        # Applies dimming to the blurred image.
        gm convert -fill black -colorize 50% "$blur" "$dimblur"
esac
