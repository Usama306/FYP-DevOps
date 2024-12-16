pipeline {
    agent any

    environment {
        DOCKER_GROUP = sh(script: 'getent group docker | cut -d: -f3', returnStdout: true).trim()
        ANSIBLE_BECOME_PASS = credentials('jenkins-sudo-password')
    }

    stages {
        stage('Setup Permissions') {
            steps {
                echo 'Setting up Jenkins permissions...'
                sh '''
                    # Add NOPASSWD sudo permissions for Jenkins
                    echo "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/jenkins
                    sudo chmod 440 /etc/sudoers.d/jenkins
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing Ansible and dependencies...'
                sh '''
                    # Install Ansible if not present
                    which ansible || sudo -E apt update && sudo -E apt install -y ansible
                    
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
                    sudo usermod -aG docker jenkins || true
                    # Ensure Docker socket has correct permissions
                    sudo chmod 666 /var/run/docker.sock || true
                '''
            }
        }

        stage('Ansible Deploy') {
            steps {
                echo 'Running Ansible playbook...'
                withEnv(['ANSIBLE_HOST_KEY_CHECKING=False']) {
                    sh '''
                        # Create ansible config if it doesn't exist
                        cat > ansible.cfg << EOF
[defaults]
host_key_checking = False
deprecation_warnings = False
interpreter_python = /usr/bin/python3
stdout_callback = yaml

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
EOF

                        # Create inventory file
                        cat > inventory.ini << EOF
[local]
localhost ansible_connection=local

[local:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_become=yes
ansible_become_method=sudo
ansible_become_user=root
EOF

                        # Run Ansible playbook
                        ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i inventory.ini deploy.yml
                    '''
                }
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
