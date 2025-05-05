# terraform/environments/dev/backend.tf
terraform {
  backend "s3" {
    bucket         = "terraform-state-zinal-devops"  # Use YOUR actual bucket name
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}