# Output for ALB Security Group ID
output "alb_security_group_id" {
  value       = aws_security_group.alb_security_group.id
  description = "The ID of the ALB Security Group"
}

# Output for ALB ARN
output "alb_arn" {
  value       = aws_lb.main.arn
  description = "The ARN of the ALB"
}

# Output for ALB DNS Name
output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "The DNS name of the ALB"
}

# Output for ALB Zone ID
output "alb_zone_id" {
  value       = aws_lb.main.zone_id
  description = "The Route 53 Zone ID for the ALB, useful for DNS records"
}
