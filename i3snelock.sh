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

# Sets up configuration types. 
dim=$(xdpyinfo | grep dimensions | grep -o [0-9]*x[0-9]*\ pixels | grep -o [0-9][0-9]*x[0-9]*)
xres=$(echo "$dim" | grep -o [0-9]*x | grep -o [0-9]*)
yres=$(echo "$dim" | grep -o x[0-9]* | grep -o [0-9]*)

lock() {
    lightgrey="d9d9d9ff"
    i3lock -t -n -k --veriftext="" --wrongtext="" --ringcolor="e6e6e6ff" --keyhlcolor="737373ff" \
        --separatorcolor="737373ff" --insidecolor="7373730f" --linecolor="737373ff" --timecolor=$lightgrey \
        --datecolor=$lightgrey -i "$1"
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
        echo "  -h, --help                         displays help prompt" 
        echo "  -s, --startup [IMAGEFILE]          initializes i3snelock with a given background image;"
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
                screenshot="$HOME""/.cache/i3snelock/screenshot.png"

                # Take screenshot.
                escrotum -C && xclip -selection clipboard -t image/png -o > $screenshot

                xcenter=$(expr $xres / 4 + $xres / 8)
                ycenter=$(expr $yres / 3)

                # Applies Gaussian blur at a radius of 10 with a SD of 2.  # Applies dimming to the blurred image.
                ffmpeg -y -loglevel quiet -i "$screenshot" -filter_complex "[0:v]boxblur=10:1.5, eq=gamma=.8[bg]; \
                    [0:v]crop=$(expr $xres / 4):$(expr $yres / 3):$xcenter:$ycenter, eq=gamma=1.05, boxblur=10:1.5[fg]; \
                    [bg][fg]overlay=$xcenter:$ycenter[v]" -map "[v]" "$screenshot"

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

        xcenter=$(expr $xres / 4 + $xres / 8)
        ycenter=$(expr $yres / 3)

        ffmpeg -y -loglevel quiet -i "$mod_file" -filter_complex "scale=$xres:$yres, boxblur=10:1.5" "$blur"
        ffmpeg -y -loglevel quiet -i "$blur" -filter_complex "[0:v]crop=$(expr $xres / 4):$(expr $yres / 3):$xcenter:$ycenter, eq=gamma=1.05[fg]; \
            [0:v][fg]overlay=$xcenter:$ycenter[v]" -map "[v]" "$blur"

        ffmpeg -y -loglevel quiet -i "$blur" -filter_complex "[0:v]eq=gamma=.8[bg], \
            [0:v]crop=$(expr $xres / 4):$(expr $yres / 3):$xcenter:$ycenter, eq=gamma=1.05[fg]; \
            [bg][fg]overlay=$xcenter:$ycenter[v]" -map "[v]" "$blur"

        # Applies dimming to the blurred image.
        gm convert -fill black -colorize 50% "$blur" "$dimblur"
        ;;
esac
