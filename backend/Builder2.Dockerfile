# Use a base image with Docker installed
FROM docker:24.0-dind

# Install essential build tools and dependencies
RUN apk add --no-cache \
    git \
    openssh-client \
    curl \
    bash \
    make \
    python3 \
    py3-pip \
    docker-compose

ENV DOCKER_TLS_CERTDIR=/certs
RUN mkdir -p /certs/client && chmod 1777 /certs/client

RUN mkdir -p /.docker && chmod 777 /.docker

WORKDIR /workspace
RUN chmod 777 /workspace

RUN mkdir -p /home/jenkins && \
    chmod -R 777 /home/jenkins

ENV DOCKER_HOST=unix:///var/run/docker.sock

CMD ["dockerd"]