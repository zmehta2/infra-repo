# terraform/environments/dev/variables.tf
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-dev"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.27"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "node_groups" {
  description = "Node groups configuration"
  type = map(object({
    instance_types = list(string)
    min_size      = number
    max_size      = number
    desired_size  = number
    active        = bool
  }))
  default = {
    blue = {
      instance_types = ["t3.medium"]
      min_size      = 2
      max_size      = 4
      desired_size  = 2
      active        = true
    }
    green = {
      instance_types = ["t3.medium"]
      min_size      = 2
      max_size      = 4
      desired_size  = 2
      active        = false
    }
  }
}