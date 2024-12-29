pipeline {
    agent {
        dockerfile {
            filename 'backend/Builder2.Dockerfile'
            args '--privileged -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    stages {
        stage('Build Docker Image') {
            steps {
                sh """
                echo "→ Building application image..."
                docker build -t backend:1.0.0 -f backend/Dockerfile .
                echo "✓ Application image built successfully!"
                """
            }
        }
    }
}
