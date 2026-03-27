# Service Host Module

Deploys a single EC2 instance running a Dockerized application behind host-level Nginx. Handles IAM, KMS, EBS encryption, security groups, Elastic IP, and the bootstrap user data script.

## Resources Created

| Resource | Purpose |
|----------|---------|
| `aws_iam_role` + `aws_iam_instance_profile` | EC2 assume-role with `AmazonSSMManagedInstanceCore` |
| `aws_kms_key` + `aws_kms_alias` | Customer-managed key for EBS encryption (rotation enabled) |
| `aws_security_group` | Dynamic ingress from `ingress_rules`, all-outbound egress |
| `aws_instance` | EC2 host (Packer AMI, IMDSv2 required, two encrypted GP3 volumes) |
| `aws_ebs_volume` + `aws_volume_attachment` | Dedicated data volume at `/dev/xvdf` |
| `aws_eip` + `aws_eip_association` | Optional Elastic IP (enabled by default) |

## AMI Resolution

The module resolves its AMI in priority order:

1. **SSM parameter** — if `ami_ssm_parameter_name` is set, read the AMI ID from Parameter Store
2. **Latest matching** — `data "aws_ami"` filtered by `ami_name_prefix` + owner `self`

## Inputs

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `platform` | `string` | — | Platform name for naming/tagging |
| `environment` | `string` | — | Environment name |
| `vpc_id` | `string` | — | VPC to deploy into |
| `subnet_id` | `string` | — | Subnet for the instance |
| `availability_zone` | `string` | — | AZ for the data volume |
| `instance_type` | `string` | `t3.micro` | EC2 instance type |
| `key_pair_name` | `string` | `null` | Optional SSH key pair |
| `docker_image` | `string` | — | Container image to deploy |
| `ami_name_prefix` | `string` | `ec2-docker-host` | AMI name filter |
| `ami_ssm_parameter_name` | `string` | `null` | SSM-backed AMI ID |
| `root_volume_size_gib` | `number` | `30` | Root EBS size |
| `data_volume_size_gib` | `number` | `10` | Data EBS size |
| `enable_elastic_ip` | `bool` | `true` | Allocate an EIP |
| `ingress_rules` | `list(object)` | `[{port:80, cidr:"0.0.0.0/0"}]` | SG ingress rules |

## Outputs

| Output | Description |
|--------|-------------|
| `instance_id` | EC2 instance ID |
| `instance_public_ip` | Elastic IP (or `null`) |
| `api_endpoint` | `http://<EIP>/api/v1` (or `null`) |
| `kms_key_arn` | KMS key ARN |
| `security_group_id` | Security group ID |
| `iam_instance_profile_name` | Instance profile name |
| `ami_id` | Resolved AMI ID |

## Bootstrap Script

The user data template (`files/user_data.sh.tpl`) runs on first boot:

1. Discovers and formats the secondary EBS volume, mounts to `/data`
2. Writes Nginx config from Terraform-rendered templates
3. Creates Docker bridge network `ec2-net` at `172.30.0.0/24`
4. Pulls and runs the container at `172.30.0.10`
5. Polls `http://172.30.0.10:8081/health` until healthy
6. Validates and restarts Nginx
7. Verifies direct Nginx health at `http://localhost:80/_nginx/health`
8. Verifies the app health path at `http://localhost:80/health`

Public Nginx behavior is strict:

- `/_nginx/health` is a direct Nginx-only health endpoint
- `/health`, `/api/v1`, and `/version` proxy to the container
- all other paths return `404`
