terraform {
  backend "s3" {
    bucket     = "backend-bucket-new"
    region     = "us-east-1"
    encrypt    = true
    key        = "BUILD_NUM/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}
