# VPC Outputs
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "The IDs of the public subnets"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "The IDs of the private subnets"
}

output "vpc_cidr" {
  value       = module.vpc.vpc_cidr
  description = "The CIDR block of the VPC"
}

output "private_subnets_cidr" {
  value       = module.vpc.private_subnets_cidr
  description = "The Private Subnets CIDR block of the VPC"
}

# ECS Outputs
output "ecs_cluster_name" {
  value       = module.ecs.ecs_cluster_name
  description = "The name of the ECS cluster"
}

output "ecs_cluster_arn" {
  value       = module.ecs.ecs_cluster_arn
  description = "The ARN of the ECS cluster"
}

output "autoscaling_group_name" {
  value       = module.ecs.autoscaling_group_name
  description = "The name of the ECS Auto Scaling Group"
}


# # RDS Outputs
# output "rds_instance_id" {
#   value       = module.rds.db_instance_id
#   description = "The ID of the RDS instance"
# }

# output "rds_endpoint" {
#   value       = module.rds.db_endpoint
#   description = "The endpoint of the RDS instance"
# }

# output "rds_security_group_id" {
#   value       = module.rds.db_security_group_id
#   description = "The ID of the RDS security group"
# }

# # Redis Outputs
# output "redis_cluster_id" {
#   value       = module.redis.redis_cluster_id
#   description = "The ID of the Redis cluster"
# }

# output "redis_endpoint" {
#   value       = module.redis.redis_endpoint
#   description = "The endpoint of the Redis cluster"
# }

# # ALB Outputs
# output "alb_dns_name" {
#   value       = module.alb.alb_dns_name
#   description = "The DNS name of the Application Load Balancer"
# }

output "alb_security_group_id" {
  value       = module.alb.alb_security_group_id
  description = "The security group ID of the ALB"
}

# # S3 Outputs
# output "s3_bucket_name" {
#   value       = module.s3.bucket_name
#   description = "The name of the S3 bucket"
# }

# output "s3_bucket_arn" {
#   value       = aws_s3_bucket.bucket.arn
#   description = "The ARN of the S3 bucket"
# }

# # ECR Outputs
# output "ecr_repository_name" {
#   value       = module.ecr.repository_name
#   description = "The name of the ECR repository"
# }

# output "ecr_repository_url" {
#   value       = module.ecr.repository_url
#   description = "The URL of the ECR repository"
# }

# # Secrets Manager Outputs
# output "secrets_manager_arn" {
#   value       = module.secrets_manager.secret_arn
#   description = "The ARN of the secret stored in Secrets Manager"
# }

# RabbitMQ
output "rabbitmq_broker_url" {
  value       = module.rabbitmq.rabbitmq_broker_url
  description = "Rabbitmq broker url"
}

output "single_public_subnet_id" {
  value = module.vpc.single_public_subnet_id
}


output "ecs_alert_arn" {
  value = module.ecs.ecs_alert_arn
}

output "alb_target_group1_arn" {
  value = module.ecs.alb_target_group_arn
}
