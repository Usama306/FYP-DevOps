pipeline {
    agent any

    environment {
        DOCKER_GROUP = sh(script: 'getent group docker | cut -d: -f3', returnStdout: true).trim()
    }

    stages {
        stage('Install Dependencies') {
            steps {
                echo 'Installing Ansible and dependencies...'
                sh '''
                    # Install Ansible if not present
                    which ansible || (sudo apt update && sudo apt install -y ansible)
                    
                    # Install required Ansible collections
                    ansible-galaxy collection install community.docker || true
                '''
            }
        }

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

        stage('Ansible Deploy') {
            steps {
                echo 'Running Ansible playbook...'
                sh '''
                    # Ensure playbook files are executable
                    chmod +x deploy.yml
                    
                    # Run Ansible playbook
                    ansible-playbook deploy.yml
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                script {
                    // Check container status
                    sh 'docker ps'
                    
                    // Verify endpoints
                    def environments = [
                        [port: 3001, name: 'Development'],
                        [port: 3002, name: 'Test'],
                        [port: 3003, name: 'Production']
                    ]
                    
                    environments.each { env ->
                        try {
                            def response = sh(
                                script: "curl -s -o /dev/null -w '%{http_code}' http://localhost:${env.port}",
                                returnStdout: true
                            ).trim()
                            
                            if (response == "200") {
                                echo "${env.name} environment is accessible on port ${env.port}"
                            } else {
                                error "${env.name} environment failed health check"
                            }
                        } catch (Exception e) {
                            error "${env.name} environment is not accessible"
                        }
                    }
                }
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
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}
