variable "region" {
  description = "AWS region to build the AMI in."
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "Instance type used during the AMI build."
  type        = string
  default     = "t3.micro"
}

variable "ami_name_prefix" {
  description = "Name prefix for the generated AMI."
  type        = string
  default     = "ec2-docker-host"
}

variable "ami_regions" {
  description = "Additional regions to copy the AMI to."
  type        = list(string)
  default     = []
}

variable "ami_ssm_parameter_name" {
  description = "Optional SSM parameter name to update with the approved AMI ID after bake."
  type        = string
  default     = null
}
