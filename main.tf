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