output "eip_public_ip" {
  description = "Elastic IP address of the EC2 instance"
  value       = aws_eip.app.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app.id
}

output "api_endpoint" {
  description = "Full URL for the API endpoint"
  value       = "http://${aws_eip.app.public_ip}/api/v1"
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for EBS encryption"
  value       = aws_kms_key.ebs.arn
}
