# terraform/environments/dev/main.tf

module "vpc" {
  source = "../../modules/vpc"

  cluster_name       = var.cluster_name
  vpc_cidr          = var.vpc_cidr
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

module "eks" {
  source = "../../modules/eks"

  cluster_name        = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids
  public_access_cidrs = ["0.0.0.0/0"]
}

module "node_groups" {
  source = "../../modules/node-groups"

  cluster_name       = module.eks.cluster_name
  environment        = var.environment
  private_subnet_ids = module.vpc.private_subnet_ids
  instance_types     = ["t3.medium"]
  min_size          = 2
  max_size          = 4
  desired_size      = 2
  blue_active       = true
}

module "argocd" {
  source = "../../modules/argocd"

  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_ca_certificate
}