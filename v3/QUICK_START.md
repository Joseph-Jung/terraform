# Quick Start - Azure Pipeline Deployment

## ✅ Step 1: AWS Setup (10 minutes)

1. **Create IAM User in AWS Console**
   - Go to: IAM → Users → Create User
   - Name: `azure-pipeline-terraform`
   - Access type: Programmatic access
   - Save the Access Key ID and Secret Access Key

2. **Attach Policies**
   - `AWSLambda_FullAccess`
   - `IAMFullAccess`
   - `AmazonAPIGatewayAdministrator`
   - `CloudWatchLogsFullAccess`

## ✅ Step 2: Azure DevOps Setup (15 minutes)

### 2.1 Create Project
1. Go to https://dev.azure.com
2. Create new project: `terraform-lambda`

### 2.2 Create Variable Group
1. Navigate to: **Pipelines** → **Library** → **+ Variable group**
2. Name: `terraform-aws-credentials`
3. Add variables (click 🔒 for secrets):
   - `AWS_ACCESS_KEY_ID` (🔒 secret)
   - `AWS_SECRET_ACCESS_KEY` (🔒 secret)
   - `AWS_REGION` (e.g., `us-east-1`)
4. Save

### 2.3 Create Environment
1. Navigate to: **Pipelines** → **Environments** → **New environment**
2. Name: `production`
3. Add approval check:
   - Click ⋮ → **Approvals and checks**
   - Add yourself as approver

### 2.4 Connect GitHub
1. Go to: **Project Settings** → **Service connections** → **New service connection**
2. Select: **GitHub**
3. Authorize with OAuth
4. Name: `github-connection`

### 2.5 Create Pipeline
1. Navigate to: **Pipelines** → **New pipeline**
2. Select: **GitHub**
3. Repository: `Joseph-Jung/terraform`
4. Select: **Existing Azure Pipelines YAML file**
5. Path: `/v3/azure-pipelines.yml`
6. Save (don't run yet)

## ✅ Step 3: Run Pipeline (10 minutes)

1. **Go to Pipelines** → Select your pipeline → **Run pipeline**
2. **Monitor stages:**
   - ✅ Validate (2 min)
   - ✅ Plan (2 min)
   - ⏸️ Apply (requires approval)
   - ✅ Test (1 min)

3. **Approve deployment:**
   - Review Terraform plan
   - Click **Approve**
   - Wait for completion

## ✅ Step 4: Test Deployment

Copy the API URL from pipeline output and test:

```bash
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

## 🎉 Done!

Your Lambda function is now deployed and accessible via API Gateway!

---

## 📚 Full Documentation

For detailed instructions, see:
- **Setup Guide**: `v3/AZURE_PIPELINE_SETUP.md`
- **Project README**: `v3/README.md`
- **Implementation Plan**: `.claude/plan/v3_implementation_plan.md`

## 🔧 Troubleshooting

**Pipeline can't find variable group?**
→ Edit pipeline → ⋮ → Settings → Link variable group

**AWS authentication fails?**
→ Verify variable names are exactly: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`

**Environment not found?**
→ Create environment named exactly `production`

**Need more help?**
→ See full troubleshooting guide in `AZURE_PIPELINE_SETUP.md`

---

## 📊 What Gets Deployed

- **Lambda Function**: `hello-world-lambda` (Node.js 18.x)
- **API Gateway**: HTTP API with routes: /, /hello
- **IAM Role**: Lambda execution role with CloudWatch access
- **CloudWatch Logs**: Lambda and API Gateway logs (7-day retention)

## 💰 Cost Estimate

With AWS Free Tier:
- **First year**: ~$0/month (within free tier limits)
- **After free tier**: < $2/month for moderate usage

---

## 🚀 Next Steps

1. **Enable Remote State** (Production)
   ```bash
   # Uncomment backend.tf and configure S3 bucket
   ```

2. **Add Authentication**
   - API keys
   - AWS Cognito
   - Custom authorizer

3. **Multi-Environment**
   - Create dev/staging/prod environments
   - Separate variable groups

4. **Monitoring**
   - CloudWatch dashboards
   - SNS alerts
   - X-Ray tracing
