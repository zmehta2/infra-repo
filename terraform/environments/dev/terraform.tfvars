cluster_name       = "eks-dev"
kubernetes_version = "1.27"
vpc_cidr          = "10.0.0.0/16"
region            = "us-east-1"
environment       = "dev"

# Node group configuration
node_groups = {
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
