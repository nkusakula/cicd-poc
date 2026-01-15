# Hybrid CI/CD Pipeline Setup Guide

This guide walks you through setting up the hybrid CI/CD pipeline for the CicdPoc application.

## Overview

The hybrid approach uses:
- **GitHub Actions** for Continuous Integration (CI)
- **Azure DevOps** for Continuous Deployment (CD)

## Architecture Flow

```
Code Push → GitHub Actions (CI) → Build Artifacts → Azure DevOps (CD) → Deploy to Azure
```

## Prerequisites

### Required Services
1. **GitHub Repository** (for source code and CI)
2. **Azure DevOps Organization** (for CD pipelines)
3. **Azure Subscription** (for hosting environments)

### Required Permissions
- Admin access to GitHub repository
- Project Administrator in Azure DevOps
- Contributor/Owner role in Azure subscription

## Step 1: GitHub Actions Setup (CI)

The CI pipeline is already configured in `.github/workflows/ci.yml`. It will:

✅ **Build and Test**
- Restore NuGet packages
- Build the application
- Run tests with code coverage
- Publish build artifacts

✅ **Security Scanning**
- Vulnerability scanning
- CodeQL analysis

✅ **Artifact Creation**
- Package application for deployment
- Upload to GitHub Actions artifacts

### GitHub Actions Configuration

No additional setup needed - the workflow will trigger automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` branch

## Step 2: Azure Resources Setup

### Create Azure Web Apps

```bash
# Login to Azure
az login

# Create resource group
az group create --name rg-cicd-poc --location eastus

# Create App Service Plan
az appservice plan create --name asp-cicd-poc --resource-group rg-cicd-poc --sku S1

# Create Web Apps for each environment
az webapp create --name cicd-poc-dev --resource-group rg-cicd-poc --plan asp-cicd-poc --runtime "DOTNET|8.0"
az webapp create --name cicd-poc-staging --resource-group rg-cicd-poc --plan asp-cicd-poc --runtime "DOTNET|8.0"  
az webapp create --name cicd-poc-production --resource-group rg-cicd-poc --plan asp-cicd-poc --runtime "DOTNET|8.0"
```

## Step 3: Azure DevOps Setup (CD)

### 3.1 Create Azure DevOps Project

1. Go to [Azure DevOps](https://dev.azure.com)
2. Create new organization (if needed)
3. Create new project named "CicdPoc"

### 3.2 Set Up Service Connections

#### Azure Service Connection
1. Go to **Project Settings** → **Service Connections**
2. Click **New service connection** → **Azure Resource Manager**
3. Choose **Service principal (automatic)**
4. Select your subscription and resource group
5. Name it: `Azure-CicdPoc-Connection`

#### GitHub Service Connection (Optional)
1. **New service connection** → **GitHub**
2. Authorize Azure DevOps to access your GitHub repo
3. Name it: `GitHub-CicdPoc-Connection`

### 3.3 Create Variable Group

1. Go to **Pipelines** → **Library**
2. Click **+ Variable group**
3. Name: `cicd-poc-variables`
4. Add these variables (refer to `azure-pipelines/variables-template.yml`):

| Variable | Value | Secret |
|----------|-------|---------|
| `azureSubscriptionConnection` | `Azure-CicdPoc-Connection` | No |
| `devWebAppName` | `cicd-poc-dev` | No |
| `stagingWebAppName` | `cicd-poc-staging` | No |
| `productionWebAppName` | `cicd-poc-production` | No |
| `resourceGroupName` | `rg-cicd-poc` | No |
| `subscriptionId` | `your-subscription-id` | Yes |

### 3.4 Create Environments

1. Go to **Pipelines** → **Environments**
2. Create three environments:
   - `cicd-poc-dev` (auto-approval)
   - `cicd-poc-staging` (auto-approval)
   - `cicd-poc-production` (manual approval required)

### 3.5 Set Up the CD Pipeline

1. Go to **Pipelines** → **Pipelines**
2. Click **New pipeline**
3. Choose **Azure Repos Git** or **GitHub** (where your code is)
4. Select **Existing Azure Pipelines YAML file**
5. Choose `azure-pipelines/cd-pipeline.yml`
6. Save and run

## Step 4: Integration Setup

### 4.1 Connect GitHub Actions to Azure DevOps

You have several options to trigger the CD pipeline:

#### Option A: REST API Trigger
Add this step to your GitHub Actions workflow:

```yaml
- name: Trigger Azure DevOps Pipeline
  if: github.ref == 'refs/heads/main'
  run: |
    curl -X POST \
      -H "Authorization: Basic $(echo -n ':${{ secrets.AZURE_DEVOPS_PAT }}' | base64)" \
      -H "Content-Type: application/json" \
      -d '{"definition":{"id":${{ secrets.AZURE_PIPELINE_ID }}},"sourceBranch":"refs/heads/main"}' \
      "https://dev.azure.com/{organization}/{project}/_apis/build/builds?api-version=6.0"
