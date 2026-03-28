variable "platform" {
  description = "Platform name for tagging and naming."
  type        = string
}

variable "environment" {
  description = "Environment name for tagging and naming."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the service will be deployed."
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block used for default private ingress rules."
  type        = string
  default     = null

  validation {
    condition     = var.exposure_kind != "private" || var.vpc_cidr_block != null
    error_message = "vpc_cidr_block must be set when exposure_kind is private."
  }
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be deployed."
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the data volume."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Optional key pair name for emergency SSH access."
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "Optional caller-provided KMS key ARN for EBS encryption. When set, the module reuses this key instead of creating its own."
  type        = string
  default     = null
}

variable "docker_image" {
  description = "Docker image to deploy on the instance."
  type        = string
}

variable "ami_name_prefix" {
  description = "AMI name prefix used to discover the baked host image."
  type        = string
  default     = "ec2-docker-host"
}

variable "ami_ssm_parameter_name" {
  description = "Optional SSM parameter name that stores the approved AMI ID for this service host."
  type        = string
  default     = null
}

variable "root_volume_size_gib" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 30
}

variable "data_volume_size_gib" {
  description = "Data EBS volume size in GiB."
  type        = number
  default     = 10
}

variable "exposure_kind" {
  description = "Exposure posture for the service host: module-public, private, or caller-managed."
  type        = string
  default     = "module-public"

  validation {
    condition     = contains(["module-public", "private", "caller-managed"], var.exposure_kind)
    error_message = "exposure_kind must be one of module-public, private, or caller-managed."
  }
}

variable "enable_elastic_ip" {
  description = "Whether to allocate and associate an Elastic IP for module-public exposure."
  type        = bool
  default     = true
}

variable "ingress_rules" {
  description = "Security group ingress rules for the application instance."
  type = list(object({
    port                     = number
    description              = string
    cidr                     = optional(string)
    source_security_group_id = optional(string)
  }))
  default = null

  validation {
    condition = alltrue([
      for rule in coalesce(var.ingress_rules, []) :
      ((rule.cidr != null ? 1 : 0) + (rule.source_security_group_id != null ? 1 : 0)) == 1
    ])
    error_message = "Each ingress rule must set exactly one of cidr or source_security_group_id."
  }
}
