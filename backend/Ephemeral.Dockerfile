pipeline {
    agent {
        docker {
            image 'docker:24.0-dind'
            args '--privileged -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    environment {
        HOME = '/tmp'
        DOCKER_CONFIG = '/tmp/.docker'
        DOCKERFILE = 'Dockerfile'
        BUILD_TIMESTAMP = "${new Date().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', TimeZone.getTimeZone('UTC'))}"
        IMAGE_TAG = "1.0.0"
    }
    parameters {
        string(name: 'GOMOVIE_BACKEND_IMAGE', defaultValue: 'my-backend-image', description: 'Docker image name')
    }
    stages {
        stage('Build Docker Image') {
            steps {
                echo "→ Building Docker image using Docker-in-Docker container with tag: ${IMAGE_TAG}"
                sh """
                    mkdir -p ${DOCKER_CONFIG}
                    docker build \
                        --target runner \
                        --label org.opencontainers.image.version=${IMAGE_TAG} \
                        --label org.opencontainers.image.created=\$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
                        --label deployment_version=${IMAGE_TAG} \
                        --label git.commit=\$(git rev-parse HEAD || echo 'unknown') \
                        --label build.timestamp="${BUILD_TIMESTAMP}" \
                        --build-arg BUILD_VERSION=${IMAGE_TAG} \
                        --rm \
                        --no-cache \
                        -t ${params.GOMOVIE_BACKEND_IMAGE}:${IMAGE_TAG} \
                        -t ${params.GOMOVIE_BACKEND_IMAGE}:latest \
                        -f ${DOCKERFILE} .
                """
                echo "✓ Docker image built successfully"
            }
        }
    }
}