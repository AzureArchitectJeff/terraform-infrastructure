# ============================================
# PRODUCTION MYSQL DATABASE
# ============================================

terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Using newer version like yours
    }
  }

  backend "s3" {
    # Production state storage
    bucket         = "aws-cloud-networks-storage"
    key            = "prod/data-stores/mysql/terraform.tfstate"
    region         = "us-east-2"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}

# ---------------------------------------------------------------------------------------------------------------------
# MYSQL DATABASE INSTANCE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_db_instance" "example" {
  # Basic configuration
  identifier_prefix = "terraform-up-and-running"
  engine            = "mysql"
  engine_version    = "8.0"           # Your version (book omitted)
  allocated_storage = 20               # Your: 20, Book: 10
  instance_class    = "db.t3.micro"    # Your: t3.micro, Book: t2.micro
  
  # Database settings
  db_name  = "exampledb"              # Your hardcoded, Book uses var.db_name
  username = var.db_username
  password = var.db_password
  
  # Backup & maintenance
  skip_final_snapshot = true
  backup_retention_period = 0
  
  # Network & security
  publicly_accessible = false
  storage_encrypted   = false
  
  # Tags
  tags = {
    Name = "terraform-example"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "db_address" {
  description = "The address of the database"
  value       = aws_db_instance.example.address
}

output "db_port" {
  description = "The port of the database"
  value       = aws_db_instance.example.port
}