data "aws_ami" "docker_host" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["ec2-docker-host-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.docker_host.id
  instance_type          = var.instance_type
  subnet_id              = module.network.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.app.name
  key_name               = var.key_pair_name
  user_data = templatefile("${path.module}/files/user_data.sh.tpl", {
    docker_image   = var.docker_image
    nginx_conf     = file("${path.module}/files/nginx.conf")
    approutes_conf = file("${path.module}/files/approutes.conf")
  })

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
    kms_key_id  = aws_kms_key.ebs.arn
  }

  tags = {
    Name = "${local.name_prefix}-app"
  }
}

resource "aws_eip" "app" {
  domain = "vpc"

  tags = {
    Name = "${local.name_prefix}-app-eip"
  }
}

resource "aws_eip_association" "app" {
  instance_id   = aws_instance.app.id
  allocation_id = aws_eip.app.id
}

resource "aws_ebs_volume" "data" {
  availability_zone = var.availability_zones[0]
  size              = 10
  type              = "gp3"
  encrypted         = true
  kms_key_id        = aws_kms_key.ebs.arn

  tags = {
    Name = "${local.name_prefix}-data-volume"
  }
}

resource "aws_volume_attachment" "data" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.app.id
}
