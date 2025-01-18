data "aws_caller_identity" "current" {}

locals {
  admin_role_name     = "${var.cluster_name}-admin-role"
  developer_role_name = "${var.cluster_name}-developer-role"
  readonly_role_name  = "${var.cluster_name}-readonly-role"
}

# Resource: k8s namespace
resource "kubernetes_namespace_v1" "k8s_dev" {
  metadata {
    name = "dev"
  }
}

# Admin Role and Group
resource "aws_iam_role" "admin_role" {
  name = var.admin_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "admin_policy" {
  name  = "${local.admin_role_name}-policy"
  role  = aws_iam_role.admin_role.id

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
  name  = "${var.cluster_name}-admin-group"
  path  = "/"
}

resource "aws_iam_group_policy" "admin_group_policy" {
  name  = "${var.cluster_name}-admin-group-policy"
  group = aws_iam_group.admin_group.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Resource = aws_iam_role.admin_role.arn
      }
    ]
  })
}

# Developer Role and Group
resource "aws_iam_role" "developer_role" {
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
  name  = "${local.developer_role_name}-policy"
  role  = aws_iam_role.developer_role.id

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
  name  = "${var.cluster_name}-developer-group"
  path  = "/"
}

resource "aws_iam_group_policy" "developer_group_policy" {
  name  = "${var.cluster_name}-developer-group-policy"
  group = aws_iam_group.developer_group.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Resource = aws_iam_role.developer_role.arn
      }
    ]
  })
}

# Readonly Role and Group
resource "aws_iam_role" "readonly_role" {
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
  name  = "${local.readonly_role_name}-policy"
  role  = aws_iam_role.readonly_role.id

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
  name  = "${var.cluster_name}-readonly-group"
  path  = "/"
}

resource "aws_iam_group_policy" "readonly_group_policy" {
  name  = "${var.cluster_name}-readonly-group-policy"
  group = aws_iam_group.readonly_group.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Resource = aws_iam_role.readonly_role.arn
      }
    ]
  })
}

# Kubernetes RBAC Configuration
resource "kubernetes_cluster_role_binding" "admin_users" {

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

resource "kubernetes_cluster_role" "developer" {

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

resource "kubernetes_role_binding" "developer_users" {

  metadata {
    name      = "eks-developer-group"
    namespace = var.environment
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.developer.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "eks-developer-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role_binding" "readonly_users" {

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

# Get cluster information for version validation
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

# Get list of nodegroups
data "aws_eks_node_groups" "all" {
  cluster_name = var.cluster_name
}

# Get the first nodegroup
data "aws_eks_node_group" "main" {
  cluster_name    = var.cluster_name
  node_group_name = tolist(data.aws_eks_node_groups.all.names)[0]
}

# AWS Auth ConfigMap Management
locals {
  first_nodegroup_role_arn = data.aws_eks_node_group.main.node_role_arn

  aws_auth_configmap_data = {
    mapRoles = yamlencode(
      concat(
        [
          {
            rolearn  = local.first_nodegroup_role_arn
            username = "system:node:{{EC2PrivateDNSName}}"
            groups   = ["system:bootstrappers", "system:nodes"]
          },
          {
            rolearn  = aws_iam_role.admin_role.arn
            username = "admin:{{SessionName}}"
            groups   = ["system:masters"]
          },
          {
            rolearn  = aws_iam_role.developer_role.arn
            username = "developer:{{SessionName}}"
            groups   = ["eks-developer-group"]
          },
          {
            rolearn  = aws_iam_role.readonly_role.arn
            username = "readonly:{{SessionName}}"
            groups   = ["eks-readonly-group"]
          }
        ]
      )
    )
  }
}

resource "null_resource" "update_aws_auth" {
  depends_on = [
    aws_iam_role.admin_role,
    aws_iam_role.developer_role,
    aws_iam_role.readonly_role,
    kubernetes_cluster_role_binding.admin_users,
    kubernetes_role_binding.developer_users,
    kubernetes_cluster_role_binding.readonly_users
  ]

  triggers = {
    auth_map = local.aws_auth_configmap_data.mapRoles
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig --name ${data.aws_eks_cluster.this.name} --region ${var.aws_region}
      kubectl patch configmap/aws-auth -n kube-system --patch '${jsonencode({
        data = {
          mapRoles = local.aws_auth_configmap_data.mapRoles
        }
      })}'
    EOT
  }
}

# Create admin users
resource "aws_iam_user" "admin_users" {
  for_each = var.create_admin_users ? toset(var.admin_users) : []
  name     = each.value
  tags     = var.tags
}

resource "aws_iam_user_group_membership" "admin_users" {
  for_each = var.create_admin_users ? toset(var.admin_users) : []
  user     = aws_iam_user.admin_users[each.value].name
  groups   = [aws_iam_group.admin_group.name]
}

# Create developer users
resource "aws_iam_user" "developer_users" {
  for_each = var.create_developer_users ? toset(var.developer_users) : []
  name     = each.value
  tags     = var.tags
}

resource "aws_iam_user_group_membership" "developer_users" {
  for_each = var.create_developer_users ? toset(var.developer_users) : []
  user     = aws_iam_user.developer_users[each.value].name
  groups   = [aws_iam_group.developer_group.name]
}

# Create readonly users
resource "aws_iam_user" "readonly_users" {
  for_each = var.create_readonly_users ? toset(var.readonly_users) : []
  name     = each.value
  tags     = var.tags
}

resource "aws_iam_user_group_membership" "readonly_users" {
  for_each = var.create_readonly_users ? toset(var.readonly_users) : []
  user     = aws_iam_user.readonly_users[each.value].name
  groups   = [aws_iam_group.readonly_group.name]
}