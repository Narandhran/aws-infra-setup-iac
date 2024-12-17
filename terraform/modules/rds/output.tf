output "rds_endpoint" {
  description = "Endpoint for RDS"
  value = aws_db_instance.rds.endpoint
}