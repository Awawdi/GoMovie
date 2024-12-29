pipeline {
    agent {
        docker {
            image 'docker:24.0'
            args '''
                -v /var/run/docker.sock:/var/run/docker.sock \
                --group-add 999 \
                --rm \
                -u nonroot
            '''
        }
    }
    environment {
        DOCKERFILE = 'backend/Dockerfile'
        BUILD_TIMESTAMP = "${new Date().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', TimeZone.getTimeZone('UTC'))}"
        IMAGE_TAG = "1.0.0"
    }
    parameters {
        string(name: 'GOMOVIE_BACKEND_IMAGE', defaultValue: 'my-backend-image-eph', description: 'Docker image name')
    }
    stages {
        stage('Build Docker Image') {
            steps {
                script {

                        sh """
                        docker build \
                            --target runner \
                            --label org.opencontainers.image.version=${IMAGE_TAG} \
                            --label org.opencontainers.image.created=\$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
                            --build-arg BUILD_VERSION=${IMAGE_TAG} \
                            --security-opt no-new-privileges \
                            --rm \
                            --no-cache \
                            -t ${params.GOMOVIE_BACKEND_IMAGE}:${IMAGE_TAG} \
                            -t ${params.GOMOVIE_BACKEND_IMAGE}:latest \
                            -f ${DOCKERFILE} .
                        """

                }
            }
        }
    }
}