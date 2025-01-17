output "cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for the EKS cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.eks.vpc_id
}

# Roles ARN outputs for user reference
output "admin_role_arn" {
  description = "ARN of the admin IAM role"
  value       = module.eks_users.admin_role_arn
}

output "developer_role_arn" {
  description = "ARN of the developer IAM role"
  value       = module.eks_users.developer_role_arn
}

output "readonly_role_arn" {
  description = "ARN of the readonly IAM role"
  value       = module.eks_users.readonly_role_arn
}