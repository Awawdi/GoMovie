# Builder Image for Docker Builds
FROM docker:20.10.24-dind AS builder

# Install additional tools needed for the build process
RUN apk add --no-cache \
    python3 \
    py3-pip \
    build-base \
    git

# Set the working directory
WORKDIR /workspace

# Install Python dependencies (Optional: If needed for custom tooling)
RUN pip install --no-cache-dir wheel

COPY ./build-scripts /workspace/build-scripts

CMD ["sh"]
