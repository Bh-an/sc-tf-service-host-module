# Packer AMI Pipeline

Bakes a custom Amazon Linux 2023 AMI with Docker and Nginx pre-installed and enabled as systemd services. This AMI is what the Terraform service-host module launches from.

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
| `ami_name_prefix` | `ec2-docker-host` | AMI name prefix (the service-host module filters on this) |
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

## AMI Discovery

The service-host Terraform module finds the AMI using:

```hcl
data "aws_ami" "docker_host" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["ec2-docker-host-*"]
  }
}
```

Alternatively, when `ami_ssm_parameter_name` is set, it reads the pinned AMI ID from SSM Parameter Store instead of doing a latest-AMI lookup.
