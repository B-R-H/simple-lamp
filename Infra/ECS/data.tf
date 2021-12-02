data "terraform_remote_state" "ECR" {
  backend = "s3"
  config = {
    bucket = "my-tf-test-bucket-testing"
    key    = "global/s3/container-project/ECR/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}