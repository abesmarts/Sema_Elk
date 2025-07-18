#!/bin/bash
set -e

echo "Setting up Enhanced OpenTofu, Semaphore, Ansible, and ELK Stack"

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

# Check system requirements
check_requirements() {
    print_status "Checking system requirements..."
    
    # Check available memory (ELK stack needs at least 4GB)
    total_mem=$(free -g | awk '/^Mem:/{print $2}')
    if [ $total_mem -lt 4 ]; then
        print_error "Insufficient memory. ELK stack requires at least 4GB RAM."
        print_error "Current available memory: ${total_mem}GB"
        exit 1
    fi
    
    # Check disk space (need at least 10GB free)
    available_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ $available_space -lt 10 ]; then
        print_error "Insufficient disk space. Need at least 10GB free."
        print_error "Current available space: ${available_space}GB"
        exit 1
    fi
    
    print_status "System requirements check passed"
}

# Install Homebrew if not present
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        source ~/.zshrc
    else 
        print_status "Homebrew already installed"
    fi
}

# Update homebrew 
update_homebrew() {
    print_status "Updating Homebrew..."
    brew update
}

# Install required packages
install_packages() {
    print_status "Installing required packages..."
    brew install opentofu ansible kubectl jq git curl wget
    
    # Install docker-compose if not present
    if ! command -v docker-compose &> /dev/null; then
        print_status "Installing Docker Compose..."
        brew install docker-compose
    fi
}

# Check Docker installation
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker Desktop is not installed or not running."
        print_status "Please install Docker Desktop from https://www.docker.com/products/docker-desktop/"
        print_status "After installation, start Docker Desktop and run this script again."
        exit 1
    fi

    # Check if Docker is running 
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Starting Docker Desktop..."
        open -a Docker
        print_status "Please wait for Docker Desktop to start and run this script again."
        exit 1
    fi
}

# Generate SSH keys
generate_ssh_keys() {
    if [ ! -f ~/.ssh/id_rsa ]; then
        print_status "Generating SSH Keys..."
        ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    else 
        print_status "SSH keys already exist"
    fi
}

# Set up vm.max_map_count for Elasticsearch
setup_elasticsearch_requirements() {
    print_status "Setting up Elasticsearch requirements..."
    
    # For macOS, we need to configure Docker Desktop settings
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_warning "On macOS, you may need to increase Docker Desktop memory allocation to at least 4GB"
        print_warning "Go to Docker Desktop > Settings > Resources > Advanced"
    else
        # For Linux
        if [ -w /proc/sys/vm/max_map_count ]; then
            echo 262144 > /proc/sys/vm/max_map_count
            print_status "Set vm.max_map_count to 262144"
        else
            print_warning "Could not set vm.max_map_count. You may need to run: sudo sysctl -w vm.max_map_count=262144"
        fi
    fi
}

# Create project directories
create_directories() {
    print_status "Creating project directories..."
    cd ~/projects/opentofu-semaphore-ansible/
    
    # Create ELK directories
    mkdir -p elk/{elasticsearch,logstash,kibana,filebeat}
    mkdir -p ansible/python_scripts
    
    print_status "Project directories created"
}

# Initialize OpenTofu 
initialize_opentofu() {
    print_status "Initializing OpenTofu..." 
    cd ~/projects/opentofu-semaphore-ansible/opentofu
    tofu init
    cd ..
}

# Start enhanced services
start_services() {
    print_status "Starting enhanced services with ELK Stack..."
    cd ~/projects/opentofu-semaphore-ansible/semaphore
    
    # Stop any existing services
    docker-compose down -v
    
    # Build and start services
    docker-compose build --no-cache
    docker-compose up -d
    
    print_status "Services started. Waiting for initialization..."
    
    # Wait for services to be healthy
    print_status "Waiting for Elasticsearch to be ready..."
    timeout=300
    while ! curl -s http://localhost:9200/_cluster/health | grep -q "green\|yellow"; do
        sleep 10
        timeout=$((timeout - 10))
        if [ $timeout -le 0 ]; then
            print_error "Elasticsearch failed to start within timeout"
            exit 1
        fi
    done
    
    print_status "Waiting for Kibana to be ready..."
    timeout=300
    while ! curl -s http://localhost:5601/api/status | grep -q "available"; do
        sleep 10
        timeout=$((timeout - 10))
        if [ $timeout -le 0 ]; then
            print_error "Kibana failed to start within timeout"
            exit 1
        fi
    done
    
    print_status "All services are ready!"
}

# Initialize MySQL database
initialize_database() {
    print_status "Initializing MySQL database..."
    sleep 30
    docker exec -i semaphore-mysql-1 mysql -u semaphore -psemaphore semaphore < init-mysql.sql 2>/dev/null || true
}

# Verify installations
verify_installations() {
    print_status "Verifying installations..."
    
    echo "=================================="
    echo "Verifying OpenTofu installation..."
    docker-compose exec -T semaphore tofu version || print_warning "OpenTofu verification failed"
    
    echo "Verifying Ansible installation..."
    docker-compose exec -T semaphore ansible --version || print_warning "Ansible verification failed"
    
    echo "Verifying Docker integration..."
    docker-compose exec -T semaphore docker ps || print_warning "Docker integration verification failed"
    
    echo "Verifying ELK Stack..."
    curl -s http://localhost:9200/_cluster/health | jq . || print_warning "Elasticsearch verification failed"
    curl -s http://localhost:5601/api/status | jq . || print_warning "Kibana verification failed"
}

# Main execution
main() {
    print_status "Starting enhanced setup process..."
    
    check_requirements
    install_homebrew
    update_homebrew
    install_packages
    check_docker
    generate_ssh_keys
    setup_elasticsearch_requirements
    create_directories
    initialize_opentofu
    start_services
    initialize_database
    verify_installations
    
    print_status "Enhanced setup completed successfully!"
    
    echo ""
    echo "=========================================="
    echo "Access Information"
    echo "=========================================="
    echo "Semaphore UI: http://localhost:3000"
    echo "Username: admin"
    echo "Password: semaphorepassword"
    echo ""
    echo "Kibana Dashboard: http://localhost:5601"
    echo "Elasticsearch API: http://localhost:9200"
    echo "Logstash API: http://localhost:9600"
    echo ""
    echo "=========================================="
    echo "Next Steps"
    echo "=========================================="
    echo "1. Access Semaphore UI and configure your project"
    echo "2. Add SSH keys to the Key store"
    echo "3. Create inventories and task templates"
    echo "4. Access Kibana to view logs and create dashboards"
    echo "5. Run your first CI/CD pipeline with full logging"
    echo ""
    echo "=========================================="
    echo "Useful Commands"
    echo "=========================================="
    echo "View all container logs: docker-compose logs -f"
    echo "View Semaphore logs: docker-compose logs -f semaphore"
    echo "View ELK stack logs: docker-compose logs -f elasticsearch logstash kibana"
    echo "Access Elasticsearch: curl http://localhost:9200"
    echo "Query logs: curl 'http://localhost:9200/semaphore-logs-*/_search'"
    echo ""
    echo "Python Scripts Directory: ~/projects/opentofu-semaphore-ansible/ansible/python_scripts"
    echo "Deploy Python scripts: ansible-playbook ansible/playbooks/deploy-python.yaml"
}

# Run main function
main "$@"
