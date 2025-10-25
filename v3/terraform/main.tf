# Terraform Configuration
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "HelloWorldLambda"
      ManagedBy   = "Terraform"
      Environment = var.environment
      Repository  = "https://github.com/Joseph-Jung/terraform"
    }
  }
}
