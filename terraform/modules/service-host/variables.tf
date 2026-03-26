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
  default     = 20
}

variable "data_volume_size_gib" {
  description = "Data EBS volume size in GiB."
  type        = number
  default     = 10
}

variable "enable_elastic_ip" {
  description = "Whether to allocate and associate an Elastic IP."
  type        = bool
  default     = true
}

variable "ingress_rules" {
  description = "Security group ingress rules for the application instance."
  type = list(object({
    port        = number
    cidr        = string
    description = string
  }))
  default = [
    {
      port        = 80
      cidr        = "0.0.0.0/0"
      description = "HTTP"
    }
  ]
}
