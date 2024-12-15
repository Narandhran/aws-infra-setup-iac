output "ecs_cluster_name" {
  value       = aws_ecs_cluster.main.name
  description = "The name of the ECS cluster"
}

output "ecs_cluster_arn" {
  value       = aws_ecs_cluster.main.arn
  description = "The ARN of the ECS cluster"
}

output "autoscaling_group_name" {
  value       = aws_autoscaling_group.ecs.name
  description = "The name of the ECS Auto Scaling Group"
}
