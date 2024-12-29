FROM docker:24.0

# Create docker group with same GID as host Docker socket (typically 998 or 999)
RUN addgroup -g 999 docker && \
    adduser jenkins -D -G docker && \
    mkdir /.docker && \
    chown -R jenkins:docker /.docker && \
    chmod 777 /.docker

WORKDIR /workspace