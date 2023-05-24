#!/bin/bash

IMAGE_NAME=gfw-image
CONTAINER_NAME=gfw-container

# check if image exists
if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
    # build image from Dockerfile with name "gfw-image"
    docker build -t $IMAGE_NAME .;
fi

# check if container exists
if [[ "$(docker ps -a -f name=$CONTAINER_NAME -q 2> /dev/null)" == "" ]]; then
    # create container with name "gfw-container" from image
    docker run -d --gpus '"device=1"' -v "${PWD}:/home/repos/video-fps-upscale" --name $CONTAINER_NAME $IMAGE_NAME;
fi

# check if directory exists in container
if [[ "$(docker exec $CONTAINER_NAME ls /home/repos/frame-interpolation/pretrained_models 2> /dev/null)" == "" ]]; then
    # copy directory inside the container
    docker exec $CONTAINER_NAME cp -r /home/repos/video-fps-upscale/pretrained_models /home/repos/frame-interpolation/
fi

# log into the container
docker exec -it $CONTAINER_NAME bash
