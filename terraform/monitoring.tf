# # Ensure 'monitoring' namespace exists
# resource "kubernetes_namespace" "monitoring" {
#   metadata {
#     name = "monitoring"
#   }
# }
#
# resource "helm_release" "prometheus" {
#   name       = "prometheus"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "prometheus"
#   version    = "15.0.0"
#
#   namespace = kubernetes_namespace.monitoring.metadata[0].name
#
#   values = [
#     <<EOF
# server:
#   service:
#     type: LoadBalancer
# alertmanager:
#   enabled: true
# EOF
#   ]
# }
#
# resource "helm_release" "grafana" {
#   name       = "grafana"
#   repository = "https://grafana.github.io/helm-charts"
#   chart      = "grafana"
#   version    = "6.17.4"
#
#   namespace = kubernetes_namespace.monitoring.metadata[0].name
#
#   values = [
#     <<EOF
# podSecurityPolicy:
#   enabled: false
#
# service:
#   type: LoadBalancer
#
# adminUser: admin
# adminPassword: admin123
# EOF
#   ]
# }