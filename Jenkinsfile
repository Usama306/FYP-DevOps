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
                    ansible --version || sudo -n apt update && sudo -n apt install -y ansible
                    
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
                    id -nG | grep -q docker || sudo -n usermod -aG docker jenkins
                    # Ensure Docker socket has correct permissions
                    [ -w /var/run/docker.sock ] || sudo -n chmod 666 /var/run/docker.sock
                '''
            }
        }

        stage('Ansible Deploy') {
            steps {
                echo 'Running Ansible playbook...'
                sh '''
                    # Create ansible config
                    cat > ansible.cfg << EOF
[defaults]
host_key_checking = False
deprecation_warnings = False
interpreter_python = /usr/bin/python3
stdout_callback = yaml
ansible_connection = local

[privilege_escalation]
become = False
EOF

                    # Create inventory file
                    cat > inventory.ini << EOF
[local]
localhost ansible_connection=local
EOF

                    # Run Ansible playbook
                    ansible-playbook -i inventory.ini deploy.yml
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                script {
                    // Check container status
                    sh 'docker ps'
                    
                    // Wait for services to be ready
                    sh 'sleep 10'
                    
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
