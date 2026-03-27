module "service" {
  source = "./modules/service-host"

  platform               = var.platform
  environment            = var.environment
  vpc_id                 = module.network.vpc_id
  vpc_cidr_block         = var.vpc_cidr
  subnet_id              = module.network.public_subnet_ids[0]
  availability_zone      = var.availability_zones[0]
  instance_type          = var.instance_type
  key_pair_name          = var.key_pair_name
  docker_image           = var.docker_image
  ami_name_prefix        = var.ami_name_prefix
  ami_ssm_parameter_name = var.ami_ssm_parameter_name
  root_volume_size_gib   = var.root_volume_size_gib
  data_volume_size_gib   = var.data_volume_size_gib
  exposure_kind          = var.exposure_kind
  enable_elastic_ip      = var.enable_elastic_ip
  ingress_rules          = var.ingress_rules
}
