# video-fps-upscale

## What is this repo?

- This software takes an .mp4 video as input and returns an .mp4 video with the frame rate doubled. It is just a thin wrapper built around Google's [frame interpolation package](https://github.com/google-research/frame-interpolation) (FILM) which takes two images as input and returns interpolated frame(s). This wrapper works with one particular commit hash (69f8708) to ensure compatibility. If you want to use the latest version of FILM, just modify the ````git clone```` command in the Dockerfile by replacing

````
RUN git clone https://github.com/google-research/frame-interpolation && \
    cd frame-interpolation && \
    git checkout 69f8708f08e62c2edf46a27616a4bfcf083e2076
````
with

````
RUN git clone https://github.com/google-research/frame-interpolation
````
with the understanding that any subsequent updates to the FILM repo may break this wrapper.


- This repo requires an Nvidia GPU, and the [Nvidia Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) to be installed. (Otherwise the Dockerfile will create the container without GPU support and it will not work.)

- This wrapper also only works with the "One mid-frame interpolation" method with the ````eval.interpolator_test```` script (inserting one interpolated frame for every pair, thereby doubling frame rate). The "Many in-between frames interpolation" with the ````eval.interpolator_cli```` script and the ````--times_to_interpolate```` flag throws dependency errors which I have not yet diagnosed. ("No package 'mediapy' found, or something.)





## To use this wrapper, do the following steps, in this order:


1. Clone this repo:
````bash
https://github.com/teerev/google-film-wrapper.git
````
2. Download the pre-trained models from Google's [Drive directory](https://drive.google.com/drive/folders/1q8110-qp225asX3DQvZnfLfJPkCHmDpy?usp=sharing) into the repository's main directory. You should have a directory called ````pretrained_models```` in the repository's main directory so the working tree looks like this:

````
├── Dockerfile
├── fps-upscale
│   ├── input
│   │   ├── frames
│   │   │   ├── out00000001.png
│   │   │   ├── out00000002.png
│   │   │   ├── out00000003.png
│   │   │   └── out00000004.png
│   │   └── video
│   │       └── eggs.mp4
│   ├── output
│   │   ├── frames
│   │   │   ├── out00000001.png
│   │   │   ├── out00000001.png_int.png
│   │   │   ├── out00000002.png
│   │   │   ├── out00000002.png_int.png
│   │   │   ├── out00000003.png
│   │   │   ├── out00000003.png_int.png
│   │   │   └── out00000004.png
│   │   └── video
│   │       └── eggs_upscaled.mp4
│   └── run.sh
├── pretrained_models
│   ├── film_net
│   │   ├── L1
│   │   │   └── saved_model
│   │   │       ├── assets
│   │   │       ├── keras_metadata.pb
│   │   │       ├── saved_model.pb
│   │   │       └── variables
│   │   │           ├── variables.data-00000-of-00001
│   │   │           └── variables.index
│   │   ├── Style
│   │   │   └── saved_model
│   │   │       ├── assets
│   │   │       ├── keras_metadata.pb
│   │   │       ├── saved_model.pb
│   │   │       └── variables
│   │   │           ├── variables.data-00000-of-00001
│   │   │           └── variables.index
│   │   └── VGG
│   │       └── saved_model
│   │           ├── assets
│   │           ├── keras_metadata.pb
│   │           ├── saved_model.pb
│   │           └── variables
│   │               ├── variables.data-00000-of-00001
│   │               └── variables.index
│   └── vgg
│       └── imagenet-vgg-verydeep-19.mat
├── README.md
└── setup.sh
````

3. Run the setup.sh file to create the Docker image and container using the Dockerfile, and execute the container's shell. (On subsequent runs, if the image/container already exist, it will just execute the shell.) The image name is set to ````gfw-image```` and the container name to ````gfw-container```` by default. You can change these in the ````setup.sh```` script

````
./setup.sh
````

4. Inside the container's shell, use the command ````ls````to verify that you have two directories. The directory ````frame-interpolation```` is the main code from the [frame interpolation package](https://github.com/google-research/frame-interpolation) and google-film-wrapper contains the tool in this repo:

````
frame-interpolation  google-film-wrapper
````

5. Navigate into ````google-film-wrapper/fps-upscale````, and run the ````run.sh```` script followed by the name of the .mp4 file you want to upscale. The .mp4 file needs to be located in the directory ````fps-upscale/input/video````:

````
./run.sh eggs.mp4
````

6. The upscaled video should appear in the directory ````fps-upscale/output/video````, along with the frames (source, and interpolated) in the directory ````fps-upscale/output/frames````.




### Notes on benchmarks

- 33 seconds per full HD (1920x1080) frame on an RTX 3060, i.e. about 1000 seconds of processing per second of footage at Full HD at 30fps (input) upscaled to 60fps (output).












