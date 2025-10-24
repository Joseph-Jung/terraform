# Terraform AWS Lambda Project Plan - Version 2

## Project Overview
Deploy an AWS Lambda function that returns "Hello World" using Terraform, with deployment automation through Azure Pipeline and GitHub repository integration.

## Key Differences from V1

### Version 1 (Completed)
- Project path: `terraform/`
- Repository: Unspecified
- Deployment: Azure Pipeline only

### Version 2 (New Requirements)
- **Project path**: `v2/`
- **Repository**: GitHub - https://github.com/Joseph-Jung/terraform
- **Deployment**: Azure Pipeline integrated with GitHub
- **Lambda Runtime**: Node.js 18.x (same as v1)

## Architecture Components

### 1. AWS Lambda Function
- **Runtime**: Node.js 18.x
- **Handler**: Returns "Hello World" string
- **Trigger**: Direct invocation (can be extended with API Gateway)
- **IAM Role**: Lambda execution role with basic permissions

### 2. Terraform Infrastructure

#### Required Resources (Same as V1)
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
│   │   ├── requirement_v1.md
│   │   └── requirement_v2.md
│   ├── plan/
│   │   ├── terraform_lambda_plan_v1.md
│   │   └── terraform_lambda_plan_v2.md
│   └── result/
│       ├── implementation_result_v1.md
│       └── implementation_result_v2.md
├── v2/                           # NEW: Version 2 project path
│   ├── terraform/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   └── backend.tf
│   ├── lambda/
│   │   └── src/
│   │       └── index.js
│   └── azure-pipelines.yml      # Updated for GitHub
├── .gitignore
├── .github/                      # NEW: GitHub specific configs
│   └── workflows/                # Optional: GitHub Actions (future)
└── README.md
```

### 3. GitHub Repository Integration

#### Repository Details
- **URL**: https://github.com/Joseph-Jung/terraform
- **Purpose**: Version control and source for Azure Pipeline
- **Branch Strategy**:
  - `main`: Production deployments
  - `develop`: Development/testing

#### GitHub Setup Requirements
1. Create repository: `terraform` at https://github.com/Joseph-Jung/terraform
2. Initialize with:
   - README.md
   - .gitignore (for Terraform and AWS)
   - MIT or Apache 2.0 License (optional)

#### Files to Commit
- All v2/ directory contents
- .claude/ documentation
- Root level .gitignore
- Root level README.md

#### Secrets to Configure (GitHub)
- Not needed for Azure Pipeline integration
- Azure Pipeline will handle AWS credentials
- Optional: Set up for GitHub Actions in future

### 4. Azure Pipeline Configuration (Updated for GitHub)

#### GitHub + Azure DevOps Integration
1. **Azure DevOps Project Setup**
   - Create new pipeline
   - Select GitHub as source
   - Authorize Azure Pipelines app on GitHub
   - Select repository: `Joseph-Jung/terraform`
   - Use existing `v2/azure-pipelines.yml`

2. **Service Connection**
   - AWS service connection (same as v1)
   - GitHub service connection (created automatically)

#### Pipeline File Location
- Path: `v2/azure-pipelines.yml`
- Triggers on changes to `v2/` directory only

#### Pipeline Stages
1. **Validate Stage**
   - Terraform init
   - Terraform validate
   - Terraform fmt check

2. **Plan Stage**
   - Terraform plan
   - Publish plan artifact

3. **Apply Stage** (with manual approval)
   - Terraform apply
   - Output Lambda ARN
   - Only on `main` branch

#### Pipeline YAML Updates
```yaml
trigger:
  branches:
    include:
      - main
      - develop
  paths:
    include:
      - v2/terraform/*
      - v2/lambda/*
      - v2/azure-pipelines.yml

variables:
  terraformVersion: '1.6.0'
  workingDirectory: '$(System.DefaultWorkingDirectory)/v2/terraform'
```

### 5. State Management

#### Option 1: Local State (Development)
- Default configuration
- State file: `v2/terraform/terraform.tfstate`
- **NOT recommended** for GitHub (add to .gitignore)

#### Option 2: S3 Backend (Recommended for GitHub)
- Remote state storage in AWS S3
- State locking with DynamoDB
- Prevents conflicts in collaborative environment
- Configuration in `v2/terraform/backend.tf`

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-joseph-jung"
    key            = "v2/lambda/hello-world/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

## Implementation Steps

### Phase 1: Create V2 Project Structure
1. Create `v2/` directory structure
2. Copy and update Lambda function code
3. Copy and update Terraform configuration files
4. Create GitHub-specific Azure Pipeline config

### Phase 2: GitHub Repository Setup
1. Create repository at https://github.com/Joseph-Jung/terraform
2. Initialize local git repository
3. Add remote origin
4. Create initial commit
5. Push to GitHub

### Phase 3: Azure Pipeline Integration with GitHub
1. Go to Azure DevOps
2. Create new pipeline
3. Select "GitHub" as source
4. Authorize Azure Pipelines
5. Select `Joseph-Jung/terraform` repository
6. Configure pipeline to use `v2/azure-pipelines.yml`
7. Set AWS credentials in pipeline variables

### Phase 4: Configure Remote State (Recommended)
1. Create S3 bucket for state
2. Create DynamoDB table for locking
3. Update backend.tf
4. Run `terraform init` to migrate state

### Phase 5: Test Deployment
1. Make a change in `develop` branch
2. Push to GitHub
3. Verify pipeline runs validation and plan
4. Merge to `main` branch
5. Approve deployment
6. Verify Lambda function deployed

## Variables & Configuration

### Terraform Variables (Same as V1)
- `aws_region`: Default us-east-1
- `lambda_function_name`: Default hello-world-lambda-v2
- `environment`: Default dev
- `log_retention_days`: Default 7 days

### Azure Pipeline Variables
- `AWS_ACCESS_KEY_ID`: Secret (from v1)
- `AWS_SECRET_ACCESS_KEY`: Secret (from v1)
- `AWS_REGION`: us-east-1

### GitHub Repository Settings
- **Branch Protection**: Enable for `main` branch
- **Required Reviews**: Optional (1 reviewer)
- **Status Checks**: Require Azure Pipeline success

## Security Considerations

1. **State File Security**
   - Use S3 backend with encryption
   - Never commit `terraform.tfstate` to GitHub
   - Add to .gitignore

2. **AWS Credentials**
   - Store in Azure Pipeline secrets only
   - Never commit to GitHub repository
   - Rotate regularly

3. **GitHub Access**
   - Use SSH keys or Personal Access Tokens
   - Enable 2FA on GitHub account
   - Review Azure Pipelines app permissions

4. **Branch Protection**
   - Protect `main` branch
   - Require pull request reviews
   - Require pipeline success before merge

## Cost Estimation (Same as V1)
- **Lambda**: Free tier includes 1M requests/month
- **CloudWatch Logs**: Free tier includes 5GB ingestion
- **S3 State Storage**: ~$0.01/month
- **DynamoDB Locking**: Free tier sufficient
- **Total**: ~$0-1/month for low usage

## Success Criteria

- [ ] V2 plan document created
- [ ] GitHub repository created and configured
- [ ] V2 project structure created in `v2/` directory
- [ ] Lambda function code in `v2/lambda/src/`
- [ ] Terraform configuration in `v2/terraform/`
- [ ] Azure Pipeline YAML updated for GitHub
- [ ] Remote state backend configured (S3 + DynamoDB)
- [ ] GitHub repository initialized and pushed
- [ ] Azure Pipeline connected to GitHub
- [ ] Pipeline runs successfully on GitHub push
- [ ] Lambda function deploys and returns "Hello World"
- [ ] Result document created

## GitHub Workflow

### Initial Setup
```bash
# Create repository on GitHub first, then:
cd /Users/joseph/Playground/AWS/BabyStep
git init
git add .
git commit -m "Initial commit: Terraform Lambda v2 with GitHub integration"
git branch -M main
git remote add origin https://github.com/Joseph-Jung/terraform.git
git push -u origin main
```

### Development Workflow
```bash
# Create feature branch
git checkout -b feature/update-lambda

# Make changes
# ... edit files ...

# Commit and push
git add .
git commit -m "Update: Lambda function enhancement"
git push origin feature/update-lambda

# Create Pull Request on GitHub
# Pipeline runs validation and plan

# After review and approval, merge to main
# Pipeline runs apply stage (with manual approval)
```

## Differences Summary: V1 vs V2

| Feature | V1 | V2 |
|---------|----|----|
| Project Path | `terraform/`, `lambda/` | `v2/terraform/`, `v2/lambda/` |
| Repository | Not specified | GitHub: Joseph-Jung/terraform |
| Version Control | Optional | Required (GitHub) |
| State Management | Local | S3 + DynamoDB (recommended) |
| Pipeline Integration | Azure only | Azure + GitHub |
| Branch Strategy | Not defined | main/develop |
| Collaboration | Single developer | Team-ready |

## Next Steps

1. ✅ Review and approve this plan
2. Create GitHub repository
3. Implement v2 project structure
4. Configure remote state backend
5. Push to GitHub
6. Configure Azure Pipeline with GitHub
7. Test end-to-end deployment
8. Document results

## References
- [AWS Lambda with Node.js](https://docs.aws.amazon.com/lambda/latest/dg/lambda-nodejs.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform S3 Backend](https://www.terraform.io/docs/language/settings/backends/s3.html)
- [Azure Pipelines with GitHub](https://docs.microsoft.com/azure/devops/pipelines/repos/github)
- [GitHub Repository Setup](https://docs.github.com/en/get-started/quickstart)

---

**Note**: This plan builds upon the successful v1 implementation and adds GitHub integration for better version control and collaboration.
