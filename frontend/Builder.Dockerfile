FROM alpine:3.19

RUN apk add --no-cache \
    bash \
    git

WORKDIR /workspace

COPY ./frontend/cleanup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/cleanup.sh