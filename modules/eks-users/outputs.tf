output "admin_role_arn" {
  description = "ARN of the admin IAM role"
  value       = length(var.admin_users) > 0 ? aws_iam_role.admin_role[0].arn : null
}

output "developer_role_arn" {
  description = "ARN of the developer IAM role"
  value       = length(var.developer_users) > 0 ? aws_iam_role.developer_role[0].arn : null
}

output "readonly_role_arn" {
  description = "ARN of the readonly IAM role"
  value       = length(var.readonly_users) > 0 ? aws_iam_role.readonly_role[0].arn : null
}