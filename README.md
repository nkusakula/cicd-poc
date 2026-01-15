# CI/CD POC Application

This is a sample .NET 9.0 Web API application designed to demonstrate a **hybrid CI/CD pipeline** using GitHub Actions for Continuous Integration and Azure DevOps for Continuous Deployment.

## 🏗️ Architecture Overview

```
Developer → GitHub → GitHub Actions (CI) → Artifacts → Azure DevOps (CD) → Azure Web Apps
```

### Hybrid CI/CD Benefits
- **GitHub Actions**: Fast, integrated CI with excellent GitHub ecosystem
- **Azure DevOps**: Enterprise-grade deployment pipelines with advanced approval workflows
- **Best of Both Worlds**: Leverage strengths of both platforms

## Features

- **Health Check Endpoint**: `/health` - Returns application health status
- **Products API**: `/api/products` - Returns sample product data
- **Application Info**: `/api/info` - Returns system and application information
- **Swagger UI**: Available in development environment

## Getting Started

### Prerequisites

- .NET 9.0 SDK
- Visual Studio 2022 or VS Code
- Azure CLI (for Azure resource setup)
- Azure DevOps account
- GitHub account

### Running the Application

1. Clone the repository
2. Navigate to the project directory
3. Run the following commands:

```bash
dotnet restore
dotnet build
dotnet run
```

The application will start on `https://localhost:7000` and `http://localhost:5000`.

### Running Tests

```bash
dotnet test
```

## API Endpoints

- `GET /` - Welcome message with application info
- `GET /health` - Health check endpoint
- `🚀 CI/CD Pipeline Setup

This application implements a hybrid CI/CD pipeline:

### 📋 **Quick Start**
1. **Set up Azure resources**: Run `scripts/setup-azure-resources.ps1`
2. **Configure Azure DevOps**: Follow `docs/pipeline-setup.md`
3. **Push to main branch**: Pipeline will automatically deploy

### 🔄 **Pipeline Flow**
1. **CI (GitHub Actions)**:
   - Build & test .NET application
   - Run security scans (CodeQL, vulnerability checks)  
   - Create deployment artifacts
   - Upload to GitHub Actions artifacts

2. **CD (Azure DevOps)**:
   - Download artifacts from GitHub Actions
   - Deploy to Development → Staging → Production
   - Run health checks and smoke tests
   - Manual approval gates for production

### 🌐 **Deployment Environments**
- **Development**: `https://cicd-poc-dev.azurewebsites.net`
- **Staging**: `https://cicd-poc-staging.azurewebsites.net`  
- **Production**: `https://cicd-poc-production.azurewebsites.net`

### 📁 **Pipeline Files**
- `.github/workflows/ci.yml` - GitHub Actions CI pipeline
- `azure-pipelines/cd-pipeline.yml` - Azure DevOps CD pipeline
- `scripts/setup-azure-resources.ps1` - Azure resource setup script
- `docs/pipeline-setup.md` - Complete setup guide
This application is configured for:
- **CI**: GitHub Actions for building, testing, and packaging
- **CD**: Azure DevOps Pipelines for deployment orchestration

## Project Structure

```
├── Program.cs                  # Main application file
├── CicdPoc.csproj             # Project file
├── appsettings.json           # Application settings
├── appsettings.Development.json # Development settings
├── Tests/                     # Test project
│   ├── ApplicationTests.cs    # Integration tests
│   └── CicdPoc.Tests.csproj  # Test project file
└── README.md                  # This file
```

## Technology Stack

- .NET 8
- ASP.NET Core Web API
- Swagger/OpenAPI
- xUnit for testing
- Microsoft.AspNetCore.Mvc.Testing for integration tests