variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
  default     = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnets_cidr" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
  default     = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

variable "public_subnet_count" {
  description = "Number of public subnets."
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets."
  type        = number
  default     = 2
}

variable "availability_zones" {
  description = "List of availability zones to deploy resources in."
  type        = list(string)
  default     = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  default     = "student-support-cluster"
}

variable "desired_capacity" {
  description = "Desired number of nodes in the EKS node group."
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of nodes in the EKS node group."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of nodes in the EKS node group."
  type        = number
  default     = 3
}
