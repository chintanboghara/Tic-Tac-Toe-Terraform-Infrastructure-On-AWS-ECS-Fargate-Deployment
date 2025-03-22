## Project Overview

The goal is to demonstrate how Terraform can manage Docker infrastructure declaratively, covering key Terraform topics such as providers, resources, variables, outputs, and state management, while adhering to IaC best practices like modularity, security, and reproducibility. The project consists of:

- **A Docker Network**: To enable communication between containers.
- **A Docker Volume**: For persistent storage of database data.
- **Docker Images**: Custom-built images for the backend and frontend, and an existing image for the database.
- **Docker Containers**: One each for the database (MySQL), backend (Flask API), and frontend (nginx serving a static page with API proxying).

The application is a minimal web app where:
- The **frontend** serves a static HTML page that fetches a health status from the backend via an API call.
- The **backend** provides a `/health` endpoint that checks connectivity to the database.
- The **database** stores data persistently using a volume.

Terraform manages all these resources, ensuring a reproducible and scalable setup.

---

## Design and Implementation

### Docker Infrastructure
- **Network**: A single Docker network (`app_network`) connects all containers, allowing them to communicate using container names as hostnames.
- **Volume**: A volume (`db_data`) persists MySQL data, mounted at `/var/lib/mysql` in the database container.
- **Images**:
  - **MySQL**: Uses the official `mysql:5.7` image from Docker Hub.
  - **Backend**: A custom image built from a Dockerfile, based on `python:3.8`, running a Flask app.
  - **Frontend**: A custom image built from a Dockerfile, based on `nginx:alpine`, serving static content and proxying API requests.
- **Containers**:
  - **Database (`db`)**: Runs MySQL, configured with environment variables for the root password and database name.
  - **Backend (`backend`)**: Runs the Flask app, connecting to the database using environment variables, listening on port 5000 internally.
  - **Frontend (`frontend`)**: Runs nginx, serving a static page and proxying `/api` requests to the backend, exposed to the host on port 8080.

### Terraform Configuration
Terraform uses the Docker provider to manage these resources. The configuration is split into multiple files for clarity:
- **`main.tf`**: Defines the provider and all resources (network, volume, images, containers).
- **`variables.tf`**: Declares input variables for configuration flexibility.
- **`outputs.tf`**: Specifies outputs, such as the frontend URL.

Key Terraform features demonstrated:
- **Provider Configuration**: Uses the `kreuzwerker/docker` provider with a version constraint.
- **Resource Dependencies**: Implicit dependencies ensure the network is created before containers are attached.
- **Variables**: Parameterize sensitive data (e.g., database password) and configurable settings (e.g., frontend port).
- **Outputs**: Provide the frontend URL for easy access post-deployment.

### Application Code
- **Backend**: A Flask app (`app.py`) exposes a `/health` endpoint, connecting to MySQL using environment variables for credentials and host details.
- **Frontend**: An nginx server with a custom `index.html` that fetches `/api/health` via JavaScript, and an `nginx.conf` that proxies `/api` to `backend:5000`.

### Best Practices
- **Security**: Sensitive data like the database password is stored in a variable marked as `sensitive`, and users are instructed to provide it securely (e.g., via `terraform.tfvars` or environment variables).
- **Reusability**: The configuration uses relative paths and variables, making it portable across environments.
- **State Management**: Local state is used for simplicity, with a note in the README about using remote backends (e.g., S3 or Terraform Cloud) in production.
- **Version Control**: The `.gitignore` excludes Terraform state files and other transient artifacts.
- **Documentation**: The `README.md` provides clear setup and teardown instructions.

---

## GitHub Repository Structure

The repository is structured as follows:

```
docker-terraform/
├── app/
│   ├── backend/
│   │   ├── Dockerfile
│   │   └── app.py
│   └── frontend/
│       ├── Dockerfile
│       ├── index.html
│       └── nginx.conf
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── README.md
└── .gitignore
```

