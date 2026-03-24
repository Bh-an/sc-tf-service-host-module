resource "aws_kms_key" "ebs" {
  description             = "KMS key for EBS volume encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${local.name_prefix}-ebs-kms-key"
  }
}

resource "aws_kms_alias" "ebs" {
  name          = "alias/${local.name_prefix}-ebs-key"
  target_key_id = aws_kms_key.ebs.key_id
}
