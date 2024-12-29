# Use the official Docker image as the base
FROM docker:24.0

# Install required tools
RUN apk add --no-cache \
    bash \
    git \
    curl \
    openjdk11 \
    build-base

# Set up Docker CLI (already included in the base image)
RUN docker --version

# Set the working directory inside the container
WORKDIR /workspace

# Optional: Add an entrypoint script to set up the environment if needed
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Default entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default CMD to keep the container running
CMD ["bash"]
