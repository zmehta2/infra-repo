# terraform/modules/node-groups/main.tf

# Use LabRole for node groups (typical in AWS Academy)
data "aws_iam_role" "existing_node_role" {
  name = "LabRole"
}

resource "aws_eks_node_group" "blue" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.environment}-blue"
  node_role_arn   = data.aws_iam_role.existing_node_role.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types
  capacity_type  = "ON_DEMAND"

  labels = {
    environment = var.environment
    deployment  = "blue"
  }

  dynamic "taint" {
    for_each = var.blue_active ? [] : [1]
    content {
      key    = "deployment"
      value  = "inactive"
      effect = "NO_SCHEDULE"
    }
  }
}

resource "aws_eks_node_group" "green" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.environment}-green"
  node_role_arn   = data.aws_iam_role.existing_node_role.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types
  capacity_type  = "ON_DEMAND"

  labels = {
    environment = var.environment
    deployment  = "green"
  }

  dynamic "taint" {
    for_each = var.blue_active ? [1] : []
    content {
      key    = "deployment"
      value  = "inactive"
      effect = "NO_SCHEDULE"
    }
  }
}