# Azure Pipeline Setup Guide

This guide will walk you through setting up Azure Pipelines to automatically deploy your Lambda function to AWS from GitHub.

## Prerequisites Checklist

### ✅ AWS Account Setup

1. **AWS Account Access**
   - [ ] Active AWS account
   - [ ] Access to AWS Console

2. **Create IAM User for Azure Pipeline**
   ```bash
   # In AWS Console: IAM → Users → Create User
   # User name: azure-pipeline-terraform
   # Access type: Programmatic access (Access Key)
   ```

3. **Attach Required IAM Policies**

   Attach these AWS managed policies to the IAM user:
   - [ ] `AWSLambda_FullAccess`
   - [ ] `IAMFullAccess` (or create custom policy - see below)
   - [ ] `AmazonAPIGatewayAdministrator`
   - [ ] `CloudWatchLogsFullAccess`

   **Custom IAM Policy (Least Privilege - Recommended):**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "lambda:*",
           "iam:CreateRole",
           "iam:DeleteRole",
           "iam:GetRole",
           "iam:PassRole",
           "iam:AttachRolePolicy",
           "iam:DetachRolePolicy",
           "iam:PutRolePolicy",
           "iam:DeleteRolePolicy",
           "iam:GetRolePolicy",
           "iam:ListRolePolicies",
           "iam:ListAttachedRolePolicies",
           "apigateway:*",
           "logs:*",
           "s3:*"
         ],
         "Resource": "*"
       }
     ]
   }
   ```

4. **Save AWS Credentials**
   - [ ] Copy `AWS Access Key ID`
   - [ ] Copy `AWS Secret Access Key`
   - [ ] Note your AWS Region (e.g., `us-east-1`)

   ⚠️ **IMPORTANT**: Store these securely! You won't be able to see the secret key again.

---

## Azure DevOps Setup

### Step 1: Create Azure DevOps Organization and Project

1. **Navigate to Azure DevOps**
   - [ ] Go to https://dev.azure.com
   - [ ] Sign in with your Microsoft account
   - [ ] Create a new organization (if you don't have one)

2. **Create a Project**
   - [ ] Click "New Project"
   - [ ] Name: `terraform-lambda` (or your preferred name)
   - [ ] Visibility: Private (recommended)
   - [ ] Version control: Git
   - [ ] Work item process: Agile
   - [ ] Click "Create"

---

### Step 2: Connect GitHub Repository

1. **Create Service Connection to GitHub**
   - [ ] In Azure DevOps, go to: **Project Settings** (bottom left)
   - [ ] Navigate to: **Pipelines** → **Service connections**
   - [ ] Click: **New service connection**
   - [ ] Select: **GitHub**
   - [ ] Click: **Next**
   - [ ] Choose authorization method:
     - **OAuth** (Recommended): Click "Authorize" and sign in to GitHub
     - **Personal Access Token**: Create a PAT in GitHub Settings
   - [ ] Connection name: `github-connection`
   - [ ] Grant access permission to all pipelines: ✅
   - [ ] Click: **Save**

2. **Verify Connection**
   - [ ] Ensure the connection shows "Ready" status
   - [ ] Test the connection if possible

---

### Step 3: Create Variable Group for AWS Credentials

1. **Navigate to Library**
   - [ ] In Azure DevOps, go to: **Pipelines** → **Library**
   - [ ] Click: **+ Variable group**

2. **Configure Variable Group**
   - [ ] Variable group name: `terraform-aws-credentials`
   - [ ] Description: `AWS credentials for Terraform deployment`

3. **Add Variables**

   Click **+ Add** for each variable:

   | Variable Name | Value | Secret? | Example |
   |--------------|-------|---------|---------|
   | `AWS_ACCESS_KEY_ID` | Your AWS Access Key | ✅ Yes | `AKIAIOSFODNN7EXAMPLE` |
   | `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Key | ✅ Yes | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
   | `AWS_REGION` | Your AWS Region | ❌ No | `us-east-1` |

4. **Lock the Secret Variables**
   - [ ] Click the 🔒 lock icon next to `AWS_ACCESS_KEY_ID`
   - [ ] Click the 🔒 lock icon next to `AWS_SECRET_ACCESS_KEY`
   - [ ] This hides the values in logs and UI

5. **Save the Variable Group**
   - [ ] Click: **Save**

---

### Step 4: Create Environment for Approvals

1. **Navigate to Environments**
   - [ ] In Azure DevOps, go to: **Pipelines** → **Environments**
   - [ ] Click: **New environment**

