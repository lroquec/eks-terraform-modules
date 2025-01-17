# EKS Terraform Modules

This repository contains a collection of Terraform modules for deploying and managing Amazon EKS clusters with associated resources and add-ons.

## Repository Structure

```
.
├── modules/
│   ├── eks/                      # Core EKS module
│   ├── eks-addons/              # EKS add-ons module
│   └── eks-users/               # EKS user management module
├── environments/
│   ├── dev/                     # Development environment
│   ├── staging/                 # Staging environment
│   └── prod/                    # Production environment
└── basic-verifications.sh       # Verification script
```

## Modules Overview

### EKS Core Module (`modules/eks`)

This module handles the core EKS cluster infrastructure including:

- EKS cluster creation
- VPC and networking setup
- Node groups configuration
- Security group management

#### Key Features

- Multi-AZ deployment
- Configurable node groups
- Support for SPOT and ON_DEMAND instances
- Built-in logging and monitoring
- Secure networking defaults

#### Usage

```hcl
module "eks" {
  source = "../../modules/eks"

  environment    = "dev"
  cluster_name   = "dev-cluster"
  cluster_version = "1.31"
  vpc_cidr       = "10.0.0.0/16"
  
  instance_types = ["t3.medium"]
  min_size      = 1
  max_size      = 5
  desired_size  = 2
  capacity_type = "SPOT"  # or "ON_DEMAND"

  tags = {
    Environment = "dev"
    Team        = "platform"
  }
}
```

### EKS Add-ons Module (`modules/eks-addons`)

This module manages essential EKS add-ons:

- AWS Load Balancer Controller
- Cluster Autoscaler
- External DNS
- Metrics Server

Each add-on can be enabled/disabled independently and comes with pre-configured IAM roles and policies.

#### Usage

```hcl
module "eks_addons" {
  source = "../../modules/eks-addons"

  cluster_name                       = module.eks.cluster_name
  cluster_endpoint                   = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  oidc_provider_arn                 = module.eks.oidc_provider_arn

  enable_metrics_server            = true
  enable_cluster_autoscaler       = true
  enable_load_balancer_controller = true
  enable_external_dns            = true

  tags = {
    Environment = "dev"
  }
}
```

### EKS Users Module (`modules/eks-users`)

This module handles EKS user access management with three predefined access levels:

1. **Admin Users**: Full cluster access
2. **Developer Users**: Namespace-scoped access with full permissions
3. **ReadOnly Users**: Cluster-wide read-only access

#### Features

- IAM role and group creation
- RBAC configuration
- AWS Auth ConfigMap management
- Integration with EKS OIDC provider

#### Usage

```hcl
module "eks_users" {
  source = "../../modules/eks-users"

  cluster_name = module.eks.cluster_name
  environment  = "dev"

  admin_users     = ["admin1", "admin2"]
  developer_users = ["dev1", "dev2"]
  readonly_users  = ["viewer1"]

  tags = {
    Environment = "dev"
  }
}
```

## Prerequisites

- Terraform >= 1.7.0
- AWS CLI configured with appropriate permissions
- kubectl installed
- AWS Account with required services enabled:
  - EKS
  - EC2
  - VPC
  - IAM
  - Route53 (if using External DNS)

## Required AWS Permissions

The AWS account/role used for deploying these modules needs the following permissions:

- `eks:*`
- `ec2:*`
- `iam:*`
- `route53:*` (if using External DNS)
- `autoscaling:*`
- `elasticloadbalancing:*`

## Environment Variables

```bash
export AWS_REGION=us-east-1  # or your preferred region
export AWS_PROFILE=default   # or your AWS CLI profile
```

## Deployment Instructions

1. Initialize Terraform:
```bash
terraform init
```

2. Review the plan:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

4. Configure kubectl (after deployment):
```bash
aws eks update-kubeconfig --region [region] --name [cluster_name]
```

## State Management

The project uses S3 for state storage. Make sure to configure your backend appropriately:

```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "path/to/your/state"
    region = "us-east-1"
    # Recommended for production
    # dynamodb_table = "terraform-locks"
  }
}
```

## Security Considerations

- All IAM roles follow the principle of least privilege
- Network security groups are configured with minimal required access
- RBAC is properly configured for different user types
- Secrets are managed through AWS Secrets Manager
- Private endpoints are used where possible
- Node groups run in private subnets
- Control plane logging is enabled by default

## Known Limitations

- External DNS requires an existing Route53 hosted zone
- Fargate profiles are not included (but can be added)
- Limited to one node group by default

## Acknowledgments

- Based on official AWS EKS best practices
- Uses official AWS Terraform modules
- Follows HashiCorp best practices for Terraform

## Future Improvements

- [ ] Add multi-node group support
- [ ] Add support for custom CNI configurations
- [ ] Add monitoring stack (Prometheus/Grafana)
- [ ] Add backup solutions
- [ ] Add disaster recovery procedures
