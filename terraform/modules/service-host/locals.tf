locals {
  name_prefix     = "${var.platform}-${var.environment}"
  resolved_ami_id = var.ami_ssm_parameter_name != null ? data.aws_ssm_parameter.docker_host_ami[0].value : data.aws_ami.docker_host[0].id
}
