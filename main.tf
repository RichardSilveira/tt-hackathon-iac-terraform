# Configuring a remote s3 backend using this module https://registry.terraform.io/modules/nozaq/remote-state-s3-backend/aws/latest
provider "aws" {
  profile = "tt-admin"
  region = "us-east-1"
}

provider "aws" {
  profile = "tt-admin"
  alias  = "replica"
  region = "us-west-1"
}

module "remote_state" {
  source = "nozaq/remote-state-s3-backend/aws"

  providers = {
    aws         = aws
    aws.replica = aws.replica
  }
}

resource "aws_iam_user" "terraform" {
  name = "TerraformUser"
}

resource "aws_iam_user_policy_attachment" "remote_state_access" {
  user       = aws_iam_user.terraform.name
  policy_arn = module.remote_state.terraform_iam_policy.arn
}