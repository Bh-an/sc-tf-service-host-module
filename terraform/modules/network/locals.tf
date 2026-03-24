locals {
  # Base tags applied to all resources in the module.
  tags = {
    Platform    = var.platform
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  create_public_subnets = length(var.public_subnet_cidrs) > 0

  public_subnets_map = zipmap(
    slice(var.availability_zones, 0, length(var.public_subnet_cidrs)),
    var.public_subnet_cidrs
  )

  private_subnets_map = zipmap(
    slice(var.availability_zones, 0, length(var.private_subnet_cidrs)),
    var.private_subnet_cidrs
  )

  db_subnets_map = zipmap(
    slice(var.availability_zones, 0, length(var.db_subnet_cidrs)),
    var.db_subnet_cidrs
  )

  nat_gateway_target_map = length(var.public_subnet_cidrs) > 0 && length(var.private_subnet_cidrs) > 0 ? (
    var.single_nat_gateway ? {
      (var.availability_zones[0]) = var.public_subnet_cidrs[0]
    } : local.public_subnets_map
  ) : {}

}
