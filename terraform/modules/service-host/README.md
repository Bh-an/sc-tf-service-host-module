# Service Host Module

Reusable Terraform module that deploys a single EC2 host running a Dockerized application behind host-level Nginx. This is the Terraform-side equivalent of the CDK service-host model.

## Context

- parent repo: [README.md](../../../README.md)
- paired network module: [../network/README.md](../network/README.md)
- main consumer: [`sc-ec2-go-service/infra/terraform`](https://github.com/Bh-an/sc-ec2-go-service/tree/main/infra/terraform)

## Prerequisites

- Terraform
- an image reference for `docker_image`
- either a baked AMI or an SSM-published AMI parameter

## Resources Created

| Resource | Purpose |
|----------|---------|
| `aws_iam_role` + `aws_iam_instance_profile` | EC2 assume-role with `AmazonSSMManagedInstanceCore` |
| `aws_kms_key` + `aws_kms_alias` | EBS encryption key (only when `kms_key_arn` is not provided) |
| `aws_security_group` | Dynamic ingress plus all-outbound egress |
| `aws_instance` | EC2 host |
| `aws_ebs_volume` + `aws_volume_attachment` | Dedicated data volume at `/dev/xvdf` |
| `aws_eip` + `aws_eip_association` | Optional EIP for `module-public` |

## AMI Resolution

> [!NOTE]
> The SSM path is preferred for real deployments because it pins a tested AMI ID rather than always picking the newest build.

The module resolves its AMI in priority order:

1. SSM parameter
2. latest matching AMI by `ami_name_prefix`

## Inputs

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `platform` | `string` | — | Platform name |
| `environment` | `string` | — | Environment name |
| `vpc_id` | `string` | — | VPC to deploy into |
| `vpc_cidr_block` | `string` | `null` | Required for `private` exposure defaults |
| `subnet_id` | `string` | — | Subnet for the instance |
| `availability_zone` | `string` | — | AZ for the data volume |
| `instance_type` | `string` | `t3.micro` | EC2 instance type |
| `key_pair_name` | `string` | `null` | Optional SSH key pair |
| `kms_key_arn` | `string` | `null` | Optional caller-provided KMS key ARN for EBS encryption |
| `docker_image` | `string` | — | Container image to deploy |
| `ami_name_prefix` | `string` | `ec2-docker-host` | AMI name filter |
| `ami_ssm_parameter_name` | `string` | `null` | SSM-backed AMI ID |
| `root_volume_size_gib` | `number` | `30` | Root EBS size |
| `data_volume_size_gib` | `number` | `10` | Data EBS size |
| `exposure_kind` | `string` | `module-public` | `module-public`, `private`, or `caller-managed` |
| `enable_elastic_ip` | `bool` | `true` | Allocate an EIP for `module-public` |
| `ingress_rules` | `list(object)` | `null` | Explicit ingress rules using either `cidr` or `source_security_group_id` |

## Outputs

| Output | Description |
|--------|-------------|
| `instance_id` | EC2 instance ID |
| `instance_public_ip` | Elastic IP or `null` |
| `api_endpoint` | `http://<EIP>/api/v1` or `null` |
| `exposure_kind` | Effective exposure posture |
| `has_public_endpoint` | Whether the module manages a public endpoint |
| `listener_port` | Host Nginx listener port |
| `kms_key_arn` | Effective KMS key ARN (module-created or caller-provided) |
| `security_group_id` | Security group ID |
| `iam_instance_profile_name` | Instance profile name |
| `ami_id` | Resolved AMI ID |

## Exposure Modes

- `module-public` — module-managed EIP and public ingress
- `private` — no EIP and VPC-only ingress default
- `caller-managed` — no EIP and no default ingress

## Bootstrap Script

The first-boot user data script:

1. prepares the data volume
2. writes Nginx config
3. creates the Docker bridge network
4. pulls and runs the container
5. waits for app health
6. validates and restarts Nginx

Public Nginx behavior is strict:

- `/_nginx/health` is Nginx-only
- `/health`, `/api/v1`, and `/version` proxy to the container
- all other paths return `404`

If you pass `kms_key_arn`, the module reuses that key and skips creating its own KMS key and alias. If you leave it unset, the module creates a customer-managed EBS key and schedules it for deletion with a 7-day window on destroy.