2. **Configure Environment**
   - [ ] Name: `production`
   - [ ] Description: `Production AWS environment`
   - [ ] Resource: **None** (we're not using Kubernetes)
   - [ ] Click: **Create**

3. **Add Approval Check (Recommended)**
   - [ ] Click on the `production` environment
   - [ ] Click the **⋮** (three dots) → **Approvals and checks**
   - [ ] Click: **Approvals**
   - [ ] Add yourself as an approver
   - [ ] Configure:
     - Approvers: Add your name/email
     - Minimum number of approvers: 1
     - Timeout: 30 days
     - Allow approvers to approve their own runs: ✅ (if you're solo)
   - [ ] Click: **Create**

---

### Step 5: Create the Pipeline

1. **Navigate to Pipelines**
   - [ ] In Azure DevOps, go to: **Pipelines** → **Pipelines**
   - [ ] Click: **New pipeline** (or **Create Pipeline**)

2. **Connect to Your Repository**
   - [ ] Select: **GitHub**
   - [ ] Select your repository: `Joseph-Jung/terraform`
   - [ ] You may need to authorize Azure Pipelines to access your repo

3. **Configure Pipeline**
   - [ ] Select: **Existing Azure Pipelines YAML file**
   - [ ] Branch: `main`
   - [ ] Path: `/v3/azure-pipelines.yml`
   - [ ] Click: **Continue**

4. **Review Pipeline YAML**
   - [ ] Review the pipeline configuration
   - [ ] Click: **Save** (not Run yet)

5. **Configure Pipeline Permissions**
   - [ ] Go to pipeline settings (⋮ menu → Settings)
   - [ ] Grant access to variable group `terraform-aws-credentials`
   - [ ] Grant access to environment `production`

---

### Step 6: Push Code to GitHub

Before running the pipeline, ensure your code is pushed to GitHub:

```bash
# Navigate to repository root
cd /Users/joseph/Playground/terraform

# Check current status
git status

# Add v3 directory
git add v3/
git add .gitignore
git add .claude/

# Commit changes
git commit -m "Add v3: AWS Lambda with Terraform and Azure Pipeline

- Lambda function (Node.js 18.x) returning Hello World
- Complete Terraform infrastructure (Lambda, API Gateway, IAM, CloudWatch)
- Azure Pipeline for CI/CD deployment
- Comprehensive documentation and setup guides"

# Push to GitHub
git push origin main
```

---

### Step 7: Run the Pipeline

1. **Trigger Pipeline Manually**
   - [ ] Go to: **Pipelines** → **Pipelines**
   - [ ] Select your pipeline
   - [ ] Click: **Run pipeline**
   - [ ] Branch: `main`
   - [ ] Click: **Run**

2. **Monitor Pipeline Execution**

   The pipeline will run through 4 stages:

   **Stage 1: Validate** (2-3 minutes)
   - [ ] Checkout code
   - [ ] Install Terraform
   - [ ] Format check
   - [ ] Terraform validate

   **Stage 2: Plan** (2-3 minutes)
   - [ ] Terraform init
   - [ ] Terraform plan
   - [ ] Publish plan artifact

   **Stage 3: Apply** (Waits for approval)
   - [ ] **APPROVE THE DEPLOYMENT** in the Azure DevOps UI
   - [ ] Terraform apply
   - [ ] Display outputs

   **Stage 4: Test** (1 minute)
   - [ ] Test API endpoints
   - [ ] Verify deployment

3. **Approve Deployment**
   - [ ] When Stage 3 starts, you'll see an approval request
   - [ ] Review the Terraform plan from Stage 2
   - [ ] Click: **Review** → **Approve**
   - [ ] Deployment will proceed

---

## Verification Steps

### After Successful Deployment

1. **Check Pipeline Output**
   - [ ] Stage 3 (Apply) should show Terraform outputs
   - [ ] Copy the `api_gateway_invoke_url`

2. **Test the API Endpoint**
   ```bash
   # Replace with your actual URL from pipeline output
   curl https://XXXXXXXXXX.execute-api.us-east-1.amazonaws.com/prod/
   ```

   Expected response:
   ```json
   {
     "message": "Hello World",
     "timestamp": "2025-10-25T...",
     "requestId": "..."
   }
   ```

3. **Verify in AWS Console**
   - [ ] **Lambda**: Check function exists and has correct configuration
   - [ ] **API Gateway**: Verify HTTP API is created
   - [ ] **CloudWatch Logs**: Check log groups are created
   - [ ] **IAM**: Verify execution role exists

---

## Troubleshooting

### Common Issues

#### Issue 1: Pipeline Can't Access Variable Group
**Error**: `Variable group 'terraform-aws-credentials' could not be found`

**Solution**:
1. Go to Pipeline → Edit → ⋮ → Triggers
2. Enable "Variables" → Link variable group
3. Save and re-run

#### Issue 2: AWS Authentication Fails
**Error**: `Error: error configuring Terraform AWS Provider: no valid credential sources`

**Solution**:
1. Verify variable names are exactly:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
2. Check variables are marked as secrets (locked)
3. Verify IAM user credentials are correct

#### Issue 3: Terraform Permission Denied
**Error**: `AccessDeniedException` or `UnauthorizedException`

**Solution**:
1. Verify IAM user has required policies attached
2. Check policy permissions include all required actions
3. Wait 1-2 minutes for IAM changes to propagate

#### Issue 4: Environment Not Found
**Error**: `Could not find an environment named 'production'`

**Solution**:
1. Create environment named exactly `production`
2. Grant pipeline access to environment
3. Re-run pipeline

#### Issue 5: GitHub Connection Failed
**Error**: `The requested resource does not exist, or you don't have permission to access it`

**Solution**:
1. Re-authorize GitHub connection
2. Ensure Azure Pipelines app is installed in GitHub
3. Check repository access permissions

---

## Pipeline Triggers

### Automatic Triggers

The pipeline is configured to trigger automatically on:

1. **Push to main branch** with changes in `v3/**`
   - Full deployment (all stages)

2. **Pull Request to main** with changes in `v3/**`
   - Validation and planning only (no apply)

### Manual Triggers

You can also run the pipeline manually:
1. Go to Pipelines → Your pipeline
2. Click "Run pipeline"
3. Select branch and run

---

## Security Best Practices

### ✅ Implemented
- [x] AWS credentials stored as secret variables
- [x] Manual approval for production deployment
- [x] Terraform state stored locally (for now)
- [x] IAM least privilege principles
- [x] CloudWatch logging enabled

### 🔄 Recommended for Production
- [ ] Enable S3 backend for Terraform state (see `backend.tf`)
- [ ] Implement state locking with DynamoDB
- [ ] Add API Gateway authentication (API keys or Cognito)
- [ ] Enable AWS CloudTrail for audit logging
- [ ] Implement automated testing stage
- [ ] Add rollback capabilities
- [ ] Enable branch protection in GitHub
- [ ] Rotate AWS credentials regularly

---

## Next Steps

After successful deployment:

1. **Enable Remote State** (Production)
   ```bash
   # Create S3 bucket for state
   aws s3api create-bucket --bucket your-terraform-state-bucket --region us-east-1
   aws s3api put-bucket-versioning --bucket your-terraform-state-bucket --versioning-configuration Status=Enabled

   # Create DynamoDB table for locking
   aws dynamodb create-table \
     --table-name terraform-state-lock \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST

   # Uncomment and configure backend.tf
   ```

2. **Add Multiple Environments**
   - Create `dev`, `staging`, `prod` workspaces
   - Separate variable groups per environment
   - Different approval workflows

3. **Enhance Monitoring**
   - CloudWatch dashboards
   - SNS alerts for Lambda errors
   - X-Ray tracing

4. **Add Testing**
   - Unit tests for Lambda function
   - Integration tests in pipeline
   - Load testing

---

## Support

If you encounter issues:

1. **Check Pipeline Logs**
   - Click on failed stage
   - Review detailed logs
   - Look for error messages

2. **Verify Prerequisites**
   - All checkboxes in this guide are complete
   - AWS credentials are valid
   - IAM permissions are correct

3. **Common Commands**
   ```bash
   # Test AWS credentials locally
   aws sts get-caller-identity

   # Verify Terraform locally
   cd v3/terraform
   terraform init
   terraform validate
   terraform plan
   ```

---

## Quick Reference

### Azure DevOps URLs
- Organization: `https://dev.azure.com/YOUR_ORG`
- Project: `https://dev.azure.com/YOUR_ORG/terraform-lambda`
- Pipelines: `https://dev.azure.com/YOUR_ORG/terraform-lambda/_build`
- Library: `https://dev.azure.com/YOUR_ORG/terraform-lambda/_library`

### Important Names (Must Match Exactly)
- Variable Group: `terraform-aws-credentials`
- Environment: `production`
- Pipeline File: `v3/azure-pipelines.yml`

### AWS Resources Created
- Lambda Function: `hello-world-lambda`
- API Gateway: `hello-world-lambda-api`
- IAM Role: `hello-world-lambda-execution-role`
- Log Groups: `/aws/lambda/hello-world-lambda`, `/aws/apigateway/hello-world-lambda-api`

---

## Estimated Time to Complete

- **AWS Setup**: 10-15 minutes
- **Azure DevOps Setup**: 15-20 minutes
- **First Deployment**: 10-15 minutes
- **Total**: ~45 minutes

---

Good luck with your deployment! 🚀
