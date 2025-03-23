# Configure the AWS provider
provider "aws" {
  region = var.region
}

# Terraform backend for remote state management (assumes S3 bucket and DynamoDB table exist)
terraform {
  backend "s3" {
    bucket         = "tic-tac-toe-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tic-tac-toe-terraform-locks"
  }
}

# Data sources for default VPC and subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "tic_tac_toe" {
  name = "tic-tac-toe-cluster"
}

# Local value for container definitions
locals {
  container_definitions = jsonencode([{
    name  = "tic-tac-toe"
    image = "chintanboghara/tic-tac-toe"
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

# ECS Task Definition
resource "aws_ecs_task_definition" "tic_tac_toe" {
  family                   = "tic-tac-toe-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions    = local.container_definitions
}

# Security Group for Load Balancer
resource "aws_security_group" "lb_sg" {
  name        = "tic-tac-toe-lb-sg"
  description = "Security group for Tic-Tac-Toe load balancer"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for ECS Service
resource "aws_security_group" "tic_tac_toe_sg" {
  name        = "tic-tac-toe-sg"
  description = "Security group for Tic-Tac-Toe ECS service"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application Load Balancer
resource "aws_lb" "tic_tac_toe" {
  name               = "tic-tac-toe-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = data.aws_subnets.default.ids
}

# Load Balancer Target Group
resource "aws_lb_target_group" "tic_tac_toe" {
  name        = "tic-tac-toe-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id
}

# Load Balancer Listener
resource "aws_lb_listener" "tic_tac_toe" {
  load_balancer_arn = aws_lb.tic_tac_toe.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tic_tac_toe.arn
  }
}

# ECS Service
resource "aws_ecs_service" "tic_tac_toe" {
  name            = "tic-tac-toe-service"
  cluster         = aws_ecs_cluster.tic_tac_toe.id
  task_definition = aws_ecs_task_definition.tic_tac_toe.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.tic_tac_toe_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tic_tac_toe.arn
    container_name   = "tic-tac-toe"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.tic_tac_toe]
}

# Optional: Route 53 Hosted Zone and Record
# resource "aws_route53_zone" "primary" {
#   name = "example.com"
# }

# resource "aws_route53_record" "tic_tac_toe" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = "tic-tac-toe.example.com"
#   type    = "A"
#   alias {
#     name                   = aws_lb.tic_tac_toe.dns_name
#     zone_id                = aws_lb.tic_tac_toe.zone_id
#     evaluate_target_health = true
#   }
# }