provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/config")
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.9.0"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    <<EOF
server:
  service:
    type: LoadBalancer
EOF
  ]
}