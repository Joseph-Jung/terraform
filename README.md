# AWS Lambda Hello World - Terraform Project

This project deploys AWS Lambda functions that return "Hello World" using Terraform and Azure Pipelines for CI/CD automation.

## Project Versions

This repository contains two versions of the Lambda deployment:

### Version 1 (v1/) - Initial Implementation
- ✅ **Status**: Completed and deployed
- **Path**: `v1/terraform/`, `v1/lambda/`
- **State**: Local state file
- **Repository**: Not version-controlled
- **Pipeline**: `azure-pipelines.yml` (root)

### Version 2 (v2/) - GitHub Integration
- 🚀 **Status**: Ready for deployment
- **Path**: `v2/terraform/`, `v2/lambda/`
- **State**: AWS S3 backend with DynamoDB locking
- **Repository**: https://github.com/Joseph-Jung/terraform
- **Pipeline**: `v2/azure-pipelines.yml`
- **Features**: GitHub integration, remote state, collaboration-ready

## Quick Start

### For V1 (Local Deployment)
```bash
cd v1/terraform
terraform init
terraform plan
terraform apply
```

### For V2 (GitHub + S3 Backend)
```bash
# 1. Set up S3 backend (see v2/terraform/backend.tf for commands)

# 2. Initialize and deploy
cd v2/terraform
terraform init
terraform plan
terraform apply
```

## Project Structure

```
BabyStep/
├── .claude/
│   ├── instruction/
│   │   ├── requirement_v1.md    # V1 requirements
│   │   └── requirement_v2.md    # V2 requirements
│   ├── plan/
│   │   ├── terraform_lambda_plan_v1.md
│   │   └── terraform_lambda_plan_v2.md
│   └── result/
│       ├── implementation_result_v1.md
│       └── implementation_result_v2.md
├── v1/
│   ├── lambda/src/index.js      # V1 Lambda function
│   └── terraform/               # V1 Terraform config
├── v2/
│   ├── lambda/src/index.js      # V2 Lambda function
│   ├── terraform/               # V2 Terraform config
│   └── azure-pipelines.yml      # V2 pipeline (GitHub)
├── .gitignore
├── azure-pipelines.yml          # V1 pipeline
└── README.md                    # This file
```

## Architecture

Both versions create the following AWS resources:

- **Lambda Function**: Node.js 18.x runtime, returns "Hello World"
- **IAM Role**: Execution role with basic Lambda permissions
- **CloudWatch Log Group**: For Lambda function logs (7-day retention)

## Prerequisites

### Local Development
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with credentials
- AWS account with appropriate permissions

### For V2 - GitHub Integration
- GitHub account
- Repository: https://github.com/Joseph-Jung/terraform
- S3 bucket and DynamoDB table for remote state

### Azure DevOps
- Azure DevOps account
- AWS service connection configured
- Pipeline variables configured

## Configuration

### AWS Credentials

Set up AWS credentials using one of these methods:

**Option 1: AWS CLI Configuration**
```bash
aws configure
```

**Option 2: Environment Variables**
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REGION="us-east-1"
```

**Option 3: Credentials File**
```bash
# ~/.aws/credentials
[default]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
```

### Terraform Variables

Both versions support the following variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | us-east-1 | AWS region for resources |
| `lambda_function_name` | hello-world-lambda[-v2] | Lambda function name |
| `environment` | dev | Environment tag |
| `log_retention_days` | 7 | CloudWatch log retention |

## Deployment

### Version 1 - Local Deployment

1. **Initialize Terraform**:
   ```bash
   cd v1/terraform
   terraform init
   ```

2. **Review the Plan**:
   ```bash
   terraform plan
   ```

3. **Apply the Configuration**:
   ```bash
   terraform apply
   ```

4. **Test the Lambda Function**:
   ```bash
   aws lambda invoke \
     --function-name hello-world-lambda \
     --region us-east-1 \
     response.json

   cat response.json
   ```

### Version 2 - GitHub + Azure Pipeline

1. **Set Up S3 Backend** (one-time setup):
   ```bash
   # See v2/terraform/backend.tf for complete setup commands
   aws s3 mb s3://terraform-state-joseph-jung --region us-east-1
   aws dynamodb create-table --table-name terraform-state-lock ...
   ```

2. **Push to GitHub**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit: Terraform Lambda v2"
   git remote add origin https://github.com/Joseph-Jung/terraform.git
   git push -u origin main
   ```

3. **Configure Azure Pipeline**:
   - Create pipeline in Azure DevOps
   - Select GitHub repository: `Joseph-Jung/terraform`
   - Use existing `v2/azure-pipelines.yml`
   - Set AWS credentials in pipeline variables

4. **Deploy via Pipeline**:
   - Push changes to `develop` branch for validation
   - Merge to `main` branch for deployment
   - Approve deployment in Azure DevOps

## Testing

### V1 Lambda Function
```bash
aws lambda invoke \
  --function-name hello-world-lambda \
  --region us-east-1 \
  response.json

cat response.json
# Expected: {"statusCode":200,"body":"Hello World"}
```

