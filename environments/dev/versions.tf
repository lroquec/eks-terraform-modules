terraform {
  required_version = ">= 1.7.0"
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "dev/eks/terraform.tfstate"
    region = "us-east-1"
    # Recomendado para entornos de producción
    # dynamodb_table = "terraform-locks"
  }
}