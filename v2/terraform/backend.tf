# Terraform Backend Configuration for V2
# Configured for remote state storage in AWS S3 with DynamoDB locking
# This is recommended for GitHub collaboration and team environments

terraform {
  backend "s3" {
    bucket         = "terraform-state-joseph-jung"
    key            = "v2/lambda/hello-world/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

# To set up the S3 backend, run these commands first:
#
# 1. Create S3 bucket:
# aws s3 mb s3://terraform-state-joseph-jung --region us-east-1
#
# 2. Enable versioning:
# aws s3api put-bucket-versioning \
#   --bucket terraform-state-joseph-jung \
#   --versioning-configuration Status=Enabled
#
# 3. Enable encryption:
# aws s3api put-bucket-encryption \
#   --bucket terraform-state-joseph-jung \
#   --server-side-encryption-configuration '{
#     "Rules": [{
#       "ApplyServerSideEncryptionByDefault": {
#         "SSEAlgorithm": "AES256"
#       }
#     }]
#   }'
#
# 4. Create DynamoDB table for state locking:
# aws dynamodb create-table \
#   --table-name terraform-state-lock \
#   --attribute-definitions AttributeName=LockID,AttributeType=S \
#   --key-schema AttributeName=LockID,KeyType=HASH \
#   --billing-mode PAY_PER_REQUEST \
#   --region us-east-1
#
# 5. After creating the backend resources, initialize Terraform:
# terraform init
#
# Note: If migrating from local state, Terraform will prompt to copy
# existing state to the new backend location.
