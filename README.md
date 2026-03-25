# sc-terraform-ec2-service-module

`sc-terraform-ec2-service-module` is the Terraform-side infrastructure repo for the assignment-aligned EC2 service model.

It owns:

- the Packer AMI pipeline under `packer/`
- reusable Terraform modules under `terraform/modules/`
- a runnable Terraform root stack under `terraform/`

It does not own the application source anymore. The Go application now lives in the sibling service repo at `../ec2-go-service`.

## Repo Layout

```text
packer/                 Baked EC2 host AMI
terraform/              Runnable Terraform root stack
terraform/modules/      Reusable Terraform modules
```

## Current Modules

- `terraform/modules/network`
  - shared VPC and subnet module
- `terraform/modules/ec2-docker-service`
  - EC2 host, EIP, IAM, KMS, EBS, Nginx, and Dockerized app bootstrap

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

- `../ec2-go-service`
  - service-team repo with the Go app plus both Terraform and CDK consumer paths
- `../cdk-ec2-service-module`
  - shared CDK module repo with Go bindings for the same service model

Current release line: `v0.1.0`
