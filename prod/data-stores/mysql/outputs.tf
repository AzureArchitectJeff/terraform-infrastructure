output "address" {
  value       = aws_db_instance.example.address
  description = "Connect to the database at this endpoint"
}

output "port" {
  value       = aws_db_instance.example.port
  description = "The port the database is listening on"
}

# Extra output that's sometimes helpful
output "db_name" {
  value       = aws_db_instance.example.db_name
  description = "The name of the database"
}