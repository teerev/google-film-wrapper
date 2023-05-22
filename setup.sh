#!/bin/bash

# check if image exists
if [[ "$(docker images -q gfw-image 2> /dev/null)" == "" ]]; then
    # build image from Dockerfile with name "gfw-image"
    docker build -t gfw-image .;
fi

# check if container exists
if [[ "$(docker ps -a -f name=gfw-container -q 2> /dev/null)" == "" ]]; then
    # create container with name "gfw-container" from image
    docker run -d --gpus '"device=1"' -v ~/repos/google-film-wrapper/:/home/repos/google-film-wrapper --name gfw-container gfw-image;
fi

# check if directory exists in container
if [[ "$(docker exec gfw-container ls /home/repos/frame-interpolation/pretrained_models 2> /dev/null)" == "" ]]; then
    # copy directory inside the container
    docker exec gfw-container cp -r /home/repos/google-film-wrapper/pretrained_models /home/repos/frame-interpolation/
fi

# log into the container
docker exec -it gfw-container bash
