FROM docker:24.0
RUN mkdir /.docker && chmod 777 /.docker
WORKDIR /workspace