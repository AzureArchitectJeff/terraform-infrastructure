# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
  type        = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
  # No default - user MUST provide this
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
  # No default - user MUST provide this
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
  # No default - user MUST provide this
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "ssh_allowed_ip" {
  description = "The IP address (with CIDR) allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ami_id" {
  description = "The AMI ID to use for EC2 instances"
  type        = string
  default     = "ami-0c7217cdde317cfec"  # Ubuntu 22.04 LTS
}