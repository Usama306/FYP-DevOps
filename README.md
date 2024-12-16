# Node.js Multi-Environment Application with CI/CD Pipeline

This project is a Node.js application deployed across multiple environments (Development, Test, and Production) using Docker containers and automated CI/CD pipeline with Jenkins and Ansible.

## Architecture Overview

- **Application**: Node.js web application
- **Containerization**: Docker with multi-environment setup
- **CI/CD**: Jenkins Pipeline
- **Configuration Management**: Ansible
- **Environments**: Development, Test, and Production

## Prerequisites

- Jenkins server with following plugins:
  - Pipeline
  - Git
  - Ansible
  - SSH
- Docker
- Ansible
- SSH access to deployment server
- Git

## Environment Setup

The application runs in three separate environments:

1. **Development** (Port: 3001)
2. **Test** (Port: 3002)
3. **Production** (Port: 3003)

Each environment runs in its own Docker container with isolated configurations.

## Deployment Architecture

```
┌─────────────────┐      ┌─────────────────┐      ┌──────────────────────────────────────────┐
│   Jenkins CI    │────▶ │     Ansible     │────▶│  Docker Hosts On Workers using Ansible   │
└─────────────────┘      └─────────────────┘      └──────────────────────────────────────────┘
        │                                                             │
        │                                                             │
        │                                                             │
        ▼                                                             ▼
┌─────────────────┐                                             ┌─────────────────────────┐
│  GitHub Repo    │                                             │   Containers            │
└─────────────────┘                                             │  - Dev  (Worker1:3001)  │
                                                                │  - Test (Worker2:3002)  │
                                                                │  - Prod (Worker3:3003)  │
                                                                └─────────────────────────┘
```

## Project Structure

```
.
├── app/
│   ├── src/
│   ├── public/
│   ├── views/
│   └── package.json
├── Dockerfile
├── docker-compose.yml
├── Jenkinsfile
├── deploy.yml
└── README.md
```

## CI/CD Pipeline Stages

1. **Install Dependencies**
   - Installs required tools (Ansible, sshpass)
   - Sets up Ansible collections

2. **Clone Code**
   - Clones the repository from GitHub

3. **Setup SSH Config**
   - Configures SSH for remote server access

4. **Pre-check Remote Server**
   - Verifies SSH connectivity
   - Checks system resources
   - Validates prerequisites

5. **Ansible Deploy**
   - Installs and configures Docker
   - Builds and deploys containers
   - Sets up networking and permissions

6. **Verify Deployment**
   - Checks container status
   - Verifies endpoint accessibility
   - Validates external access

## Deployment Process

1. **Local Development**:
   ```bash
   docker compose up -d
   ```

2. **Jenkins Pipeline**:
   - Push changes to GitHub
   - Jenkins automatically triggers the pipeline
   - Access Jenkins at: `http://localhost:8080`  Change this to your Jenkins server URL Currnrtly it is running on local machine using Oracle VM VirtualBox Port Forwarding

3. **Manual Deployment**:
   ```bash
   ansible-playbook -i inventory.ini deploy.yml
   ```

## Environment URLs

- Development: `http://worker:3001`
- Test: `http://worker:3002`
- Production: `http://worker:3003`

## Monitoring and Logs

- **Container Logs**:
  ```bash
  docker logs dev_env   # Development environment
  docker logs test_env  # Test environment
  docker logs prod_env  # Production environment
  ```

- **Application Status**:
  ```bash
  docker ps  # Check running containers
  ```

## Troubleshooting

1. **Permission Issues**:
   ```bash
   sudo chown -R dev:dev /home/dev/app
   ```

2. **Docker Issues**:
   ```bash
   sudo systemctl restart docker
   docker compose down && docker compose up -d
   ```

3. **Network Issues**:
   ```bash
   nc -zv localhost 3001  # Test port connectivity
   ```

## Security Considerations

- SSH keys for authentication
- Docker security best practices
- Environment-specific configurations
- Secure credential management
- Regular security updates
