terraform {
  required_version = ">= 1.7.0"
  backend "s3" {
    bucket = "lroquec-tf"
    key    = "dev/eks/terraform.tfstate"
    region = "us-east-1"
    # For DynamoDB locking in production environments
    # dynamodb_table = "terraform-locks"
  }
}