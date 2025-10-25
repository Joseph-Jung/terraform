# Hello World Lambda - Terraform AWS Deployment

A serverless "Hello World" application deployed on AWS Lambda using Terraform, with automated CI/CD via Azure Pipelines.

## Overview

This project demonstrates:
- AWS Lambda function (Node.js 18.x) returning "Hello World"
- Infrastructure as Code using Terraform
- HTTP API Gateway for RESTful access
- Automated deployment via Azure Pipelines
- CloudWatch logging and monitoring

## Architecture

```
GitHub Repository
    ↓
Azure Pipeline (CI/CD)
    ↓
Terraform Deploy
    ↓
AWS Cloud
├── Lambda Function (Node.js 18.x)
├── API Gateway (HTTP API)
├── IAM Roles & Policies
└── CloudWatch Logs
```

## Project Structure

```
v3/
├── terraform/
│   ├── main.tf              # Provider and Terraform configuration
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Output values
│   ├── backend.tf           # Backend configuration (S3/local)
│   ├── lambda.tf            # Lambda function resources
│   ├── iam.tf               # IAM roles and policies
│   └── api_gateway.tf       # API Gateway configuration
├── lambda/
│   ├── src/
│   │   └── index.js         # Lambda function code
│   └── package.json         # Node.js package configuration
├── azure-pipelines.yml      # Azure Pipeline definition
└── README.md                # This file
```

## Prerequisites

### AWS Account
- Active AWS account with appropriate permissions
- IAM user with permissions to create:
  - Lambda functions
  - API Gateway resources
  - IAM roles and policies
  - CloudWatch Log Groups

### Azure DevOps
- Azure DevOps organization and project
- GitHub repository connection
- Variable group named `terraform-aws-credentials` with:
  - `AWS_ACCESS_KEY_ID` (secret)
  - `AWS_SECRET_ACCESS_KEY` (secret)
  - `AWS_REGION` (e.g., us-east-1)

### Local Development
- Terraform >= 1.0
- AWS CLI (optional, for manual operations)
- Node.js 18.x (for local testing)

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/Joseph-Jung/terraform.git
cd terraform/v3
```

### 2. Configure AWS Credentials (Local)

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REGION="us-east-1"
```

### 3. Initialize Terraform

```bash
cd terraform
terraform init
```

### 4. Plan Deployment

```bash
terraform plan
```

### 5. Deploy Infrastructure

```bash
terraform apply
```

### 6. Test the API

After deployment, Terraform will output the API endpoint:

```bash
# Get the API URL from outputs
terraform output api_gateway_invoke_url

# Test the endpoint
curl https://your-api-id.execute-api.us-east-1.amazonaws.com/prod/
```

Expected response:
```json
{
  "message": "Hello World",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "requestId": "abc123..."
}
```

## Azure Pipeline Deployment

### Setting Up Azure Pipeline

1. **Create Variable Group**
   - Navigate to Azure DevOps → Pipelines → Library
   - Create variable group: `terraform-aws-credentials`
   - Add variables:
     - `AWS_ACCESS_KEY_ID` (mark as secret)
     - `AWS_SECRET_ACCESS_KEY` (mark as secret)
     - `AWS_REGION`

2. **Connect GitHub Repository**
   - Navigate to Project Settings → Service connections
   - Add GitHub service connection
   - Authorize Azure Pipelines to access your repository

3. **Create Pipeline**
   - Navigate to Pipelines → Create Pipeline
   - Select GitHub as source
   - Choose repository: `Joseph-Jung/terraform`
   - Use existing Azure Pipelines YAML file: `v3/azure-pipelines.yml`

4. **Create Environment**
   - Navigate to Pipelines → Environments
   - Create environment named `production`
   - Add approval checks (recommended)

### Pipeline Stages

The pipeline consists of 4 stages:

1. **Validate** - Runs on all branches
   - Terraform format check
   - Terraform validation

2. **Plan** - Runs on all branches
   - Terraform init
   - Terraform plan
   - Publish plan as artifact

3. **Apply** - Runs only on `main` branch
   - Requires manual approval (if configured)
   - Applies Terraform changes
   - Publishes outputs

4. **Test** - Runs after Apply
   - Tests API endpoints
   - Validates deployment

### Triggering Deployments

**Automatic Trigger:**
- Push to `main` branch with changes in `v3/**`
- Pull request to `main` branch (validate and plan only)

**Manual Trigger:**
- Navigate to Pipelines → Select pipeline → Run pipeline

## Configuration

### Terraform Variables

