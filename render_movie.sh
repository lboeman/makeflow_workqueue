#!/bin/bash
# Creates a makeflow file which is then called to create a movie of a rendered object.

movie_length=$1
pov_file=$2
movie_file=$3

echo $movie_length
echo $pov_file
echo $movie_file

touch movie.makeflow
# Add all the frames while keeping track of a list of them to built a make command for
# the final movie.
# Credit here to Kyle Saxberg, I looked through his bash script to overcome some of my
# issues in this loop.

movie_frames=$((movie_length*10)) 
echo $movie_frames
for i in $(seq $movie_frames)
do	
	printf "frame%s.png: munsell_1929.pov CIE.inc\n" "$i" >> movie.makeflow
	printf "\tpovray +Imunsell_1929.pov +Oframe%03d.png +K%03d\n" "$i" "$i" >> movie.makeflow
	imagefiles=$(printf "%s frame%03d.png" "$imagefiles" "$i")
done

#write a makeflow rule for the movie file
printf "%s : %s\n" "$movie_file" "$imagefiles" >> movie.makeflow
printf "\tffmpeg -r 10 -i frame%03d.png -r ntsc %s" "$movie_file" >> movie.makeflow

#Submit the makeflow with pbs here. TODO: figure out how to pbs_submit_works on ua hpc
