This project integrates OpenTofu, Semaphore, and Ansible using Kubernetes as the cloud provider for OpenTofu

## Prereqs
- 2025 Macbook with Apple Silicon (M4)
- macOS latest version 
- Homebrew installed

## Setup Instructions
1. Clone this Repo
    - git clone
    - cd opentofu-semaphore-ansible
2. Run `./scripts/setup.sh` to install all dependencies 
    - chmod +x scripts/setup.sh
    ./scripts/setup.sh
3. Access Semaphore ui
    - username: admin
    - password: whatever youlike


## Project Structure    
- `opentofu/`: OpenTofu configuration files
- `ansible/`: Ansible playbooks and roles
- `semaphore/`: Semaphore CI/CD configuration
- `scripts/`: Utility scripts for setup and cleanup

## Usage 
1. Create task templates in Semaphore UI using the provided platybooks
2. Configure repositories and inventories 
3. Execute CI/CD pipelines through the semaphore web interface
4. Monitor deployments and configurations via kubectl and Minikube dashboard

## troubleshooting
- ensure docker desktop is running before starting Minikube
- check Minikube status: `minikube status`
- view semaphore logs: `docker compose logs -f semaphore`
- Access Minikube dashboard: `minikube dashboard`