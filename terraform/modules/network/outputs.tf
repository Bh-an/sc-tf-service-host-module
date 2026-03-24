# -----------------------------------------------------------------------------
# VPC Outputs
# -----------------------------------------------------------------------------
output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "The ARN of the created VPC."
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "availability_zones" {
  description = "List of Availability Zones used in this VPC."
  value       = var.availability_zones
}

# -----------------------------------------------------------------------------
# Subnet Outputs (Lists & Maps)
# -----------------------------------------------------------------------------

# Public
output "public_subnet_ids" {
  description = "List of IDs for the public subnets."
  value       = [for s in aws_subnet.public : s.id]
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks for the public subnets."
  value       = [for s in aws_subnet.public : s.cidr_block]
}

output "public_subnets_map" {
  description = "Map of AZ to Public Subnet ID (e.g., 'us-east-1a' = 'subnet-123')."
  value       = { for k, v in aws_subnet.public : k => v.id }
}

# Private
output "private_subnet_ids" {
  description = "List of IDs for the private subnets."
  value       = [for s in aws_subnet.private : s.id]
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks for the private subnets. Useful for Security Group rules."
  value       = [for s in aws_subnet.private : s.cidr_block]
}

output "private_subnets_map" {
  description = "Map of AZ to Private Subnet ID."
  value       = { for k, v in aws_subnet.private : k => v.id }
}

# DB
output "db_subnet_ids" {
  description = "List of IDs for the db subnets."
  value       = [for s in aws_subnet.db : s.id]
}

output "db_subnet_cidrs" {
  description = "List of CIDR blocks for the DB subnets."
  value       = [for s in aws_subnet.db : s.cidr_block]
}

output "db_subnets_map" {
  description = "Map of AZ to DB Subnet ID."
  value       = { for k, v in aws_subnet.db : k => v.id }
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group."
  value       = try(aws_db_subnet_group.this[0].name, null)
}

# -----------------------------------------------------------------------------
# Gateway & Routing Outputs
# -----------------------------------------------------------------------------

output "nat_gateway_public_ips" {
  description = "List of public IP addresses allocated to the NAT Gateways."
  value       = [for e in aws_eip.nat : e.public_ip]
}

output "public_route_table_id" {
  description = "The ID of the public route table. Useful for adding peering routes."
  value       = try(aws_route_table.public[0].id, null)
}

output "private_route_table_ids" {
  description = "Map of AZ to Private Route Table IDs. Useful for VPC Endpoints."
  value       = { for k, v in aws_route_table.private : k => v.id }
}

output "db_route_table_id" {
  description = "The ID of the isolated DB route table."
  value       = aws_route_table.db.id
}