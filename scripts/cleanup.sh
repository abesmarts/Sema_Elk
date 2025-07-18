#!/bin/bash
set -e

echo "==== Cleaning up Enhanced OpenTofu, Semaphore, and ELK Stack resources ===="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Stop and remove all containers and volumes
cleanup_containers() {
    print_status "Stopping and removing all containers and volumes..."
    
    cd ~/projects/opentofu-semaphore-ansible/semaphore
    
    # Stop all services
    docker-compose down -v --remove-orphans
    
    # Remove unused volumes
    docker volume prune -f
    
    # Remove unused networks
    docker network prune -f
    
    print_status "Containers and volumes cleaned up"
}

# Clean up OpenTofu resources
cleanup_opentofu() {
    print_status "Destroying OpenTofu resources..."
    cd ~/projects/opentofu-semaphore-ansible/opentofu
    
    if [ -f terraform.tfstate ]; then 
        tofu destroy -auto-approve
    fi
    
    # Clean up state files
    rm -f terraform.tfstate*
    rm -f .terraform.lock.hcl
    rm -rf .terraform/
    
    cd ..
    print_status "OpenTofu resources cleaned up"
}

# Clean up Docker resources
cleanup_docker() {
    print_status "Cleaning up Docker resources..."
    
    # Remove unused images
    docker image prune -a -f
    
    # Remove unused containers
    docker container prune -f
    
    # System cleanup
    docker system prune -a -f --volumes
    
    print_status "Docker resources cleaned up"
}

# Clean up log files
cleanup_logs() {
    print_status "Cleaning up log files..."
    
    # Remove application logs
    sudo rm -rf /var/log/applications/* 2>/dev/null || true
    sudo rm -rf /var/log/semaphore/* 2>/dev/null || true
    
    print_status "Log files cleaned up"
}

# Clean up temporary files
cleanup_temp() {
    print_status "Cleaning up temporary files..."
    
    # Remove ansible temp files
    rm -rf ~/.ansible/tmp/* 2>/dev/null || true
    
    # Remove any generated files
    rm -rf ~/projects/opentofu-semaphore-ansible/ansible/python_scripts/__pycache__ 2>/dev/null || true
    
    print_status "Temporary files cleaned up"
}

# Main cleanup function
main() {
    print_status "Starting comprehensive cleanup..."
    
    cleanup_containers
    cleanup_opentofu
    cleanup_docker
    cleanup_logs
    cleanup_temp
    
    print_status "Cleanup completed successfully!"
    
    echo ""
    echo "=========================================="
    echo "Cleanup Summary"
    echo "=========================================="
    echo "✓ All containers stopped and removed"
    echo "✓ All volumes and networks removed"
    echo "✓ OpenTofu resources destroyed"
    echo "✓ Docker system cleaned"
    echo "✓ Log files removed"
    echo "✓ Temporary files cleaned"
    echo ""
    echo "Your system is now clean and ready for a fresh setup."
}

# Run main function
main "$@"
