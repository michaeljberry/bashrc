#!/bin/bash
makegif(){
	outputFileName=$1
	if [ -z "$outputFileName" ]; then
		outputFileName="out"
	fi
	cd ~/Desktop
	ffmpeg -i in.mov -s 600x400 -pix_fmt rgb24 -r 10 -f gif - | gifsicle --optimize=3 --delay=3 > ${outputFileName}.gif
	cd ~
}
