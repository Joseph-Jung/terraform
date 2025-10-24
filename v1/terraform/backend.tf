# Terraform Backend Configuration
# By default, uses local backend for development
# Uncomment and configure for remote state storage in production

# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "lambda/hello-world/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }

# To create the required S3 bucket and DynamoDB table, run:
#
# aws s3 mb s3://your-terraform-state-bucket --region us-east-1
# aws s3api put-bucket-versioning \
#   --bucket your-terraform-state-bucket \
#   --versioning-configuration Status=Enabled
#
# aws dynamodb create-table \
#   --table-name terraform-state-lock \
#   --attribute-definitions AttributeName=LockID,AttributeType=S \
#   --key-schema AttributeName=LockID,KeyType=HASH \
#   --billing-mode PAY_PER_REQUEST \
#   --region us-east-1
