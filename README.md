# sc-tf-service-host-module

The Terraform-side infrastructure for the EC2 service model. This is the aligned secondary deployment path — the CDK module is primary, but both paths produce equivalent deployments with the same security posture and runtime model.

This repo owns:

- **Packer AMI pipeline** — bakes Docker and Nginx into Amazon Linux 2023
- **Reusable Terraform modules** — `network` (VPC/subnets) and `service-host` (EC2/KMS/EBS/IAM/SG)
- **Root Terraform stack** — wires the modules together for maintainer validation

It does not own the Go application or the Docker image. Those belong to [`sc-ec2-go-service`](https://github.com/Bh-an/sc-ec2-go-service).

## Directory Layout

```
packer/                          Baked EC2 host AMI (Amazon Linux 2023 + Docker + Nginx)
terraform/                       Root stack (reference/validation)
terraform/modules/network/       VPC, subnets, IGW, NAT, routing
terraform/modules/service-host/  EC2, IAM, KMS, EBS, SG, Nginx, bootstrap user data
scripts/                         AMI publication helpers
```

## Configured Defaults

> **Defaults governance** — these values are load-bearing. If you change a default in code, update this table in the same commit.

| Default | Value | Source |
|---------|-------|--------|
| Instance type | `t3.micro` | `terraform/modules/service-host/variables.tf:29` |
| Root volume | **30 GiB**, GP3, encrypted | `terraform/modules/service-host/variables.tf:58` |
| Data volume | 10 GiB, GP3, encrypted | `terraform/modules/service-host/variables.tf:64` |
| Data volume device | `/dev/xvdf` | `terraform/modules/service-host/main.tf:162` |
| Elastic IP | Enabled | `terraform/modules/service-host/variables.tf:70` |
| KMS key rotation | Enabled | `terraform/modules/service-host/main.tf:38` |
| KMS deletion window | 7 days | `terraform/modules/service-host/main.tf:37` |
| IMDSv2 | Required | `terraform/modules/service-host/main.tf:118` |
| EBS type | GP3 | `terraform/modules/service-host/main.tf:123, 152` |
| Ingress | Port 80 from `0.0.0.0/0` | `terraform/modules/service-host/variables.tf:80-86` |
| Egress | All traffic | `terraform/modules/service-host/main.tf:66-71` |
| AMI name prefix | `ec2-docker-host` | `terraform/modules/service-host/variables.tf:46` |
| AMI SSM parameter | `null` (fallback to latest AMI) | `terraform/modules/service-host/variables.tf:52` |
| Packer region | `ap-south-1` | `packer/variables.pkr.hcl:4` |
| Packer base OS | Amazon Linux 2023, x86_64 | `packer/docker-host.pkr.hcl:18` |
| Packer SSH user | `ec2-user` | `packer/docker-host.pkr.hcl:26` |

> **Note:** Root volume is 30 GiB here vs 20 GiB in the CDK module. This is intentional — the Packer-baked AMI includes pre-installed packages (Docker, Nginx) that consume more root space than the CDK path, which installs them at boot via user data.

## AMI Resolution

The service-host module resolves its AMI in priority order:

1. **SSM parameter** — if `ami_ssm_parameter_name` is set, read the AMI ID from Parameter Store
2. **Latest matching** — fall back to `data "aws_ami"` filtered by `ami_name_prefix` + owner `self`

The SSM path is preferred for production because it pins a tested AMI ID rather than always picking the newest build.

## Validation

```bash
cd packer && packer init . && packer validate .
cd ../terraform && terraform init -backend=false && terraform validate
```

For real deployment, use the operator surface in [`sc-ec2-go-service`](https://github.com/Bh-an/sc-ec2-go-service):

```bash
make build-ami ENV=dev
make deploy-terraform ENV=dev
```

## Related Repos

| Repo | Role |
|------|------|
| [sc-cdk-service-host-module](https://github.com/Bh-an/sc-cdk-service-host-module) | Primary CDK constructs (source of truth for infra design) |
| [sc-cdk-service-host-module-go](https://github.com/Bh-an/sc-cdk-service-host-module-go) | Generated Go CDK bindings |
| [sc-ec2-go-service](https://github.com/Bh-an/sc-ec2-go-service) | Go application + operator surface + both consumer paths |

## Current Release

`v0.3.3`

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
