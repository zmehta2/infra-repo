# modules/irsa/main.tf
resource "aws_iam_role" "service_account" {
  name = "${var.cluster_name}-${var.service_name}-sa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.cluster_oidc_issuer_url, "https://", "")}"
      }
      Condition = {
        StringEquals = {
          "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub": "system:serviceaccount:${var.namespace}:${var.service_account_name}"
        }
      }
    }]
  })
}