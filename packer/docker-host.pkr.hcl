packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.0"
    }
  }
}

source "amazon-ebs" "docker_host" {
  region        = var.region
  instance_type = var.instance_type
  ami_name      = "${var.ami_name_prefix}-{{timestamp}}"
  ami_regions   = var.ami_regions

  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  ssh_username = "ec2-user"

  tags = {
    Name      = "${var.ami_name_prefix}-{{timestamp}}"
    Base      = "al2023"
    ManagedBy = "Packer"
  }
}

build {
  sources = ["source.amazon-ebs.docker_host"]

  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y docker nginx",
      "sudo systemctl enable docker",
      "sudo systemctl enable nginx",
      "sudo usermod -aG docker ec2-user"
    ]
  }
}
