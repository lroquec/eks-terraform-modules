variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "admin_role" {
  description = "Name of the admin role to create"
  type        = string
  default     = "eks-admin"
}

variable "developer_role" {
  description = "Name of the developer role to create"
  type        = string
  default     = "eks-developer"
}

variable "readonly_role" {
  description = "Name of the readonly role to create"
  type        = string
  default     = "eks-viewer"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}

variable "create_admin_users" {
  description = "Whether to create admin IAM users"
  type        = bool
  default     = false
}

variable "create_developer_users" {
  description = "Whether to create developer IAM users"
  type        = bool
  default     = false
}

variable "create_readonly_users" {
  description = "Whether to create readonly IAM users"
  type        = bool
  default     = false
}

variable "admin_users" {
  description = "List of admin users to create"
  type        = list(string)
  default     = []
}

variable "developer_users" {
  description = "List of developer users to create"
  type        = list(string)
  default     = []
}

variable "readonly_users" {
  description = "List of readonly users to create"
  type        = list(string)
  default     = []
}