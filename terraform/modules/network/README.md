# Network Module

Reusable VPC module for the Terraform-side service model. This module is usually consumed through [`sc-ec2-go-service`](https://github.com/Bh-an/sc-ec2-go-service), not directly by assignment operators.

## Context

- parent repo: [README.md](../../../README.md)
- paired service module: [../service-host/README.md](../service-host/README.md)
- main consumer: [`sc-ec2-go-service/infra/terraform`](https://github.com/Bh-an/sc-ec2-go-service/tree/main/infra/terraform)

## Prerequisites

- Terraform
- AWS provider access in the consuming stack

## Resources Created

- VPC with DNS support and hostnames enabled
- public subnets with IGW route
- private subnets with optional NAT route
- DB subnets
- Internet Gateway
- optional NAT Gateway(s)
- route tables for each subnet tier
- optional DB subnet group

## Inputs

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `region` | `string` | Yes | — | AWS region |
| `platform` | `string` | Yes | — | Platform name for naming/tagging |
| `environment` | `string` | Yes | — | Environment name for naming/tagging |
| `vpc_cidr` | `string` | Yes | — | VPC CIDR block |
| `public_subnet_cidrs` | `list(string)` | Yes | — | Public subnet CIDRs |
| `private_subnet_cidrs` | `list(string)` | Yes | — | Private subnet CIDRs |
| `db_subnet_cidrs` | `list(string)` | Yes | — | DB subnet CIDRs |
| `availability_zones` | `list(string)` | Yes | — | AZs to deploy into |
| `single_nat_gateway` | `bool` | Yes | — | `true` for one NAT, `false` for per-AZ |
| `enable_nat_gateways` | `bool` | No | `true` | Whether to create NAT Gateways and private default routes |
| `eks_cluster_name` | `string` | No | `null` | Optional EKS subnet tagging helper |

## Outputs

| Output | Description |
|--------|-------------|
| `vpc_id` | VPC ID |
| `vpc_arn` | VPC ARN |
| `vpc_cidr_block` | VPC CIDR |
| `availability_zones` | AZs used |
| `public_subnet_ids` | Public subnet IDs |
| `private_subnet_ids` | Private subnet IDs |
| `db_subnet_ids` | DB subnet IDs |
| `nat_gateway_public_ips` | NAT Gateway IPs |
| `public_route_table_id` | Public route table ID |
| `private_route_table_ids` | Private route table IDs |
| `db_route_table_id` | DB route table ID |

## Usage Notes

- public-only assignment deployments can set `enable_nat_gateways = false`
- private hosts that need outbound image or package access should keep `enable_nat_gateways = true`
