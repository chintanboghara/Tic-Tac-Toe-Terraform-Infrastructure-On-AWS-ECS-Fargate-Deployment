# Tic-Tac-Toe Terraform Infrastructure on AWS ECS Fargate Deployment

Deploy the Tic-Tac-Toe application as a Docker container on AWS ECS (Elastic Container Service) using the Fargate launch type, expose it via an Application Load Balancer (ALB), and optionally configure a custom domain with Route 53. The infrastructure will be provisioned entirely with Terraform.

### Key Components
- **AWS ECS Fargate**: Runs the Docker container without managing EC2 instances.
- **Application Load Balancer**: Exposes the application to the internet.
- **Security Groups**: Controls network access to the ECS service and load balancer.
- **Route 53 (optional)**: Maps a custom domain to the load balancer.
- **Terraform State Management**: Uses S3 and DynamoDB for remote state storage and locking.

## Prerequisites

- **AWS Account**: With permissions to create ECS, ALB, and Route 53 resources.
- **AWS CLI**: Configured with credentials (`aws configure`).
- **Terraform**: Installed (version 1.5+ recommended).
- **Docker Image**: The application uses `chintanboghara/tic-tac-toe` from Docker Hub.
- **S3 Bucket and DynamoDB Table**: For state management.

## Resources Created

- **ECS Cluster**: Runs the Tic-Tac-Toe application.
- **ECS Task Definition**: Defines the Docker container configuration.
- **ECS Service**: Manages the running tasks with Fargate.
- **Application Load Balancer**: Exposes the application on port 80.
- **Security Groups**: Controls traffic to the ECS service and load balancer.
- **Route 53 (optional)**: Maps a custom domain to the load balancer.

## Deployment Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/<your-username>/Tic-Tac-Toe-Terraform-Infrastructure-On-AWS-ECS-Fargate-Deployment.git
   cd Tic-Tac-Toe-Terraform-Infrastructure-On-AWS-ECS-Fargate-Deployment
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Review and Apply**
   ```bash
   terraform plan
   terraform apply
   ```

4. **Access the Application**
   After deployment, Terraform outputs the load balancer DNS name:
   ```
   Outputs:
   load_balancer_dns = "tic-tac-toe-lb-<hash>.ap-south-1.elb.amazonaws.com"
   ```
   Open this URL in a browser to play Tic-Tac-Toe.

5. **Cleanup**
   ```bash
   terraform destroy
   ```
