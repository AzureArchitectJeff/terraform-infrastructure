# ============================================
# TERRAFORM CONFIGURATION
# ============================================
terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# ============================================
# PROVIDER CONFIGURATION
# ============================================
provider "aws" {
  region = "us-east-2"
}

# ============================================
# LOCALS (Computed values)
# ============================================
locals {
  http_port     = 80
  any_port      = 0
  any_protocol  = "-1"
  tcp_protocol  = "tcp"
  all_ips       = ["0.0.0.0/0"]
}

# ============================================
# DATA SOURCES
# ============================================

# Read database outputs from its state file
data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "us-east-2"
  }
}

# Find the default VPC
data "aws_vpc" "default" {
  default = true
}

# Find subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  }
}

# ============================================
# RESOURCES
# ============================================

# Security group for EC2 instances
resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"

  # Web traffic from anywhere
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = local.all_ips
  }

  # SSH access from specific IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_ip]
  }

  # Allow all outbound traffic
  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }
}

# Security group for load balancer
resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"

  # Allow inbound HTTP requests from anywhere
  ingress {
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  # Allow all outbound requests (for health checks)
  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }
}

# Launch template (modern replacement for launch configuration)
resource "aws_launch_template" "example" {
  name_prefix   = "${var.cluster_name}-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = "terraform-key"

  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.cluster_name
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Load Balancer (ALB)
resource "aws_lb" "example" {
  name               = var.cluster_name
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

# Listener - listens on port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = local.http_port
  protocol          = "HTTP"

  # Default response if no rules match
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

# Target Group
resource "aws_lb_target_group" "asg" {
  name     = var.cluster_name
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener Rule - forwards all traffic to target group
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "example" {
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns   = [aws_lb_target_group.asg.arn]
  health_check_type   = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }
}