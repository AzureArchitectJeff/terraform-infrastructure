# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
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
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "db_name" {
  description = "The name to use for the database"
  type        = string
  default     = "exampledb"  # Matches your hardcoded value
}

# Optional: Database port (if you want to customize)
variable "db_port" {
  description = "The port the database listens on"
  type        = number
  default     = 3306  # Default MySQL port
}

# Optional: Allocated storage
variable "allocated_storage" {
  description = "The allocated storage size in GB"
  type        = number
  default     = 20  # Matches your configuration
}

# Optional: Instance class
variable "instance_class" {
  description = "The instance class for the database"
  type        = string
  default     = "db.t3.micro"  # Matches your configuration
}