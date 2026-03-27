# Network Module

Reusable VPC module that creates the full network stack: VPC, subnets (public/private/DB), Internet Gateway, optional NAT Gateway(s), and route tables.

## Resources Created

- VPC with DNS support and hostnames enabled
- Public subnets (one per AZ) with IGW route
- Private subnets (one per AZ) with optional NAT route
- DB subnets (isolated, no internet route)
- Internet Gateway
- NAT Gateway (single or per-AZ, controlled by `single_nat_gateway`, optional via `enable_nat_gateways`)
- Route tables for each subnet tier
- Optional DB subnet group

## Inputs

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `region` | `string` | Yes | — | AWS region |
| `platform` | `string` | Yes | — | Platform name for naming/tagging |
| `environment` | `string` | Yes | — | Environment name for naming/tagging |
| `vpc_cidr` | `string` | Yes | — | VPC CIDR block |
| `public_subnet_cidrs` | `list(string)` | Yes | — | Public subnet CIDRs (one per AZ) |
| `private_subnet_cidrs` | `list(string)` | Yes | — | Private subnet CIDRs (one per AZ) |
| `db_subnet_cidrs` | `list(string)` | Yes | — | DB subnet CIDRs (one per AZ) |
| `availability_zones` | `list(string)` | Yes | — | AZs to deploy into |
| `single_nat_gateway` | `bool` | Yes | — | `true` for one NAT (dev), `false` for per-AZ (prod) |
| `enable_nat_gateways` | `bool` | No | `true` | Whether to create NAT Gateways and private default routes |
| `eks_cluster_name` | `string` | No | `null` | If set, tags subnets for EKS load balancer discovery |

## Outputs

| Output | Description |
|--------|-------------|
| `vpc_id` | VPC ID |
| `vpc_arn` | VPC ARN |
| `vpc_cidr_block` | VPC CIDR |
| `availability_zones` | AZs used |
| `public_subnet_ids` | Public subnet IDs |
| `public_subnet_cidrs` | Public subnet CIDRs |
| `public_subnets_map` | AZ → public subnet ID |
| `private_subnet_ids` | Private subnet IDs |
| `private_subnet_cidrs` | Private subnet CIDRs |
| `private_subnets_map` | AZ → private subnet ID |
| `db_subnet_ids` | DB subnet IDs |
| `db_subnet_cidrs` | DB subnet CIDRs |
| `db_subnets_map` | AZ → DB subnet ID |
| `db_subnet_group_name` | DB subnet group name |
| `nat_gateway_public_ips` | NAT Gateway IPs |
| `public_route_table_id` | Public route table ID |
| `private_route_table_ids` | AZ → private route table ID |
| `db_route_table_id` | DB route table ID |

## Usage Notes

- Public-only assignment deployments can set `enable_nat_gateways = false` to avoid paying for unused NAT infrastructure.
- Private service hosts that need outbound package/image access should keep `enable_nat_gateways = true`.
