pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = "${env.GOMOVIE_FRONTEND_IMAGE}"
        KUBECONFIG_CREDENTIAL = "${env.KUBECONFIG_CREDENTIAL}"
    }

    stages {
        stage('Retrieve Deployment Version') {
            steps {
                script {
                    DEPLOYMENT_VERSION = sh(
                        script: "docker inspect --format='{{index .Config.Labels \"deployment_version\"}}' ${env.DOCKERHUB_REPO}:latest",
                        returnStdout: true
                    ).trim()

                    if (!DEPLOYMENT_VERSION) {
                        error("Label 'deployment_version' not found in the Docker image. Job will fail.")
                    }

                    echo "Retrieved deployment_version: ${DEPLOYMENT_VERSION}"
                }
            }
        }

        stage('Update Kubernetes Deployment') {
            steps {
                withCredentials([file(credentialsId: env.KUBECONFIG_CREDENTIAL, variable: 'KUBECONFIG')]) {
                    script {
                        sh """
                        export KUBECONFIG=${KUBECONFIG}
                        kubectl set image deployment/gomovie-deployment gomovie=${env.DOCKERHUB_REPO}:${DEPLOYMENT_VERSION} --record
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
