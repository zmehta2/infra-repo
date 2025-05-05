# terraform/modules/argocd/variables.tf
variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
  default     = ""
}

variable "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = ""
}