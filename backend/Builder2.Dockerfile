FROM docker:24.0

RUN apk add --no-cache bash git curl openjdk11 build-base
ENV HOME=/workspace
RUN mkdir -p $HOME/.docker && chmod -R 700 $HOME/.docker
WORKDIR /workspace
CMD ["bash"]
