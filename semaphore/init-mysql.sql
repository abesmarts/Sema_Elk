USE semaphore;

CREATE TABLE IF NOT EXISTS tofu_states (
    id INT AUTO_INCREMENT PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL,
    environment VARCHAR(100) DEFAULT 'development',
    state_data LONGTEXT NOT NULL,
    state_hash VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_project_env (project_name, environment),
    INDEX idx_created_at (created_at)
);

CREATE TABLE IF NOT EXISTS ansible_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL,
    playbook VARCHAR(255) NOT NULL,
    environment VARCHAR(100) DEFAULT 'development',
    status ENUM('running','success','failed','cancelled') DEFAULT 'running',
    log_data LONGTEXT,
    execution_time INT DEFAULT 0, 
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    INDEX idx_project_playbook (project_name, playbook),
    INDEX idx_status (status),
    INDEX idx_started_at (started_at)
);

CREATE TABLE IF NOT EXISTS deployments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL,
    deployment_type ENUM('opentofu','ansible','combined') NOT NULL,
    environment VARCHAR(100) DEFAULT 'development', 
    version VARCHAR(50),
    status ENUM('pending','running','success','failed','rolled_back') DEFAULT 'pending',
    metadata JSON,
    created_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_project_type (project_name, deployment_type),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at) 
);


INSERT INTO deployments (project_name, deployment_type, environment, version, status,created_by)
VALUES
    ("opentofu-ansible-integration",'combined','development','1.0.0','pending','system'),
    ("opentofu-ansible-integration",'opentofu','development','1.0.0','pending','system'),
    ("opentofu-ansible-integration",'ansible','development','1.0.0','pending','system');


SHOW TABLES;

