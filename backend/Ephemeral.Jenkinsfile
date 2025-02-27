@Library('shared-library') _
pipeline {
    agent {
        docker {
            image 'docker:24.0-dind'
            args '--privileged -v /var/run/docker.sock:/var/run/docker.sock --rm -u root'
        }
    }
    options {
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
        timestamps()
    }

    environment {
        DOCKERFILE = 'backend/Dockerfile'
        IMAGE_VERSION_FILE = 'backend-version.txt'
        BUILD_TIMESTAMP = sh(script: 'date -u "+%Y-%m-%d %H:%M:%S UTC"', returnStdout: true).trim()
    }
    parameters {
        choice(
        name: 'VERSION_INCREMENT',
        choices: ['PATCH','MAJOR','MINOR'],
        description: 'Select the version part to increment (default: PATCH)'
        )
        string(
            name: 'GOMOVIE_BACKEND_IMAGE',
            defaultValue: 'orsanaw/gomovie-backend-image-ephemeral',
            description: 'Docker repository for the backend image. Must not be empty.',
            trim: true
        )
    }
    stages {
        stage('Validate Environment') {
            steps {
                script {
                    echo "→ Starting environment validation at ${BUILD_TIMESTAMP}"
                    if (!params.GOMOVIE_BACKEND_IMAGE?.trim()) {
                        error "GOMOVIE_BACKEND_IMAGE parameter is missing or empty."
                    }
                    echo "✓ Environment validation successful."

                    try {
                        echo "→ Checking Docker daemon status..."
                        def dockerInfo = sh(script: 'docker info', returnStdout: true).trim()
                        echo "✓ Docker daemon is running and accessible"
                        def dockerVersion = sh(script: 'docker version --format "{{.Server.Version}}"', returnStdout: true).trim()
                        echo "✓ Docker version: ${dockerVersion}"

                    } catch (Exception e) {
                            error """
                                Docker daemon check failed: ${e.message}
                            """
                    }
                }
            }
        }
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Read Current Version') {
            steps {
                script {
                    try {
                        echo "→ Reading current version from ${env.IMAGE_VERSION_FILE}..."
                        readCurrentVersion(env.IMAGE_VERSION_FILE, params.VERSION_INCREMENT)
                        echo "✓ New version tag: ${IMAGE_TAG}"
                    } catch (Exception e) {
                        error "Failed to read/increment version: ${e.message}"
                    }
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        echo "→ Building Docker image"
                        sh """
                                docker build \
                                    --target runner \
                                    --label org.opencontainers.image.version=${IMAGE_TAG} \
                                    --label org.opencontainers.image.created=\$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
                                    --label deployment_version=${IMAGE_TAG} \
                                    --label git.commit=\$(git rev-parse HEAD) \
                                    --label build.timestamp="${BUILD_TIMESTAMP}" \
                                    --label build.user="\$(whoami)" \
                                    --build-arg BUILD_VERSION=${IMAGE_TAG} \
                                    --rm \
                                    --no-cache \
                                    -t ${params.GOMOVIE_BACKEND_IMAGE}:${IMAGE_TAG} \
                                    -t ${params.GOMOVIE_BACKEND_IMAGE}:latest \
                                    -f ${env.DOCKERFILE} .
                        """
                        echo "✓ Docker image built successfully"


                        // Push the Docker image to the registry
                        withCredentials([usernamePassword(
                            credentialsId: 'dockerhub-credentials',
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASSWORD')]) {
                            sh """
                                echo "→ Logging into Docker registry..."
                                echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USER" --password-stdin
                                echo "✓ Successfully logged into Docker registry"

                                echo "→ Pushing image with tag: ${IMAGE_TAG}"
                                docker push ${params.GOMOVIE_BACKEND_IMAGE}:${IMAGE_TAG}
                                echo "✓ Successfully pushed ${params.GOMOVIE_BACKEND_IMAGE}:${IMAGE_TAG}"

                                echo "→ Pushing latest tag..."
                                docker push ${params.GOMOVIE_BACKEND_IMAGE}:latest
                                echo "✓ Successfully pushed ${params.GOMOVIE_BACKEND_IMAGE}:latest"

                                echo "→ Logging out from Docker registry..."
                                docker logout
                                echo "✓ Successfully logged out from Docker registry"
                            """
                        }

                   } catch (Exception e) {
                        error "Failed to build Docker image: ${e.message}"
                   }
                }
            }
        }
        stage('Post Image Push') {
            parallel {
                stage('Update Version File') {
                    when {
                        expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
                    }
                    steps {
                        script {
                            try {
                                echo "→ Updating version file: ${env.IMAGE_VERSION_FILE}"
                                writeFile file: env.IMAGE_VERSION_FILE, text: IMAGE_TAG
                                archiveArtifacts artifacts: env.IMAGE_VERSION_FILE, fingerprint: true
                                echo "✓ Version file updated and archived"
                            } catch (Exception e) {
                                error "Failed to update version file: ${e.message}"
                            }
                        }
                    }
                }
                stage('List Docker Images') {
                    steps {
                        script {
                            sh """
                                docker images --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}"
                            """
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                try {
                    echo "→ Cleaning up the builder image with label builder=true..."
                    sh 'docker rmi $(docker images --filter=label=builder=true -q) || echo "No builder images to remove."'
                    echo "✓ Builder image removed"
                } catch (Exception e) {
                    echo "⚠️ Failed to clean up builder image: ${e.message}"
                }
            }
        }
        success {
            script {
                def duration = currentBuild.durationString
                echo """
                    ✅ Build Successful!
                    • Image: ${params.GOMOVIE_BACKEND_IMAGE}:${IMAGE_TAG}
                    • Build Duration: ${duration}
                    • Build URL: ${env.BUILD_URL}
                """
            }
        }
        failure {
            script {
                def duration = currentBuild.durationString
                echo """
                    ❌ Build Failed!
                    • Duration: ${duration}
                    • Build URL: ${env.BUILD_URL}
                    Please check the logs above for details.
                """
            }
        }
    }
}