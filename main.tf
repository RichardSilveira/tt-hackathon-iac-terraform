terraform {
  backend "s3" {
    bucket     = "tf-remote-state20210627105150468000000002"
    key        = "dev/terraform.tfstate"
    region     = "us-east-1"
    encrypt    = true
    kms_key_id = "b5089cd7-bdaa-487b-95e1-1760f94cc400"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.4"
    }
  }
}

provider "aws" {
  profile = "tt-admin"
  region  = "us-east-1"
}

locals {
  tags_shared = {
    Product   = "tt-hackathon"
    Terraform = "true"
  }
}

resource "aws_iam_role" "lambda-task-registration-role" {
  name        = "lambda-task-registration-role"
  description = "Role used by the task-registration serverless microservice"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = ""
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"] # Isn't a good practice, but I'll leave as-is for simplicity
}

resource "aws_dynamodb_table" "task-registration" {
  name           = "TaskRegistration"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "employeeId"
  range_key      = "taskDate"

  attribute {
    name = "employeeId"
    type = "S"
  }

  attribute {
    name = "taskDate"
    type = "S" # Date in dynamo are stored in UTC ISO-8601 strings
  }

  tags = merge(local.tags_shared, { Name = "TaskRegistrationDynamo" })
}