Below are the contents of each file.

### `/app/backend/Dockerfile`
```dockerfile
FROM python:3.8
RUN pip install flask mysql-connector-python
COPY app.py /app/app.py
CMD ["python", "/app/app.py"]
```

### `/app/backend/app.py`
```python
from flask import Flask, jsonify
import mysql.connector
import os

app = Flask(__name__)

@app.route('/health')
def health():
    try:
        conn = mysql.connector.connect(
            host=os.environ['DB_HOST'],
            user=os.environ['DB_USER'],
            password=os.environ['DB_PASSWORD'],
            database=os.environ['DB_NAME']
        )
        conn.close()
        return jsonify(status='healthy')
    except Exception as e:
        return jsonify(status='unhealthy', error=str(e))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### `/app/frontend/Dockerfile`
```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/nginx.conf
```

### `/app/frontend/index.html`
```html
<html>
<body>
<h1>Application</h1>
<p id="status"></p>
<script>
fetch('/api/health')
  .then(response => response.json())
  .then(data => {
    document.getElementById('status').innerText = 'Status: ' + data.status;
  })
  .catch(error => {
    document.getElementById('status').innerText = 'Error: ' + error;
  });
</script>
</body>
</html>
```

### `/app/frontend/nginx.conf`
```nginx
events {}
http {
    server {
        listen 80;
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
        location /api {
            proxy_pass http://backend:5000;
        }
    }
}
```

### `/terraform/main.tf`
```hcl
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.12"
    }
  }
}

provider "docker" {}

resource "docker_network" "app_network" {
  name = "app_network"
}

resource "docker_volume" "db_data" {
  name = "db_data"
}

resource "docker_image" "mysql" {
  name = "mysql:5.7"
}

resource "docker_image" "backend" {
  name = "backend:latest"
  build {
    context = "${path.module}/../app/backend"
  }
}

resource "docker_image" "frontend" {
  name = "frontend:latest"
  build {
    context = "${path.module}/../app/frontend"
  }
}

resource "docker_container" "db" {
  image = docker_image.mysql.name
  name  = "db"
  networks_advanced {
    name = docker_network.app_network.name
  }
  volumes {
    volume_name    = docker_volume.db_data.name
    container_path = "/var/lib/mysql"
  }
  env = [
    "MYSQL_ROOT_PASSWORD=${var.db_password}",
    "MYSQL_DATABASE=${var.db_name}"
  ]
}

resource "docker_container" "backend" {
  image = docker_image.backend.name
  name  = "backend"
  networks_advanced {
    name = docker_network.app_network.name
  }
  env = [
    "DB_HOST=db",
    "DB_USER=${var.db_user}",
    "DB_PASSWORD=${var.db_password}",
    "DB_NAME=${var.db_name}"
  ]
}

resource "docker_container" "frontend" {
  image = docker_image.frontend.name
  name  = "frontend"
  networks_advanced {
    name = docker_network.app_network.name
  }
  ports {
    internal = 80
    external = var.frontend_port
  }
}
```

### `/terraform/variables.tf`
```hcl
variable "db_password" {
  type      = string
  sensitive = true
  description = "Password for the MySQL root user"
}

variable "db_user" {
  type    = string
  default = "root"
  description = "MySQL user"
}

variable "db_name" {
  type    = string
  default = "mydb"
  description = "Name of the MySQL database"
}

variable "frontend_port" {
  type    = number
  default = 8080
  description = "Port on the host to expose the frontend"
}
```

### `/terraform/outputs.tf`
```hcl
output "frontend_url" {
  value       = "http://localhost:${var.frontend_port}"
  description = "URL to access the frontend application"
}
```

### `README.md`
```markdown
# Docker Infrastructure with Terraform

This project demonstrates the use of Terraform to manage Docker infrastructure for a simple web application. The application consists of a frontend (nginx), backend (Flask API), and database (MySQL), all running in Docker containers connected via a network.

