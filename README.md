# sc-tf-service-host-module

`sc-tf-service-host-module` is the Terraform-side infrastructure repo for the assignment-aligned EC2 service model.

It owns:

- the Packer AMI pipeline under `packer/`
- reusable Terraform modules under `terraform/modules/`
- a runnable Terraform root stack under `terraform/`

It does not own the application source. The Go application lives in the sibling service repo `sc-ec2-go-service` (Bh‑an namespace), which also owns Docker image publishing to GHCR.

For real service bring-up on a fresh machine, start in `https://github.com/Bh-an/sc-ec2-go-service` and use its operator surface:

- `make bootstrap`
- `make validate`
- `make publish-image`
- `make deploy-cdk`
- `make deploy-terraform`
- `make cleanup-cdk`
- `make cleanup-terraform`
- `TESTING.md` for the real AWS-account checklist

## Deployability Contract (Aligned To CDK)

- CDK is the primary deployment path for this service model (`https://github.com/Bh-an/sc-cdk-service-host-module`).
- This Terraform repo maintains an aligned secondary path with the same inputs/outputs and posture.
- The service repo publishes its Docker image to GHCR: `ghcr.io/bh-an/ec2-go-service:<tag>`.
- Terraform consumers should pass that GHCR image reference into the root stack variables.
- Terraform consumers should prefer an SSM Parameter Store AMI ID contract over implicit latest-AMI lookup.
- Current deployability assumption: the GHCR package is public so the EC2 host can pull it during bootstrap without extra registry credentials.

## Repo Layout

```text
packer/                 Baked EC2 host AMI
terraform/              Runnable Terraform root stack
terraform/modules/      Reusable Terraform modules
```

## Current Modules

- `terraform/modules/network`
  - shared VPC and subnet module
- `terraform/modules/service-host`
  - EC2 host, EIP, IAM, KMS, EBS, Nginx, and Dockerized app bootstrap
  - SSM-backed AMI selection with fallback to latest matching baked AMI

## Root Terraform Role

The root stack under `terraform/` is kept as a reference and maintainer validation root for the shared modules. The service repo remains the operator-facing Terraform deploy path.

## Packer AMI Replication

Packer supports cross-region AMI replication through `ami_regions`.

Recommended flow:

1. bake the host AMI in the primary region
2. replicate it to additional regions with `ami_regions`
3. publish the approved regional AMI ID to SSM Parameter Store

Use `packer/replication.pkrvars.hcl.example` as a starting point and `scripts/publish-ami-parameter.sh` to publish the chosen AMI ID to a service-level parameter such as `/sc/ec2-go-service/dev/ami-id`.

## Local Validation

```bash
cd packer
packer init .
packer validate .

cd ../terraform
terraform init -backend=false
terraform validate
```

## Relationship To Other Repos

- `https://github.com/Bh-an/sc-cdk-service-host-module`
  - shared CDK module repo; primary deployment interface (Go bindings available)
- `https://github.com/Bh-an/sc-ec2-go-service`
  - service-team repo with the Go app plus both CDK (primary) and Terraform (secondary) consumer paths

Current release line: `v0.3.0`

Current `dev` branch is preparing the next non-breaking Terraform release: `v0.3.2`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for branch usage, Conventional Commit rules, and required validation commands.
