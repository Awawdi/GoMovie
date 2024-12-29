FROM docker:24.0

RUN apk add --no-cache bash git curl openjdk11 build-base

WORKDIR /workspace
CMD ["bash"]
