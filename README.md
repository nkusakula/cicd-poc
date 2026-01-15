# CI/CD POC Application

This is a sample .NET 8 Web API application designed to demonstrate a hybrid CI/CD pipeline using GitHub Actions for Continuous Integration and Azure DevOps for Continuous Deployment.

## Features

- **Health Check Endpoint**: `/health` - Returns application health status
- **Products API**: `/api/products` - Returns sample product data
- **Application Info**: `/api/info` - Returns system and application information
- **Swagger UI**: Available in development environment

## Getting Started

### Prerequisites

- .NET 8.0 SDK
- Visual Studio 2022 or VS Code

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
- `GET /api/products` - Returns sample product data
- `GET /api/info` - Returns detailed application information

## CI/CD Pipeline

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