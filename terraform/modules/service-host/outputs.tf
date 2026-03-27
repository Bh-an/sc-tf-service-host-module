output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app.id
}

output "instance_public_ip" {
  description = "Elastic IP address of the EC2 instance when enabled"
  value       = try(aws_eip.app[0].public_ip, null)
}

output "api_endpoint" {
  description = "Full URL for the API endpoint when Elastic IP is enabled"
  value       = local.effective_enable_elastic_ip ? "http://${aws_eip.app[0].public_ip}/api/v1" : null
}

output "exposure_kind" {
  description = "Exposure posture for the service host"
  value       = var.exposure_kind
}

output "has_public_endpoint" {
  description = "Whether the service host has a module-managed public endpoint"
  value       = local.effective_enable_elastic_ip
}

output "listener_port" {
  description = "Public listener port exposed by host Nginx"
  value       = local.listener_port
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for EBS encryption"
  value       = aws_kms_key.ebs.arn
}

output "security_group_id" {
  description = "Security group ID for the service host"
  value       = aws_security_group.app.id
}

output "iam_instance_profile_name" {
  description = "Instance profile attached to the service host"
  value       = aws_iam_instance_profile.app.name
}

output "ami_id" {
  description = "AMI ID used for the service host instance"
  value       = local.resolved_ami_id
}
