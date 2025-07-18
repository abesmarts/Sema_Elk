terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.23.1"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "ubuntu" {
  name = "ubuntu:22.04"
}

resource "docker_container" "ansible_vm1" {
  name  = "ansible-vm1"
  image = docker_image.ubuntu.image_id
  
  # Keep container running
  command = ["tail", "-f", "/dev/null"]
  
  # Enable SSH access
  ports {
    internal = 22
    external = 2222
  }
  
  # Environment variables
  env = [
    "DEBIAN_FRONTEND=noninteractive"
  ]
  
  # Add labels for log collection
  labels {
    label = "filebeat_ingest"
    value = "true"
  }
  
  # Mount volumes for shared data
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }
  
  # Network configuration
  networks_advanced {
    name = "semaphore_network"
  }
  
  # Auto-remove when stopped
  rm = false
  
  # Restart policy
  restart = "unless-stopped"
}

# Create Docker network
resource "docker_network" "semaphore_network" {
  name = "semaphore_network"
}
