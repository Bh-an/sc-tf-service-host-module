locals {
  tags = {
    Platform    = var.platform
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  name_prefix = "${var.platform}-${var.environment}"
}
