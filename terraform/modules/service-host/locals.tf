locals {
  default_ingress_rules = var.exposure_kind == "module-public" ? [
    {
      port                     = 80
      description              = "HTTP"
      cidr                     = "0.0.0.0/0"
      source_security_group_id = null
    }
    ] : var.exposure_kind == "private" ? [
    {
      port                     = 80
      description              = "VPC internal access"
      cidr                     = var.vpc_cidr_block
      source_security_group_id = null
    }
  ] : []

  effective_enable_elastic_ip = var.exposure_kind == "module-public" ? var.enable_elastic_ip : false
  effective_ingress_rules     = var.ingress_rules != null ? var.ingress_rules : local.default_ingress_rules
  listener_port               = 80
  name_prefix                 = "${var.platform}-${var.environment}"
  resolved_ami_id             = var.ami_ssm_parameter_name != null ? data.aws_ssm_parameter.docker_host_ami[0].value : data.aws_ami.docker_host[0].id
}
