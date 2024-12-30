# builder.Dockerfile
FROM ubuntu:20.04

# Install Docker CLI, Git, and Curl
RUN apt-get update && apt-get install -y \
    docker.io \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace