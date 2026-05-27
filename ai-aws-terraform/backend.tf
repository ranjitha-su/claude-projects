# Remote state backend configuration for S3.
# The S3 bucket must be created manually before running terraform init.
terraform {
  backend "s3" {
    bucket  = "aws-terraform-remote-state-ranjitha-projects-us-west-2"
    key     = "terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}
