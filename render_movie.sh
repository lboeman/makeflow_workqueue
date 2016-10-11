#!/bin/bash
# Creates a makeflow file which is then called to create a movie of a rendered object.

movie_length=$1
pov_file=$2
movie_file=$3

echo $movie_length
echo $pov_file
echo $movie_file

touch movie.makeflow

movie_frames=$((movie_length*10)) 
echo $movie_frames
for i in $(seq $movie_frames)
do
	printf -v j "%03d" $i 
	echo "frame"$j".png:\r \t povray +Imunsell_1929.pov +Oframe"$j".png +K"$j
done
