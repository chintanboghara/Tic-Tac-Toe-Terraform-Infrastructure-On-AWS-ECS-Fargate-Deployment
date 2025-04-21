# Tic-Tac-Toe on AWS ECS Fargate using Terraform

This repository contains Terraform code to deploy a containerized Tic-Tac-Toe web application (`chintanboghara/tic-tac-toe` from Docker Hub) onto AWS Elastic Container Service (ECS) using the Fargate launch type.

The application is exposed publicly via an Application Load Balancer (ALB). Optionally, you can configure a custom domain using AWS Route 53. The entire infrastructure is provisioned and managed using Terraform.

## Architecture Overview

The infrastructure consists of the following key AWS components managed by Terraform:

1.  **VPC & Networking**: Creates or uses the default VPC, subnets, and necessary routing for internet access.
2.  **ECS Cluster**: A logical grouping for the ECS resources.
3.  **ECS Task Definition**: Defines the Docker container (`chintanboghara/tic-tac-toe`), its resource requirements (CPU/memory), and port mappings. Uses the Fargate launch type, eliminating the need to manage underlying EC2 instances.
4.  **ECS Service**: Manages the lifecycle of the Tic-Tac-Toe application tasks, ensuring the desired number of tasks are running and registering them with the ALB.
5.  **Application Load Balancer (ALB)**: Distributes incoming traffic across the running tasks. Listens on HTTP port 80.
6.  **Target Group**: Groups the ECS tasks, allowing the ALB to perform health checks and route traffic.
7.  **Security Groups**:
    *   One for the ALB, allowing inbound HTTP traffic (port 80) from the internet (0.0.0.0/0).
    *   One for the ECS tasks, allowing inbound traffic *only* from the ALB's security group on the application port (usually 3000 or 80 depending on the container).
8.  **IAM Roles**: Necessary permissions for ECS tasks and the ECS service to interact with other AWS services (like ECR, CloudWatch Logs, ELB).
9.  **CloudWatch Log Group**: Collects logs from the running container.
10. **Route 53 Record (Optional)**: If enabled, creates an A record (alias) pointing your custom domain to the ALB.
11. **S3 Bucket & DynamoDB Table (for Terraform State)**: You need to create these *manually* beforehand for secure, remote state management and locking.

## Prerequisites

