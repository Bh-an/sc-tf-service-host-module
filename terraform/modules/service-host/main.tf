data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

locals {
  effective_kms_key_arn = var.kms_key_arn != null ? var.kms_key_arn : aws_kms_key.ebs[0].arn
}

resource "aws_iam_role" "app" {
  name               = "${local.name_prefix}-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json

  tags = {
    Name = "${local.name_prefix}-app-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app" {
  name = "${local.name_prefix}-app-profile"
  role = aws_iam_role.app.name

  tags = {
    Name = "${local.name_prefix}-app-profile"
  }
}

resource "aws_kms_key" "ebs" {
  count                   = var.kms_key_arn == null ? 1 : 0
  description             = "KMS key for EBS volume encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${local.name_prefix}-ebs-kms-key"
  }
}

resource "aws_kms_alias" "ebs" {
  count         = var.kms_key_arn == null ? 1 : 0
  name          = "alias/${local.name_prefix}-ebs-key"
  target_key_id = aws_kms_key.ebs[0].key_id
}

resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "Security group for the platform application instance"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.effective_ingress_rules
    content {
      from_port       = ingress.value.port
      to_port         = ingress.value.port
      protocol        = "tcp"
      cidr_blocks     = ingress.value.cidr != null ? [ingress.value.cidr] : null
      security_groups = ingress.value.source_security_group_id != null ? [ingress.value.source_security_group_id] : null
      description     = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.name_prefix}-app-sg"
  }
}

data "aws_ssm_parameter" "docker_host_ami" {
  count = var.ami_ssm_parameter_name != null ? 1 : 0
  name  = var.ami_ssm_parameter_name
}

data "aws_ami" "docker_host" {
  count       = var.ami_ssm_parameter_name == null ? 1 : 0
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${var.ami_name_prefix}-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "app" {
  ami                    = local.resolved_ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
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
    volume_size = var.root_volume_size_gib
    encrypted   = true
    kms_key_id  = local.effective_kms_key_arn
  }

  tags = {
    Name = "${local.name_prefix}-app"
  }
}

resource "aws_eip" "app" {
  count  = local.effective_enable_elastic_ip ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "${local.name_prefix}-app-eip"
  }
}

resource "aws_eip_association" "app" {
  count         = local.effective_enable_elastic_ip ? 1 : 0
  instance_id   = aws_instance.app.id
  allocation_id = aws_eip.app[0].id
}

resource "aws_ebs_volume" "data" {
  availability_zone = var.availability_zone
  size              = var.data_volume_size_gib
  type              = "gp3"
  encrypted         = true
  kms_key_id        = local.effective_kms_key_arn

  tags = {
    Name = "${local.name_prefix}-data-volume"
  }
}

resource "aws_volume_attachment" "data" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.app.id
}