### V2 Lambda Function
```bash
aws lambda invoke \
  --function-name hello-world-lambda-v2 \
  --region us-east-1 \
  response.json

cat response.json
# Expected: {"statusCode":200,"body":"Hello World"}
```

### View CloudWatch Logs
```bash
# V1
aws logs tail /aws/lambda/hello-world-lambda --follow

# V2
aws logs tail /aws/lambda/hello-world-lambda-v2 --follow
```

## Azure Pipeline

### V1 Pipeline (`azure-pipelines.yml`)
- Triggers: Changes to `terraform/`, `lambda/`
- Stages: Validate → Plan → Apply
- Working Directory: `$(System.DefaultWorkingDirectory)/terraform`

### V2 Pipeline (`v2/azure-pipelines.yml`)
- Triggers: Changes to `v2/` directory
- Stages: Validate → Plan → Apply
- Working Directory: `$(System.DefaultWorkingDirectory)/v2/terraform`
- Environment: `production-v2` (requires approval)
- Repository: GitHub integration

## State Management

### V1 - Local State
- Location: `v1/terraform/terraform.tfstate`
- Suitable for: Single developer, learning
- **Warning**: Do not commit to version control

### V2 - Remote State (S3 + DynamoDB)
- S3 Bucket: `terraform-state-joseph-jung`
- State Key: `v2/lambda/hello-world/terraform.tfstate`
- Locking: DynamoDB table `terraform-state-lock`
- Suitable for: Teams, production, GitHub collaboration
- Encrypted and versioned

## Outputs

After deployment, both versions provide:

```bash
terraform output
```

Outputs include:
- `lambda_function_name`: Function name
- `lambda_function_arn`: Function ARN
- `lambda_function_invoke_arn`: Invoke ARN
- `lambda_role_arn`: IAM role ARN
- `cloudwatch_log_group_name`: Log group name
- `lambda_version`: Version identifier (V2 only)

## Cleanup

### Destroy V1 Resources
```bash
cd v1/terraform
terraform destroy
```

### Destroy V2 Resources
```bash
cd v2/terraform
terraform destroy
```

## Troubleshooting

### Terraform Init Fails
- Verify AWS credentials are configured
- Check network connectivity to AWS
- For V2: Verify S3 bucket and DynamoDB table exist

### Lambda Function Not Working
- Check CloudWatch logs for errors
- Verify IAM role permissions
- Test function in AWS Console

### Pipeline Fails
- Verify service connection is active
- Check pipeline variable configuration
- Review pipeline logs for specific errors

### GitHub Push Rejected
- Ensure you have write access to repository
- Check branch protection rules
- Verify remote URL is correct

## Cost Estimation

Within AWS Free Tier:
- **Lambda**: 1M requests/month free
- **CloudWatch Logs**: 5GB ingestion/month free
- **S3 State Storage**: ~$0.01/month
- **DynamoDB Locking**: Free tier sufficient
- **Total**: ~$0-1/month for development/testing

## Security Best Practices

1. ✅ Never commit AWS credentials to repository
2. ✅ Use Azure Pipeline secrets for sensitive variables
3. ✅ Enable S3 encryption for Terraform state (V2)
4. ✅ Apply least privilege IAM policies
5. ✅ Review CloudWatch logs regularly
6. ✅ Enable branch protection on `main` (V2)
7. ✅ Rotate AWS credentials periodically

## Version Comparison

| Feature | V1 | V2 |
|---------|----|----|
| Lambda Runtime | Node.js 18.x | Node.js 18.x |
| Function Name | hello-world-lambda | hello-world-lambda-v2 |
| State Storage | Local | S3 + DynamoDB |
| Version Control | Optional | GitHub |
| Collaboration | Single dev | Team-ready |
| Azure Pipeline | Basic | GitHub-integrated |
| Branch Strategy | None | main/develop |
| State Locking | No | Yes |
| Encryption | No | Yes |
| Best For | Learning, POC | Production, Teams |

## Contributing (V2)

1. Fork the repository
2. Create feature branch: `git checkout -b feature/my-feature`
3. Make changes and commit: `git commit -m "Add feature"`
4. Push to branch: `git push origin feature/my-feature`
5. Create Pull Request
6. Wait for pipeline validation
7. Request review and merge

## Documentation

- **V1 Plan**: `.claude/plan/terraform_lambda_plan_v1.md`
- **V2 Plan**: `.claude/plan/terraform_lambda_plan_v2.md`
- **V1 Results**: `.claude/result/implementation_result_v1.md`
- **V2 Results**: `.claude/result/implementation_result_v2.md`

## Support

For issues or questions:
- Review troubleshooting section
- Check CloudWatch logs
- Review Azure Pipeline logs
- Consult AWS/Terraform documentation

## License

This project is provided as-is for educational purposes.

## References

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform S3 Backend](https://www.terraform.io/docs/language/settings/backends/s3.html)
- [Azure Pipelines Documentation](https://docs.microsoft.com/azure/devops/pipelines/)
- [GitHub Documentation](https://docs.github.com/)

---

**Repository**: https://github.com/Joseph-Jung/terraform
**Last Updated**: October 24, 2025
**Status**: V1 Deployed ✅ | V2 Ready 🚀
