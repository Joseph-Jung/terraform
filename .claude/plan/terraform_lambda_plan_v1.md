# Terraform AWS Lambda Project Plan

## Project Overview
Deploy an AWS Lambda function that returns "Hello World" using Terraform, with deployment automation through Azure Pipeline.

## Architecture Components

### 1. AWS Lambda Function
- **Runtime**: Node.js 18.x
- **Handler**: Returns "Hello World" string
- **Trigger**: Direct invocation (can be extended with API Gateway)
- **IAM Role**: Lambda execution role with basic permissions

### 2. Terraform Infrastructure

#### Required Resources
1. **Lambda Function** (`aws_lambda_function`)
   - Function code (zip file)
   - Runtime: nodejs18.x
   - Handler specification: index.handler
   - IAM role attachment

2. **IAM Role** (`aws_iam_role`)
   - Trust policy for Lambda service
   - Execution policy attachment

3. **IAM Policy Attachment** (`aws_iam_role_policy_attachment`)
   - AWSLambdaBasicExecutionRole

4. **CloudWatch Log Group** (`aws_cloudwatch_log_group`)
   - For Lambda logs
   - Retention policy: 7 days

#### Terraform File Structure
```
BabyStep/
├── .claude/
│   ├── instruction/
│   └── plan/
├── terraform/
│   ├── main.tf              # Main infrastructure configuration
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Output values
│   ├── providers.tf         # Provider configuration
│   └── backend.tf           # State backend configuration
├── lambda/
│   └── src/
│       └── index.js         # Lambda function code (Node.js)
├── azure-pipelines.yml      # Azure Pipeline configuration
├── .gitignore               # Git ignore file
└── README.md                # Project documentation
```

### 3. Azure Pipeline Configuration

#### Pipeline Stages
1. **Install Stage**
   - Install Terraform

2. **Package Stage**
   - Zip Lambda function code

3. **Validate Stage**
   - Terraform init
   - Terraform validate
   - Terraform fmt check

4. **Plan Stage**
   - Terraform plan
   - Display plan output

5. **Apply Stage** (with manual approval)
   - Terraform apply
   - Output Lambda ARN

#### Prerequisites
- Azure DevOps service connection to AWS
- AWS credentials stored as pipeline variables/secrets:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_REGION`

### 4. State Management
- **Backend**: AWS S3 bucket for state storage (optional for initial setup)
- **Locking**: DynamoDB table for state locking (optional)
- **Alternative**: Local state for development, S3 for production

## Implementation Steps

### Phase 1: Create Project Structure
1. Create directory structure
2. Create Lambda function code (Node.js)
3. Create Terraform configuration files
4. Create Azure Pipeline configuration

### Phase 2: Local Testing
1. Test Lambda code locally (optional)
2. Initialize Terraform:
   ```bash
   cd terraform
   terraform init
   terraform validate
   terraform plan
   ```

### Phase 3: Azure Pipeline Setup
1. Push code to Git repository
2. Create pipeline in Azure DevOps
3. Configure AWS service connection
4. Set up pipeline variables for AWS credentials
5. Run pipeline

### Phase 4: Deployment & Verification
1. Trigger pipeline
2. Review plan output
3. Approve and deploy
4. Test Lambda function using AWS CLI or Console

## Variables & Configuration

### Terraform Variables
- `aws_region`: AWS region (default: us-east-1)
- `lambda_function_name`: Name of Lambda function (default: hello-world-lambda)
- `environment`: Environment tag (default: dev)

### Azure Pipeline Variables (Secrets)
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `AWS_REGION`: AWS region (e.g., us-east-1)

## Lambda Function Details

### Handler Function
- **File**: index.js
- **Handler**: index.handler
- **Response**: Returns "Hello World" message

### Response Format
```json
{
  "statusCode": 200,
  "body": "Hello World"
}
```

## Security Considerations
1. Never commit AWS credentials to repository
2. Use Azure Pipeline secrets for sensitive data
3. Apply least privilege IAM policies
4. Enable CloudWatch logging for monitoring
5. Use S3 bucket encryption for state files (if using remote state)

## Cost Estimation
- **Lambda**: Free tier includes 1M requests/month and 400,000 GB-seconds compute time
- **CloudWatch Logs**: Free tier includes 5GB ingestion
- **Estimated Monthly Cost**: $0 (within free tier for low usage)

## Success Criteria
- [x] Plan document created
- [ ] Lambda function code created (Node.js 18.x)
- [ ] Terraform configuration files created
- [ ] Azure Pipeline configuration created
- [ ] Pipeline runs successfully and deploys Lambda
- [ ] Lambda function returns "Hello World" when invoked
- [ ] Infrastructure is reproducible via Terraform

## Testing the Lambda Function

After deployment, test using AWS CLI:
```bash
aws lambda invoke \
  --function-name hello-world-lambda \
  --region us-east-1 \
  response.json

cat response.json
```

## Next Steps
1. ✅ Plan document completed
2. Create Lambda function code (index.js)
3. Create Terraform configuration files
4. Create Azure Pipeline YAML
5. Test locally
6. Push to repository and run pipeline

## References
- [AWS Lambda with Node.js](https://docs.aws.amazon.com/lambda/latest/dg/lambda-nodejs.html)
- [Terraform AWS Lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)
- [Azure Pipelines YAML](https://docs.microsoft.com/azure/devops/pipelines/yaml-schema)

Create a result document after the plan in this document is completed under the .claude/result folder. 