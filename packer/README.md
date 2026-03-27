# Packer AMI Pipeline

This directory owns the baked AMI path for the Terraform deployment model. Start at the [repo root README](../README.md) for ownership and release context, or use [`sc-ec2-go-service`](https://github.com/Bh-an/sc-ec2-go-service) for the operator workflow that drives this build.

## Context

- parent repo: [README.md](../README.md)
- consuming operator path: [`sc-ec2-go-service`](https://github.com/Bh-an/sc-ec2-go-service)
- AMI consumer: [service-host module README](../terraform/modules/service-host/README.md)

## Prerequisites

- Packer
- AWS CLI with valid credentials

## What Gets Baked

| Package | Install Method | Enabled |
|---------|---------------|---------|
| Docker | `dnf install docker` | `systemd enable + start` |
| Nginx | `dnf install nginx` | `systemd enable` |

The resulting AMI is named `ec2-docker-host-<timestamp>` and owned by the build account.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `region` | `ap-south-1` | AWS region for the build |
| `instance_type` | `t3.micro` | Builder instance type |
| `ami_name_prefix` | `ec2-docker-host` | AMI name prefix |
| `ami_regions` | `[]` | Additional regions to copy the AMI to |
| `ami_ssm_parameter_name` | `null` | Optional SSM parameter to publish the AMI ID to |

## Build

From the service repo (preferred):

```bash
make build-ami ENV=dev
AMI_REGIONS=ap-southeast-1 make build-ami ENV=dev
```

Directly from this repo:

```bash
cd packer
packer init .
packer validate .
packer build .
```

For cross-region replication, copy `replication.pkrvars.hcl.example` to a real `*.pkrvars.hcl` file, set `ami_regions`, and pass it:

```bash
packer build -var-file=replication.pkrvars.hcl .
```
