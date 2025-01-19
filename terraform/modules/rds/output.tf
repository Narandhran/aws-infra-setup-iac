output "rds_endpoint" {
  description = "Endpoint for RDS"
  value       = aws_db_instance.rds.endpoint
}

output "rds_engine" {
  value = aws_db_instance.rds.engine
}

output "rds_port" {
  value = aws_db_instance.rds.port
}

output "rds_dbname" {
  value = aws_db_instance.rds.db_name
}

output "rds_dbinstance_identifier" {
  value = aws_db_instance.rds.identifier
}

