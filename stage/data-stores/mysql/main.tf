terraform {
  backend "s3" {
    bucket         = "aws-cloud-networks-storage"
    key            = "stage/data-stores/mysql/terraform.tfstate"
    region         = "us-east-2"
    use_lockfile   = true
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}


resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-up-and-running"
  engine            = "mysql"
  engine_version    = "8.0"
  allocated_storage = 20
  instance_class    = "db.t3.micro"
  db_name           = "exampledb"
  username          = var.db_username
  password          = var.db_password
  skip_final_snapshot = true
  backup_retention_period = 0
  publicly_accessible = false
  storage_encrypted   = false

  tags = {
    Name = "terraform-example"
  }
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.example.dns_name
}
