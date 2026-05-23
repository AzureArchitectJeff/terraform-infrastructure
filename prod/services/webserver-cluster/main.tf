# ============================================
# PRODUCTION WEBSERVER CLUSTER
# ============================================

terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Your version (newer)
    }
  }

  backend "s3" {
    # Your production backend
    bucket         = "aws-cloud-networks-storage"
    key            = "prod/services/webserver-cluster/terraform.tfstate"
    region         = "us-east-2"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"  # Your region
}

# ---------------------------------------------------------------------------------------------------------------------
# WEBSERVER CLUSTER MODULE
# ---------------------------------------------------------------------------------------------------------------------
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  # Your hardcoded values
  cluster_name           = "webservers-prod"
  db_remote_state_bucket = "aws-cloud-networks-storage"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"
  instance_type          = "m4.large"
  min_size               = 2
  max_size               = 10
}

# ---------------------------------------------------------------------------------------------------------------------
# AUTO SCALING SCHEDULES (from the book)
# Scale out during business hours (9 AM)
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"  # 9 AM every day

  autoscaling_group_name = module.webserver_cluster.asg_name
}

# Scale in at night (5 PM)
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"  # 5 PM every day

  autoscaling_group_name = module.webserver_cluster.asg_name
}
