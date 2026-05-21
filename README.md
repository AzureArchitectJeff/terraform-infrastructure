# 🏗️ Production Terraform Infrastructure

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-EC2%20%7C%20RDS%20%7C%20ALB%20%7C%20S3-FF9900?logo=amazonaws)](https://aws.amazon.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 Overview

This project demonstrates **production-ready AWS infrastructure** using Terraform with proper **state isolation** and **component separation**.

### What's Deployed

| Component | Description |
|-----------|-------------|
| **Global S3 Backend** | Remote state storage with DynamoDB locking |
| **RDS MySQL Database** | Managed database in staging environment |
| **Web Server Cluster** | Auto Scaling Group + ALB + EC2 instances |

## 🏗️ Architecture Diagram

flowchart TD
    A[Internet] --> B[ALB :80]
    B --> C[Auto Scaling Group]
    C --> D[EC2 Instances]
    D --> E[RDS MySQL]
    E --> F[S3 + DynamoDB]

## 🏆 Skills Demonstrated

| Skill | Implementation |
|-------|----------------|
| **State Isolation** | Separate state files per environment/component |
| **Remote State** | S3 backend with DynamoDB locking |
| **Cross-Component Communication** | `terraform_remote_state` data source |
| **Secrets Management** | Environment variables for sensitive data |
| **High Availability** | Multi-AZ deployment, Auto Scaling |
| **Load Balancing** | Application Load Balancer with health checks |

## 📁 Project Structure
terraform-project/
├── global/
│ └── s3/ # Shared state storage (run FIRST)
│ └── main.tf # S3 bucket + DynamoDB
│
├── stage/
│ ├── data-stores/
│ │ └── mysql/ # Database component (run SECOND)
│ │ ├── main.tf # RDS instance
│ │ ├── outputs.tf # DB address & port
│ │ └── variables.tf # Credentials (sensitive)
│ │
│ └── services/
│ └── webserver-cluster/ # Web app (run THIRD)
│ ├── main.tf # ALB + ASG + EC2
│ └── user-data.sh # EC2 bootstrap script
│
└── prod/ # Production (same structure, separate state)
├── data-stores/
│ └── mysql/
└── services/
└── webserver-cluster/

text

## 🚀 Quick Start

### Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.5
- SSH key pair named `terraform-key` in AWS EC2

### 1. Set Database Credentials

```bash
export TF_VAR_db_username="your_username"
export TF_VAR_db_password="your_strong_password"
2. Deploy State Storage (Run Once)

bash
cd global/s3
terraform init
terraform apply
3. Deploy Database

bash
cd ../../stage/data-stores/mysql
terraform init
terraform apply
4. Deploy Web Server Cluster

bash
cd ../../services/webserver-cluster
terraform init
terraform apply
5. Get the Load Balancer URL

bash
terraform output alb_dns_name
Open in browser to see:

"Hello, World"
Database address and port