Customize deployment by modifying variables in `terraform/variables.tf` or create a `terraform.tfvars` file:

```hcl
# terraform.tfvars
aws_region           = "us-east-1"
environment          = "production"
lambda_function_name = "my-hello-world"
lambda_memory_size   = 256
lambda_timeout       = 30
log_retention_days   = 14
```

### Environment Variables

The Lambda function supports these environment variables (configured in `lambda.tf`):
- `ENVIRONMENT` - Environment name (dev/staging/prod)
- `LOG_LEVEL` - Logging level (DEBUG/INFO/WARN/ERROR)

## API Endpoints

The API Gateway exposes the following endpoints:

- `GET /` - Returns Hello World message
- `GET /hello` - Returns Hello World message
- `POST /` - Returns Hello World message

All endpoints return the same response:
```json
{
  "message": "Hello World",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "requestId": "request-id"
}
```

## Monitoring and Logging

### CloudWatch Logs

Lambda function logs are available in CloudWatch:
```bash
# View log group
aws logs tail /aws/lambda/hello-world-lambda --follow
```

API Gateway logs:
```bash
# View API Gateway logs
aws logs tail /aws/apigateway/hello-world-lambda-api --follow
```

### Metrics

Monitor Lambda metrics in CloudWatch:
- Invocations
- Errors
- Duration
- Throttles

## Terraform Outputs

After deployment, the following outputs are available:

```bash
terraform output
```

Key outputs:
- `api_gateway_invoke_url` - Full API endpoint URL
- `lambda_function_arn` - Lambda function ARN
- `lambda_function_name` - Lambda function name
- `test_curl_command` - Command to test the API

## Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy
```

Or via Azure Pipeline (requires manual approval):
```bash
# Add destroy stage to pipeline or run manually
terraform destroy -auto-approve
```

## Cost Estimation

### AWS Free Tier
- Lambda: 1M requests/month, 400,000 GB-seconds compute time
- API Gateway: 1M API calls/month (HTTP APIs - 12 months)
- CloudWatch: 5GB logs ingestion, 5GB storage

### Expected Monthly Cost (after free tier)
- Lambda: ~$0.20 per 1M requests (128MB memory)
- API Gateway HTTP: ~$1.00 per 1M requests
- CloudWatch Logs: ~$0.50 per GB ingested
- **Total: < $2/month for moderate usage**

## Troubleshooting

### Common Issues

**1. Terraform Init Fails**
```bash
# Clear Terraform cache
rm -rf .terraform
terraform init
```

**2. Lambda Function Not Responding**
- Check CloudWatch logs: `/aws/lambda/hello-world-lambda`
- Verify IAM role permissions
- Check Lambda function configuration

**3. API Gateway 403 Error**
- Verify Lambda permission for API Gateway
- Check API Gateway integration settings

**4. Azure Pipeline Fails**
- Verify AWS credentials in variable group
- Check Terraform version compatibility
- Review pipeline logs for specific errors

### Enable Debug Logging

```bash
# Local Terraform
export TF_LOG=DEBUG
terraform plan

# Lambda function
# Set LOG_LEVEL environment variable to DEBUG in lambda.tf
```

## Security Best Practices

1. **Secrets Management**
   - Never commit AWS credentials to repository
   - Use Azure DevOps secret variables
   - Rotate credentials regularly

2. **IAM Permissions**
   - Use least privilege principle
   - Lambda execution role has minimal permissions
   - Consider using IAM roles instead of access keys

3. **API Security**
   - Consider adding API key authentication
   - Implement rate limiting
   - Enable AWS WAF for production

4. **State File**
   - Enable S3 backend for production (see `backend.tf`)
   - Enable bucket encryption and versioning
   - Restrict access to state bucket

## Future Enhancements

- [ ] Add Lambda function tests
- [ ] Implement API key authentication
- [ ] Add custom domain for API Gateway
- [ ] Multi-environment support (dev/staging/prod)
- [ ] Lambda versioning and aliases
- [ ] Blue-green deployment strategy
- [ ] AWS X-Ray tracing
- [ ] Custom CloudWatch dashboards
- [ ] Automated rollback on errors

## References

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Azure Pipelines Documentation](https://docs.microsoft.com/azure/devops/pipelines/)
- [API Gateway HTTP API](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api.html)

## License

MIT License - See LICENSE file for details

## Support

For issues or questions:
- GitHub Issues: https://github.com/Joseph-Jung/terraform/issues
- Repository: https://github.com/Joseph-Jung/terraform
