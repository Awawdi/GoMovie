FROM docker:20.10.7

WORKDIR /workspace

RUN apk add --no-cache \
    curl \
    git \
    bash

# Set the environment variable for Docker to ensure Docker commands work inside the container
ENV DOCKER_CLI_EXPERIMENTAL=enabled

ENTRYPOINT ["docker"]