```

#### Option B: Azure DevOps Extension
Use the Azure DevOps GitHub Action:

```yaml
- name: Trigger Azure Pipeline
  uses: Azure/pipelines@v1
  with:
    azure-devops-project-url: 'https://dev.azure.com/{organization}/{project}'
    azure-pipeline-name: 'CD-Pipeline'
    azure-devops-token: ${{ secrets.AZURE_DEVOPS_PAT }}
```

### 4.2 GitHub Secrets Setup

Add these secrets to your GitHub repository:

1. Go to GitHub repo → **Settings** → **Secrets and variables** → **Actions**
2. Add repository secrets:
   - `AZURE_DEVOPS_PAT`: Personal Access Token from Azure DevOps
   - `AZURE_PIPELINE_ID`: ID of your CD pipeline

## Step 5: Testing the Pipeline

### 5.1 Test CI Pipeline
1. Make a code change
2. Push to `develop` branch
3. Verify GitHub Actions workflow runs successfully
4. Check artifacts are created

### 5.2 Test CD Pipeline
1. Push changes to `main` branch
2. Verify GitHub Actions completes
3. Check Azure DevOps pipeline triggers
4. Verify deployments to each environment:
   - Dev: `https://cicd-poc-dev.azurewebsites.net/health`
   - Staging: `https://cicd-poc-staging.azurewebsites.net/health`
   - Production: `https://cicd-poc-production.azurewebsites.net/health`

## Monitoring and Maintenance

### Health Checks
Each environment has health check endpoints:
- `/health` - Application health
- `/api/info` - System information

### Logs and Monitoring
- **GitHub Actions**: Check workflow logs in Actions tab
- **Azure DevOps**: Monitor pipeline runs in Pipelines section
- **Azure App Service**: Use Application Insights for runtime monitoring

### Rollback Strategy
If production deployment fails:
1. Check Azure DevOps pipeline logs
2. Use Azure portal to swap deployment slots (if configured)
3. Or redeploy previous successful build

## Security Considerations

✅ **Secrets Management**
- Use GitHub secrets for sensitive data
- Use Azure Key Vault for production secrets
- Rotate PAT tokens regularly

✅ **Access Control**
- Limit who can approve production deployments
- Use branch protection rules
- Enable required reviews for main branch

✅ **Vulnerability Scanning**
- CodeQL analysis in GitHub Actions
- Dependency vulnerability scanning
- Regular security updates

## Troubleshooting

### Common Issues

**GitHub Actions fails:**
- Check .NET SDK version compatibility
- Verify NuGet package restoration
- Check test failures

**Azure DevOps pipeline fails:**
- Verify service connection permissions
- Check variable group values
- Ensure Azure Web Apps exist

**Deployment fails:**
- Check health endpoints
- Verify Azure Web App configuration
- Check application logs in Azure portal

### Getting Help

- GitHub Actions: Check workflow logs and GitHub documentation
- Azure DevOps: Use pipeline logs and Azure DevOps documentation  
- Azure App Service: Check Application Insights and Azure portal logs