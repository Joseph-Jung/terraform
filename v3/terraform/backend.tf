# Terraform Backend Configuration
#
# IMPORTANT: Uncomment and configure this block after creating the S3 bucket and DynamoDB table
#
# Prerequisites:
# 1. Create an S3 bucket for state storage
# 2. Create a DynamoDB table for state locking (primary key: LockID)
# 3. Update the values below with your bucket name, key, and region
#
# Example AWS CLI commands to create prerequisites:
#   aws s3api create-bucket --bucket <your-bucket-name> --region <your-region>
#   aws s3api put-bucket-versioning --bucket <your-bucket-name> --versioning-configuration Status=Enabled
#   aws s3api put-bucket-encryption --bucket <your-bucket-name> --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
#   aws dynamodb create-table --table-name terraform-state-lock --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST

# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "v3/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-state-lock"
#     encrypt        = true
#   }
# }

# Alternative: Use local backend for development/testing
# No configuration needed - state will be stored in terraform.tfstate file locally
