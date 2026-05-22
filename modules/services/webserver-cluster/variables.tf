variable "cluster_name" {
  description = "The name to use for all cluster resources"
  type        = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for database remote state"
  type        = string
}

variable "db_remote_state_key" {
  description = "The path for the database remote state in S3"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instances to run"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of EC2 instances in the ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of EC2 instances in the ASG"
  type        = number
  default     = 10
}

variable "server_port" {
  description = "The port the web server listens on"
  type        = number
  default     = 8080
}