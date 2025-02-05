module "eks" {
  source = "../../modules/eks"

  environment     = "dev"
  cluster_name    = "dev-cluster"
  cluster_version = "1.31"

  vpc_cidr = "10.0.0.0/16"
  vpc_subnet_config = {
    subnet1 = {
      cidr_block = "10.0.0.0/20"
      public     = true
    }
    subnet2 = {
      cidr_block = "10.0.16.0/20"
      public     = true
    }
    subnet3 = {
      cidr_block = "10.0.32.0/20"
      public     = false
    }
    subnet4 = {
      cidr_block = "10.0.48.0/20"
      public     = false
    }
  }

  instance_types = ["t3.medium"]
  min_size       = 1
  max_size       = 2
  desired_size   = 1
  capacity_type  = "SPOT" # Using SPOT instances

  tags = {
    Team    = "platform"
    Project = "kubernetes-platform"
  }
}

module "eks_addons" {
  source     = "../../modules/eks-addons"
  aws_region = "us-east-1"

  cluster_name                       = module.eks.cluster_name
  cluster_endpoint                   = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  oidc_provider_arn                  = module.eks.oidc_provider_arn

  enable_metrics_server           = true
  enable_cluster_autoscaler       = true
  enable_load_balancer_controller = true
  enable_external_dns             = true

  tags = {
    Environment = "dev"
    Team        = "platform"
    Project     = "kubernetes-platform"
  }
  depends_on = [module.eks]
}

module "eks_users" {
  source     = "../../modules/eks-users"
  aws_region = "us-east-1"

  cluster_name = module.eks.cluster_name
  environment  = "dev"

  # User configuration
  admin_role     = "eks-admin"
  developer_role = "eks-developer"
  readonly_role  = "eks-viewer"

  admin_users     = var.eks_admin_users
  developer_users = var.eks_developer_users
  readonly_users  = var.eks_readonly_users

  create_admin_users     = var.create_admin_users
  create_developer_users = var.create_developer_users
  create_readonly_users  = var.create_readonly_users

  tags = {
    Environment = "dev"
    Team        = "platform"
    Project     = "kubernetes-platform"
  }
  depends_on = [module.eks]
}