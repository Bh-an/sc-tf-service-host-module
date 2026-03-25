output "eip_public_ip" {
  description = "Elastic IP address of the EC2 instance"
  value       = module.service.instance_public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = module.service.instance_id
}

output "api_endpoint" {
  description = "Full URL for the API endpoint"
  value       = module.service.api_endpoint
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for EBS encryption"
  value       = module.service.kms_key_arn
}
