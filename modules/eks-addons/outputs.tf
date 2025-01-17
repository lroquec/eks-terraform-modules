output "metrics_server_enabled" {
  description = "Whether metrics server is enabled"
  value       = var.enable_metrics_server
}

output "cluster_autoscaler_enabled" {
  description = "Whether cluster autoscaler is enabled"
  value       = var.enable_cluster_autoscaler
}

output "load_balancer_controller_enabled" {
  description = "Whether AWS Load Balancer Controller is enabled"
  value       = var.enable_load_balancer_controller
}

output "external_dns_enabled" {
  description = "Whether External DNS is enabled"
  value       = var.enable_external_dns
}