#!/usr/bin/env bash

# Author: Ket-Meng Cheng
# Github: http://www.github.com/Aeternitaas
# Dependencies: graphicsmagick, feh, xdpyinfo, escrotum, ffmpeg

# Create an folder to hold the wallpaper phases
img_folder="$HOME/.cache/i3snelock"

# Grabs the current background through feh
feh_image=$(cat ~/.fehbg | grep feh | grep -o \'/.*\' | grep -o [^\'].*[^\'])

# Dimblur file.
dimblur="$img_folder""/dimblur.png"

# Regular blur file.
blur="$img_folder""/blur.png"

# Modified file.
mod_file="$img_folder/modified_file.png"

lock() {
    i3lock -t -n -i "$1"
}

check_folder() {
    if [ ! -d $img_folder ]; then 
        echo "Please run \`i3snelock -s [IMGFILE]\` to set up i3snelock."
        exit 2
    fi 
}

case "$1" in 
    # Case in which no args are presented.
    "" | -h | --help)
        echo "Usage: i3snelock [OPTION]"
        echo
        echo "  -l, --lock [LOCKSTYLE]             locks the screen with the lock setting chosen; leave"
        echo "                                     may be left blank for default dimblur setting"
        echo "  -h, --help                         displays help prompt" echo "  -s, --startup [IMAGEFILE]          initializes i3snelock with a given background image;"
        echo "                                     to be run if being run for the first time or if a"
        echo "                                     custom background image is desired"
        exit 1
        ;;

    -l | --lock) 
        case "$2" in
            # TODO: add other configurations.
            "")
                # If setup has not been run, exit and prompt the user to do so.
                check_folder

                # Default configuration; dim + blur
                lock "$dimblur"
                ;;
            blur)
                check_folder

                lock "$blur"
                ;;
            screen)
                # TODO: caching? Probably not. Could use i3lock's inbuilt -B blur.
                screenshot="$HOME""/.cache/i3snelock/screenshot.png"

                # Take screenshot.
                escrotum -C && xclip -selection clipboard -t image/png -o > $screenshot

                # Applies Gaussian blur at a radius of 10 with a SD of 2.  # Applies dimming to the blurred image.
                #gm convert -blur 10x2 -fill black -colorize 50% \
                    #"$screenshot" "$screenshot"

                ffmpeg -y -loglevel quiet -i "$screenshot" -vf "boxblur=5:2" "$screenshot"

                lock "$screenshot"
                ;;
        esac
    ;;

    -s | --startup)
        shift

        if [ ! -d $img_folder ]; then
            # Create the folder at img_folder if it does not exist.
            echo "Created directory located at $img_folder" mkdir -p "$img_folder"
        fi
        
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
        
        # TODO: implement blur per-user specification.
        # TODO: implement screenshot blurring.
        # TODO: draw shapes.

        # Sets up configuration types. 
        dim=$(xdpyinfo | grep dimensions | grep -o [0-9]*x[0-9]*\ pixels | grep -o [0-9][0-9]*x[0-9]*)
        xres=$(echo "$dim" | grep -o [0-9]*x | grep -o [0-9]*)
        yres=$(echo "$dim" | grep -o x[0-9]* | grep -o [0-9]*)

        # Converts the image to the screen's dimensions.
        gm convert -resize "$yres""^" -gravity center "$mod_file" "$mod_file"

        # Applies Gaussian blur at a radius of 10 with a SD of 2.
        gm convert -blur 10x2 "$mod_file" "$blur"

        # Applies dimming to the blurred image.
        gm convert -fill black -colorize 50% "$blur" "$dimblur"
        ;;
esac
