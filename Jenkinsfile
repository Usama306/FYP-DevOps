pipeline {
    agent any

    environment {
        DOCKER_GROUP = sh(script: 'getent group docker | cut -d: -f3', returnStdout: true).trim()
        REMOTE_HOST = 'pve.netbird.cloud'
        REMOTE_USER = 'dev'
        REMOTE_PORT = '2222'
    }

    stages {
        stage('Install Dependencies') {
            steps {
                echo 'Installing Ansible and dependencies...'
                sh '''
                    # Install Ansible if not present
                    ansible --version || sudo -n apt update && sudo -n apt install -y ansible sshpass
                    
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

        stage('Setup SSH Config') {
            steps {
                echo 'Setting up SSH configuration...'
                sh '''
                    mkdir -p ~/.ssh
                    echo "Host ${REMOTE_HOST}
                        Port ${REMOTE_PORT}
                        StrictHostKeyChecking no
                        UserKnownHostsFile=/dev/null" > ~/.ssh/config
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
remote_tmp = /tmp/.ansible-${USER}/tmp

[ssh_connection]
pipelining = True
EOF

                    # Create inventory file
                    cat > inventory.ini << EOF
[remote]
${REMOTE_HOST} ansible_port=${REMOTE_PORT} ansible_user=${REMOTE_USER} ansible_password=dev

[remote:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

                    # Run Ansible playbook with verbose output
                    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini deploy.yml -vv
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                script {
                    // Wait for services to be ready
                    sh 'sleep 30'
                    
                    // Verify endpoints
                    def environments = [
                        [port: 3001, name: 'Development'],
                        [port: 3002, name: 'Test'],
                        [port: 3003, name: 'Production']
                    ]
                    
                    environments.each { env ->
                        try {
                            def response = sh(
                                script: "curl -s -o /dev/null -w '%{http_code}' ${REMOTE_HOST}:${env.port}",
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
