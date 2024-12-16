pipeline {
    agent any

    environment {
        DOCKER_GROUP = sh(script: 'getent group docker | cut -d: -f3', returnStdout: true).trim()
    }

    stages {
        stage('Clone Code') {
            steps {
                echo 'Cloning the repository...'
                git branch: 'main', url: 'https://github.com/Usama306/FYP-DevOps.git'
            }
        }

        stage('Docker Permissions') {
            steps {
                echo 'Setting up Docker permissions...'
                sh '''
                    # Add jenkins user to docker group if not already added
                    groups jenkins | grep -q docker || newgrp docker
                    # Ensure Docker socket has correct permissions
                    [ -S /var/run/docker.sock ] && [ $(stat -c '%g' /var/run/docker.sock) -eq ${DOCKER_GROUP} ]
                '''
            }
        }

        stage('Build & Start Containers') {
            steps {
                echo 'Building and starting Docker containers...'
                script {
                    // Stop any existing containers
                    sh 'docker compose down || true'
                    
                    // Build and start new containers
                    sh 'docker compose up -d --build'
                }
            }
        }

        stage('Verify Containers') {
            steps {
                echo 'Verifying that containers are running...'
                sh "docker ps"
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed. Please check the logs.'
        }
    }
}
