data "aws_caller_identity" "current" {}
locals {
  admin_role_name     = "${var.cluster_name}-admin-role"
  developer_role_name = "${var.cluster_name}-developer-role"
  readonly_role_name  = "${var.cluster_name}-readonly-role"
}

# Admin Role and Group
resource "aws_iam_role" "admin_role" {
  count = length(var.admin_users) > 0 ? 1 : 0
  name  = local.admin_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "admin_policy" {
  count = length(var.admin_users) > 0 ? 1 : 0
  name  = "${local.admin_role_name}-policy"
  role  = aws_iam_role.admin_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:*",
          "iam:ListRoles",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group" "admin_group" {
  count = length(var.admin_users) > 0 ? 1 : 0
  name  = "${var.cluster_name}-admin-group"
  path  = "/"
}

resource "aws_iam_group_policy" "admin_group_policy" {
  count = length(var.admin_users) > 0 ? 1 : 0
  name  = "${var.cluster_name}-admin-group-policy"
  group = aws_iam_group.admin_group[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Resource = aws_iam_role.admin_role[0].arn
      }
    ]
  })
}

# Developer Role and Group
resource "aws_iam_role" "developer_role" {
  count = length(var.developer_users) > 0 ? 1 : 0
  name  = local.developer_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "developer_policy" {
  count = length(var.developer_users) > 0 ? 1 : 0
  name  = "${local.developer_role_name}-policy"
  role  = aws_iam_role.developer_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:AccessKubernetesApi",
          "iam:ListRoles",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group" "developer_group" {
  count = length(var.developer_users) > 0 ? 1 : 0
  name  = "${var.cluster_name}-developer-group"
  path  = "/"
}

resource "aws_iam_group_policy" "developer_group_policy" {
  count = length(var.developer_users) > 0 ? 1 : 0
  name  = "${var.cluster_name}-developer-group-policy"
  group = aws_iam_group.developer_group[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Resource = aws_iam_role.developer_role[0].arn
      }
    ]
  })
}

# Readonly Role and Group
resource "aws_iam_role" "readonly_role" {
  count = length(var.readonly_users) > 0 ? 1 : 0
  name  = local.readonly_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "readonly_policy" {
  count = length(var.readonly_users) > 0 ? 1 : 0
  name  = "${local.readonly_role_name}-policy"
  role  = aws_iam_role.readonly_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:AccessKubernetesApi",
          "iam:ListRoles",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group" "readonly_group" {
  count = length(var.readonly_users) > 0 ? 1 : 0
  name  = "${var.cluster_name}-readonly-group"
  path  = "/"
}

resource "aws_iam_group_policy" "readonly_group_policy" {
  count = length(var.readonly_users) > 0 ? 1 : 0
  name  = "${var.cluster_name}-readonly-group-policy"
  group = aws_iam_group.readonly_group[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Resource = aws_iam_role.readonly_role[0].arn
      }
    ]
  })
}

# Kubernetes RBAC Configuration
resource "kubernetes_cluster_role_binding" "admin_users" {
  count = length(var.admin_users) > 0 ? 1 : 0

  metadata {
    name = "eks-admin-group"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "Group"
    name      = "eks-admin-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_role_binding" "developer_users" {
  count = length(var.developer_users) > 0 ? 1 : 0

  metadata {
    name      = "eks-developer-group"
    namespace = var.environment
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.developer[0].metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "eks-developer-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role" "developer" {
  count = length(var.developer_users) > 0 ? 1 : 0

  metadata {
    name = "${var.cluster_name}-developer"
  }

  rule {
    api_groups = ["", "apps", "batch", "extensions"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_cluster_role_binding" "readonly_users" {
  count = length(var.readonly_users) > 0 ? 1 : 0

  metadata {
    name = "eks-readonly-group"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }

  subject {
    kind      = "Group"
    name      = "eks-readonly-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

# AWS Auth ConfigMap
resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(
      concat(
        length(var.admin_users) > 0 ? [
          {
            rolearn  = aws_iam_role.admin_role[0].arn
            username = "admin:{{SessionName}}"
            groups   = ["system:masters"]
          }
        ] : [],
        length(var.developer_users) > 0 ? [
          {
            rolearn  = aws_iam_role.developer_role[0].arn
            username = "developer:{{SessionName}}"
            groups   = ["eks-developer-group"]
          }
        ] : [],
        length(var.readonly_users) > 0 ? [
          {
            rolearn  = aws_iam_role.readonly_role[0].arn
            username = "readonly:{{SessionName}}"
            groups   = ["eks-readonly-group"]
          }
        ] : []
      )
    )
  }
}
