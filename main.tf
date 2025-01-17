module "eks_dev" {
  source = "../../modules/eks"

  environment   = "dev"
  cluster_name  = "dev-cluster"
  vpc_cidr      = "10.0.0.0/16"
  
  instance_types = ["t3.medium"]
  capacity_type = "SPOT"
  min_size      = 1
  max_size      = 3
  
  tags = {
    Team    = "platform"
    Project = "kubernetes"
  }
}

module "eks_addons" {
  source = "../../modules/eks-addons"

  cluster_name                       = module.eks_dev.cluster_name
  cluster_endpoint                   = module.eks_dev.cluster_endpoint
  cluster_certificate_authority_data = module.eks_dev.cluster_certificate_authority_data
  oidc_provider_arn                 = module.eks_dev.oidc_provider_arn

  # Enable/Disable Addons
  enable_metrics_server            = true
  enable_cluster_autoscaler       = true
  enable_load_balancer_controller = true
  enable_external_dns            = true

  tags = {
    Environment = "dev"
    Team        = "platform"
  }
}

module "eks_users" {
  source = "../../modules/eks-users"

  cluster_name = module.eks-dev.cluster_name
  environment  = "dev"

  admin_users     = ["admin1", "admin2"]
  developer_users = ["dev1", "dev2"]
  readonly_users  = ["viewer1"]

  tags = {
    Environment = "dev"
    Team        = "platform"
  }
}