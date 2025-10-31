
terraform {
  backend "s3" {
    bucket           = "terraform-state-eks-flask-app"
    key              = "eks-infrastructure/terraform.tfstate"
    region           = "eu-central-1"
    dynamodb_table   = "terraform-state-lock"
    encrypt          = true
  }
}
