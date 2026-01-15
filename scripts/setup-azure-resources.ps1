# Azure Resources Setup Script for CI/CD POC
# Run this script to create the required Azure resources

param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "rg-cicd-poc",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$false)]
    [string]$AppServicePlanName = "asp-cicd-poc",
    
    [Parameter(Mandatory=$false)]
    [string]$AppServiceSku = "S1"
)

Write-Host "🚀 Setting up Azure resources for CI/CD POC..." -ForegroundColor Cyan

# Set subscription context
Write-Host "📋 Setting Azure subscription context..." -ForegroundColor Yellow
az account set --subscription $SubscriptionId

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to set subscription. Please ensure you're logged in: az login" -ForegroundColor Red
    exit 1
}

# Create resource group
Write-Host "🏗️ Creating resource group: $ResourceGroupName" -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create resource group" -ForegroundColor Red
    exit 1
}

# Create App Service Plan
Write-Host "📱 Creating App Service Plan: $AppServicePlanName" -ForegroundColor Yellow
az appservice plan create `
    --name $AppServicePlanName `
    --resource-group $ResourceGroupName `
    --location $Location `
    --sku $AppServiceSku

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create App Service Plan" -ForegroundColor Red
    exit 1
}

# Create Web Apps for each environment
$environments = @("dev", "staging", "production")

foreach ($env in $environments) {
    $webAppName = "cicd-poc-$env"
    Write-Host "🌐 Creating Web App: $webAppName" -ForegroundColor Yellow
    
    az webapp create `
        --name $webAppName `
        --resource-group $ResourceGroupName `
        --plan $AppServicePlanName `
        --runtime "DOTNET|9.0"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to create Web App: $webAppName" -ForegroundColor Red
        continue
    }
    
    # Configure application settings
    Write-Host "⚙️ Configuring Web App settings for: $webAppName" -ForegroundColor Yellow
    az webapp config appsettings set `
        --name $webAppName `
        --resource-group $ResourceGroupName `
        --settings `
            "ASPNETCORE_ENVIRONMENT=$($env.ToUpper())" `
            "WEBSITE_RUN_FROM_PACKAGE=1" `
            "SCM_DO_BUILD_DURING_DEPLOYMENT=false"
            
    # Configure health check
    az webapp config set `
        --name $webAppName `
        --resource-group $ResourceGroupName `
        --health-check-path "/health"
        
    Write-Host "✅ Successfully created and configured: $webAppName" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Azure resources setup completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Summary of created resources:" -ForegroundColor Cyan
Write-Host "  • Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "  • App Service Plan: $AppServicePlanName ($AppServiceSku)" -ForegroundColor White
Write-Host "  • Web Apps:" -ForegroundColor White
foreach ($env in $environments) {
    $webAppName = "cicd-poc-$env"
    $url = "https://$webAppName.azurewebsites.net"
    Write-Host "    - $webAppName ($url)" -ForegroundColor White
}
Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor Yellow
Write-Host "  1. Note down your subscription ID: $SubscriptionId" -ForegroundColor White
Write-Host "  2. Set up Azure DevOps service connection to this subscription" -ForegroundColor White
Write-Host "  3. Create variable group with the Web App names listed above" -ForegroundColor White
Write-Host "  4. Follow the pipeline setup guide in docs/pipeline-setup.md" -ForegroundColor White
Write-Host ""

# Output variables for pipeline setup
Write-Host "🔧 Variables for Azure DevOps setup:" -ForegroundColor Magenta
Write-Host "subscriptionId: $SubscriptionId" -ForegroundColor White
Write-Host "resourceGroupName: $ResourceGroupName" -ForegroundColor White
Write-Host "devWebAppName: cicd-poc-dev" -ForegroundColor White
Write-Host "stagingWebAppName: cicd-poc-staging" -ForegroundColor White
Write-Host "productionWebAppName: cicd-poc-production" -ForegroundColor White