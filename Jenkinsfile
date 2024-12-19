pipeline {
    agent any

    environment {
        REMOTE_HOST = 'pve.netbird.cloud'
        REMOTE_USER = 'dev'
        REMOTE_PORT = '2222'
        ANSIBLE_HOST_KEY_CHECKING = 'False'
        ANSIBLE_BECOME_ASK_PASS = 'False'
    }

    stages {
        stage('Install Dependencies') {
            steps {
                echo 'Installing Ansible and dependencies...'
                script {
                    // Check if Ansible is available
                    def hasAnsible = sh(script: 'which ansible', returnStatus: true) == 0
                    def hasSshpass = sh(script: 'which sshpass', returnStatus: true) == 0
                    
                    if (!hasAnsible || !hasSshpass) {
                        error """
                            Required dependencies are missing. Please ensure the following are installed on the Jenkins server:
                            - ansible
                            - sshpass
                            
                            You can install them using:
                            sudo apt update && sudo apt install -y ansible sshpass
                        """
                    }
                }
                
                // Install Ansible collections without sudo
                sh '''
                    # Create local ansible collections directory if it doesn't exist
                    mkdir -p ~/.ansible/collections
                    
                    # Install required Ansible collections
                    ansible-galaxy collection install community.docker -p ~/.ansible/collections || true
                    
                    # Display versions for debugging
                    ansible --version
                    ansible-galaxy collection list
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
                    chmod 600 ~/.ssh/config
                '''
            }
        }

        stage('Pre-check Remote Server') {
            steps {
                echo 'Checking remote server access...'
                sh '''
                    # Test SSH connection
                    sshpass -p "dev" ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "echo 'SSH connection successful'"
                    
                    # Check if any apt process is running
                    sshpass -p "dev" ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "ps aux | grep -i apt"
                    
                    # Check available disk space
                    sshpass -p "dev" ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "df -h"
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
allow_world_readable_tmpfiles = true
command_warnings = False

[privilege_escalation]
become = true
become_method = sudo
become_ask_pass = false

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
ansible_become=yes
ansible_become_method=sudo
ansible_become_pass=dev
ansible_sudo_pass=dev
EOF

                    # Set correct permissions for inventory file
                    chmod 600 inventory.ini
                    
                    # Run Ansible playbook with verbose output
                    ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_BECOME_ASK_PASS=False ansible-playbook -i inventory.ini deploy.yml -vv
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                script {
                    // Wait for services to be ready
                    sh 'sleep 30'
                    
                    // Verify endpoints using SSH to check locally on the remote server
                    def environments = [
                        [port: 3001, name: 'Development'],
                        [port: 3002, name: 'Test'],
                        [port: 3003, name: 'Production']
                    ]
                    
                    environments.each { env ->
                        try {
                            def response = sh(
                                script: """
                                    sshpass -p "dev" ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} \
                                    "curl -s -o /dev/null -w '%{http_code}' http://localhost:${env.port}"
                                """,
                                returnStdout: true
                            ).trim()
                            
                            if (response == "200") {
                                echo "${env.name} environment is accessible on port ${env.port}"
                            } else {
                                error "${env.name} environment failed health check with status ${response}"
                            }
                        } catch (Exception e) {
                            error "${env.name} environment is not accessible: ${e.message}"
                        }
                    }

                    // Verify external access
                    environments.each { env ->
                        try {
                            def response = sh(
                                script: """
                                    sshpass -p "dev" ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} \
                                    "nc -zv 0.0.0.0 ${env.port} 2>&1"
                                """,
                                returnStatus: true
                            )
                            
                            if (response == 0) {
                                echo "${env.name} environment is externally accessible on port ${env.port}"
                            } else {
                                error "${env.name} environment is not externally accessible"
                            }
                        } catch (Exception e) {
                            error "${env.name} environment external access check failed: ${e.message}"
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
