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
    py3-pip

# Install Docker Compose (optional but often useful)
RUN pip3 install docker-compose

# Set up Docker configuration
ENV DOCKER_TLS_CERTDIR=/certs
RUN mkdir -p /certs/client && chmod 1777 /certs/client

# Set working directory
WORKDIR /workspace

# Keep container running (necessary for Jenkins pipeline)
CMD ["dockerd"]