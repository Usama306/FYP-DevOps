pipeline {
    agent any

    environment {
        APP_DIR = '/home/devops/app'
    }

    stages {
        stage('Clone Code') {
            steps {
                echo 'Cloning the repository...'
                git branch: 'main', url: 'https://github.com/Usama306/FYP-DevOps.git'
            }
        }

        stage('Build & Start Containers') {
            steps {
                echo 'Building and starting Docker containers...'
                script {
                    sh "cd ${APP_DIR} && docker-compose down"
                    sh "cd ${APP_DIR} && docker-compose up -d --build"
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