*   **AWS Account**: An active AWS account with permissions to create the resources listed above (IAM, VPC, EC2/ELB, ECS, Route 53, S3, DynamoDB, CloudWatch).
*   **AWS CLI**: Installed and configured with your AWS credentials (`aws configure`). [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
*   **Terraform**: Version 1.5+ installed. [Installation Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
*   **Docker Image**: The application uses the public `chintanboghara/tic-tac-toe` image from Docker Hub. No Docker installation is needed locally for deployment.
*   **S3 Bucket**: An S3 bucket in your desired AWS region to store the Terraform state file. Versioning should be enabled on this bucket for safety.
*   **DynamoDB Table**: A DynamoDB table in the same region with a primary key named `LockID` (Type: String). This is used for state locking to prevent concurrent modifications.
*   **(Optional) Route 53 Hosted Zone**: If you want to use a custom domain, you need a registered domain name and a corresponding public hosted zone configured in AWS Route 53.

## Configuration

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/chintanboghara/Tic-Tac-Toe-Terraform-Infrastructure-On-AWS-ECS-Fargate-Deployment.git
    cd Tic-Tac-Toe-Terraform-Infrastructure-On-AWS-ECS-Fargate-Deployment
    ```

2.  **Configure Terraform Backend**:
    *   Open the `backend.tf` file (or create one if it doesn't exist, often this configuration is in `main.tf` or a dedicated `provider.tf`).
    *   Update the `bucket` and `dynamodb_table` arguments with the names of the S3 bucket and DynamoDB table you created in the prerequisites.
    *   Ensure the `region` matches where you created the bucket and table.

    Example `backend.tf`:
    ```terraform
    terraform {
      backend "s3" {
        bucket         = "your-terraform-state-bucket-name" # Replace with your bucket name
        key            = "ecs/tic-tac-toe/terraform.tfstate" # Path within the bucket for the state file
        region         = "ap-south-1"                      # Replace with your desired AWS region
        dynamodb_table = "your-terraform-lock-table-name" # Replace with your DynamoDB table name
        encrypt        = true
      }
    }
    ```

3.  **Configure Variables**:
    *   Rename `terraform.tfvars.example` to `terraform.tfvars`.
    *   Edit `terraform.tfvars` and provide values for the variables:
        *   `aws_region`: The AWS region where you want to deploy the infrastructure (e.g., `"ap-south-1"`). This should match your backend region.
        *   `environment`: A name for the environment (e.g., `"dev"`, `"staging"`, `"prod"`). Used for naming resources.
        *   `project_name`: A name for the project (e.g., `"tic-tac-toe"`). Used for naming resources.
        *   **(Optional) `enable_route53`**: Set to `true` to enable custom domain mapping. Defaults to `false`.
        *   **(Optional) `domain_name`**: If `enable_route53` is `true`, provide your custom domain name (e.g., `"tictactoe.example.com"`).
        *   **(Optional) `zone_name`**: If `enable_route53` is `true`, provide the name of your Route 53 hosted zone (e.g., `"example.com."` - note the trailing dot).

## Deployment Steps

1.  **Initialize Terraform**:
    Navigate to the repository's root directory in your terminal and run:
    ```bash
    terraform init
    ```
    This command initializes the Terraform working directory, downloads necessary provider plugins (like the AWS provider), and configures the backend based on your `backend.tf` file.

2.  **Plan**:
    Review the infrastructure changes Terraform proposes:
    ```bash
    terraform plan -out=tfplan
    ```
    This command creates an execution plan, showing you exactly which resources Terraform will create, modify, or destroy. Carefully review this output before proceeding. The `-out=tfplan` saves the plan to a file.

3.  **Apply**:
    Provision the resources on AWS:
    ```bash
    terraform apply tfplan
    ```
    Terraform will execute the actions defined in the plan file. It might ask for confirmation if you run `terraform apply` without a plan file. Type `yes` to confirm. This process can take a few minutes as AWS resources are created and configured.

## Accessing the Application

Once the `terraform apply` command completes successfully, it will display the outputs defined in `outputs.tf`.

*   **Load Balancer URL**: Look for the `load_balancer_dns` output.
    ```
    Outputs:

    load_balancer_dns = "tic-tac-toe-lb-<some-hash>.<aws-region>.elb.amazonaws.com"
    ```
    Open this DNS name in your web browser. You should see the Tic-Tac-Toe application.

*   **Custom Domain (if enabled)**: If you set `enable_route53 = true`, you should also be able to access the application via the `domain_name` you configured (e.g., `http://tictactoe.example.com`). Note that DNS propagation can sometimes take a few minutes.

## Cleanup

To remove all the infrastructure created by this Terraform configuration, run:

```bash
terraform destroy
```

Terraform will ask for confirmation before destroying the resources. Type `yes` to proceed.

**Important**:
*   This command will destroy *all* resources defined in the configuration (ECS Service, ALB, Security Groups, etc.).
*   It will **not** delete the Terraform state file from your S3 bucket or the lock table entry from DynamoDB.
*   It will **not** delete the S3 bucket or DynamoDB table themselves. These must be cleaned up manually if desired.
*   Ensure no critical resources depend on the components being destroyed.

## Terraform State Management

This project is configured to use an S3 backend with DynamoDB for locking. This is crucial for:
*   **Collaboration**: Allows multiple team members to work on the same infrastructure.
*   **Consistency**: Prevents state corruption from concurrent `apply` operations using the DynamoDB lock table.
*   **Durability**: Stores the state file safely and durably in S3, decoupled from your local machine.