## Project Structure
- `/app/backend`: Backend Flask application code and Dockerfile.
- `/app/frontend`: Frontend nginx configuration, static HTML, and Dockerfile.
- `/terraform`: Terraform configuration files (`main.tf`, `variables.tf`, `outputs.tf`).
- `README.md`: Project documentation.
- `.gitignore`: Excludes Terraform state and transient files.

## Prerequisites
- **Docker**: Installed and running on the host machine.
- **Terraform**: Installed (version 0.13 or later recommended).

## Setup Instructions
1. **Clone the Repository**:
   ```sh
   git clone https://github.com/your-username/docker-terraform.git
   cd docker-terraform
   ```
2. **Navigate to Terraform Directory**:
   ```sh
   cd terraform
   ```
3. **Set Sensitive Variables**:
   Create a `terraform.tfvars` file (do not commit it):
   ```hcl
   db_password = "your_secure_password"
   ```
   Alternatively, set it via an environment variable:
   ```sh
   export TF_VAR_db_password="your_secure_password"
   ```
4. **Initialize Terraform**:
   ```sh
   terraform init
   ```
5. **Apply the Configuration**:
   ```sh
   terraform apply
   ```
   Review the plan and type `yes` to proceed. Once applied, Terraform will output the `frontend_url`.
6. **Access the Application**:
   Open your browser to `http://localhost:8080`. The page will display the backend's health status based on its database connection.

## Teardown
To remove all resources:
```sh
terraform destroy
```
Type `yes` to confirm.

## Notes
- **State Management**: This example uses local state (`terraform.tfstate`). In production, use a remote backend (e.g., AWS S3 or Terraform Cloud) for collaboration and security.
- **Security**: The database password is marked as sensitive in Terraform and should be provided securely (e.g., via `terraform.tfvars` or environment variables), not hardcoded.
- **Service Readiness**: The backend may need to retry database connections if the MySQL container isn’t ready. This is simplified here; production apps should implement robust retry logic.
- **Extensibility**: The configuration can be extended with modules, multiple instances, or integration with CI/CD pipelines.

This project showcases Terraform’s ability to manage Docker resources as IaC, adhering to best practices for structure, security, and documentation.
```

### `.gitignore`
```gitignore
# Terraform files
.terraform/
*.tfstate
*.tfstate.*
*.tfvars

# Local build artifacts (optional, minimal in this case)
*.log
```

---

## Detailed Explanation

### Why This Design?
- **Simplicity with Depth**: The project is simple enough to understand yet demonstrates advanced Terraform features like custom image builds and container orchestration.
- **Real-World Relevance**: It mimics a microservices architecture with separate frontend, backend, and database components, a common pattern in modern applications.
- **Docker-Terraform Integration**: Using the Docker provider highlights Terraform’s flexibility beyond traditional cloud providers, a key skill for an IaC expert.

### Key Terraform Topics Covered
- **Providers**: Configures the Docker provider with version pinning for stability.
- **Resources**: Manages networks, volumes, images, and containers, showcasing Terraform’s resource types.
- **Variables**: Uses input variables for flexibility and security, with defaults for convenience.
- **Outputs**: Provides actionable information post-deployment.
- **State**: Discusses local vs. remote state management, a critical topic for production IaC.

### Best Practices Applied
- **Security**: Sensitive data is parameterized and excluded from version control.
- **Modularity**: The configuration is split into logical files, though modules are omitted for simplicity (they’d be appropriate for larger projects).
- **Documentation**: The README ensures users can replicate the setup effortlessly.
- **Reproducibility**: Dockerfiles and Terraform configs ensure consistent builds and deployments.

### Assumptions and Simplifications
- **Local Docker Daemon**: Assumes Terraform runs on a machine with Docker installed, simplifying provider configuration.
- **Minimal App Code**: The focus is on infrastructure, so application logic is basic but functional.
- **No CI/CD**: While a production setup might include GitHub Actions, it’s omitted to keep the scope manageable.