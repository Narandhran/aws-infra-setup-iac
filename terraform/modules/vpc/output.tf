output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "The IDs of the public subnets"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "The IDs of the private subnets"
}

output "vpc_cidr" {
  value       = aws_vpc.vpc.cidr_block
  description = "The CIDR block of the VPC"
}

output "private_subnets_cidr" {
  value       = aws_subnet.private[*].cidr_block
  description = "The CIDR block of the VPC"
}

output "single_public_subnet_id" {
  value = aws_subnet.public[0].id
}

output "subnet_id_for_daemon_ec2" {
  value = aws_subnet.private[0].id
}
