pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = "${env.GOMOVIE_FRONTEND_IMAGE}"
        KUBECONFIG_CREDENTIAL = "${env.KUBECONFIG_CREDENTIAL}"
        BUILD_JOB_NAME = 'build-GoMovie-frontend-image'
        DEPLOYMENT_NAME = 'gomovie-deployment'
        CONTAINER_NAME = 'gomovie'
    }

    stages {
        stage('Retrieve Version File') {
            steps {
                script {
                    step([
                        $class: 'CopyArtifact',
                        projectName: "${BUILD_JOB_NAME}",
                        filter: 'version.txt',
                        fingerprintArtifacts: true,
                        target: '.'
                    ])
                    IMAGE_TAG = readFile('version.txt').trim()
                    echo "Retrieved IMAGE_TAG: ${IMAGE_TAG}"
                }
            }
        }
        stage('Verify Deployment Version') {
            steps {
                script {
                    DEPLOYMENT_VERSION = sh(
                        script: "docker inspect --format='{{index .Config.Labels \"deployment_version\"}}' ${env.DOCKERHUB_REPO}:${IMAGE_TAG}",
                        returnStdout: true
                    ).trim()

                    if (DEPLOYMENT_VERSION != IMAGE_TAG) {
                        error "Mismatch: deployment_version=${DEPLOYMENT_VERSION}, IMAGE_TAG=${IMAGE_TAG}"
                    }

                    echo "Verified: deployment_version=${DEPLOYMENT_VERSION} matches IMAGE_TAG=${IMAGE_TAG}"
                }
            }
        }
        stage('Update Kubernetes Deployment') {
            steps {
                withCredentials([file(credentialsId: env.KUBECONFIG_CREDENTIAL, variable: 'KUBECONFIG')]) {
                    script {
                        sh """
                        export KUBECONFIG=${KUBECONFIG}
                        kubectl set image deployment/${env.DEPLOYMENT_NAME} ${env.CONTAINER_NAME}=${env.DOCKERHUB_REPO}:${IMAGE_TAG} --record

                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Successfully updated Kubernetes deployment to use image: ${env.DOCKERHUB_REPO}:${DEPLOYMENT_VERSION}"
        }
        failure {
            echo "Kubernetes Deployment update failed. Check the logs for details."
        }
    }
}
