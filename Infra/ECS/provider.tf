terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "my-tf-test-bucket-testing"
    key    = "global/s3/container-project/ECS/terraform.tfstate"
    region = "eu-west-2"

    dynamodb_table = "terraform-up-and-runing-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}
