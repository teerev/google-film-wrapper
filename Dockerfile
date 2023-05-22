FROM gcr.io/deeplearning-platform-release/tf2-gpu.2-6:latest AS BASE
RUN mkdir -p /home/repos
WORKDIR /home/repos
RUN git clone https://github.com/google-research/frame-interpolation
RUN mkdir -p /home/repos/google-film-wrapper
