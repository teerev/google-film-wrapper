FROM gcr.io/deeplearning-platform-release/tf2-gpu.2-6:latest AS BASE
RUN mkdir -p /home/repos
WORKDIR /home/repos
RUN git clone https://github.com/google-research/frame-interpolation && \
    cd frame-interpolation && \
    git checkout 69f8708f08e62c2edf46a27616a4bfcf083e2076
RUN mkdir -p /home/repos/google-film-wrapper
RUN apt-get update && apt-get install -y ffmpeg bc
