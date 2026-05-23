# ============================================
# STAGE MYSQL DATABASE
# ============================================

terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "aws-cloud-networks-storage"
    key            = "stage/data-stores/mysql/terraform.tfstate"
    region         = "us-east-2"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}

# ---------------------------------------------------------------------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
variable "db_username" {
  description = "The username for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

# ---------------------------------------------------------------------------------------------------------------------
# MYSQL DATABASE INSTANCE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-up-and-running"
  engine            = "mysql"
  engine_version    = "8.0"
  allocated_storage = 20        # Stage can be smaller than prod
  instance_class    = "db.t3.micro"
  db_name           = "exampledb_stage"  # Different name from prod
  username          = var.db_username
  password          = var.db_password
  skip_final_snapshot = true
  backup_retention_period = 0    # Stage doesn't need backups
  publicly_accessible = false
  storage_encrypted   = false

  tags = {
    Name        = "terraform-example-stage"
    Environment = "stage"
  }
}
