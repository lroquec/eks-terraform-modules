locals {
  public_subnets_cidr  = [for k, v in var.vpc_subnet_config : v.cidr_block if v.public]
  private_subnets_cidr = [for k, v in var.vpc_subnet_config : v.cidr_block if !v.public]
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr
  
  azs                = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets    = local.private_subnets_cidr
  public_subnets     = local.public_subnets_cidr
  
  enable_nat_gateway     = true
  single_nat_gateway     = var.environment != "prod"
  enable_dns_hostnames   = true
  enable_dns_support     = true
  
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
  
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = local.common_tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = var.cluster_name
  cluster_version               = var.cluster_version
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_enabled_log_types = [
    "audit",
    "api",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # Core addons
  cluster_addons = {
    coredns = {}
    kube-proxy = {}
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
    # This costs money and requires more resources
    amazon-cloudwatch-observability = {
      most_recent = true
    }
    # aws-efs-csi-driver = {
    #   most_recent = true
    # }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true
  eks_managed_node_group_defaults = {
    ami_type       = "AL2023_x86_64_STANDARD"
    instance_types = var.instance_types

    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  eks_managed_node_groups = {
    main = {
      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      instance_types = var.instance_types
      capacity_type  = var.capacity_type

      labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }

      tags = local.common_tags
    }
  }

  tags = local.common_tags
}

resource "null_resource" "wait_for_cluster" {
  depends_on = [module.eks]
}

resource "null_resource" "update_desired_size" {
  triggers = {
    desired_size = var.desired_size
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]

    command = <<-EOT
      aws eks update-nodegroup-config \
        --cluster-name ${module.eks.cluster_name} \
        --nodegroup-name ${element(split(":", module.eks.eks_managed_node_groups["main"].node_group_id), 1)} \
        --scaling-config desiredSize=${var.desired_size} \
        --region ${var.region} \
        --profile default
    EOT
  }
}