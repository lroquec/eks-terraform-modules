variable "eks_admin_users" {
  description = "List of admin users for EKS cluster"
  type        = list(string)
  default     = []
}

variable "eks_developer_users" {
  description = "List of developer users for EKS cluster"
  type        = list(string)
  default     = []
}

variable "eks_readonly_users" {
  description = "List of readonly users for EKS cluster"
  type        = list(string)
  default     = []
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