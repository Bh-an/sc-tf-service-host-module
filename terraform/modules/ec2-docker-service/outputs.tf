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
  value       = var.enable_elastic_ip ? "http://${aws_eip.app[0].public_ip}/api/v1" : null
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
