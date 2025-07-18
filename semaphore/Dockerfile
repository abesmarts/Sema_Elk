FROM semaphoreui/semaphore:v2.15.0 

# Switch to root to install things 
USER root

# Install required packages
RUN apk add --no-cache curl
RUN apk add --no-cache opentofu --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing/

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/kubectl

# Create log directory for Semaphore
RUN mkdir -p /var/log/semaphore && \
    chown semaphore:semaphore /var/log/semaphore

# Switch back to semaphore user
USER semaphore
