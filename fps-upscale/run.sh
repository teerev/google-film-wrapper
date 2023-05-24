#!/bin/bash

cd /home/repos/video-fps-upscale/fps-upscale/

# extract frames from source video
ffmpeg -i "./input/video/${1}" ./input/frames/out%08d.png

# Get the frame rate rounded up to an integer
frame_rate=$(ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate "./input/video/${1}" | bc -l)
frame_rate=$(echo "$frame_rate" | bc -l | xargs printf "%.0f")
echo "Source frame rate: $frame_rate"

# Define new frame rate as twice the source frame rate
frame_rate=$(bc -l <<< "$frame_rate*2")
echo "Target frame rate: $frame_rate"

cd input/frames/
shopt -s nullglob
frames=(*.png)
cd /home/repos/frame-interpolation/

# Use FILM package on every adjacent frame pairing and output interpolated frames with names "<filename>_int.png"
last_index=$(( ${#frames[@]} - 2 ))
for ((idx=0; idx<=last_index; ++idx)); do
  frame1="/home/repos/video-fps-upscale/fps-upscale/input/frames/${frames[idx]}"
  frame2="/home/repos/video-fps-upscale/fps-upscale/input/frames/${frames[idx+1]}"
  output_frame="/home/repos/video-fps-upscale/fps-upscale/output/frames/${frames[idx]}_int.png"

  echo "$frame1" "$frame2"

  python3 -m eval.interpolator_test \
    --frame1 "$frame1" \
    --frame2 "$frame2" \
    --model_path pretrained_models/film_net/Style/saved_model \
    --output_frame "$output_frame"
done

# Move frames to output directory
mv /home/repos/video-fps-upscale/fps-upscale/input/frames/*.png /home/repos/video-fps-upscale/fps-upscale/output/frames/
cd /home/repos/video-fps-upscale/fps-upscale/output/frames/

# Generate the output video and place in video output directory
output_file="${1%.*}_upscaled.mp4"
ffmpeg -framerate $frame_rate -pattern_type glob -i '*.png' -c:v libx264 -pix_fmt yuv420p ../video/$output_file
