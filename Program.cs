using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    app.UseDeveloperExceptionPage();
}

app.UseHttpsRedirection();
app.UseRouting();

// API endpoints
app.MapGet("/", () => 
{
    return Results.Ok(new { 
        message = "Welcome to CI/CD POC Application", 
        timestamp = DateTime.UtcNow,
        environment = app.Environment.EnvironmentName
    });
})
.WithName("GetRoot")
.WithOpenApi();

app.MapGet("/health", () => 
{
    return Results.Ok(new { 
        status = "healthy", 
        timestamp = DateTime.UtcNow,
        version = System.Reflection.Assembly.GetExecutingAssembly().GetName().Version?.ToString(),
        environment = app.Environment.EnvironmentName
    });
})
.WithName("HealthCheck")
.WithOpenApi();

app.MapGet("/api/products", () =>
{
    var products = new[]
    {
        new { Id = 1, Name = "Laptop", Price = 999.99, Category = "Electronics" },
        new { Id = 2, Name = "Book", Price = 19.99, Category = "Education" },
        new { Id = 3, Name = "Coffee Mug", Price = 12.50, Category = "Kitchen" }
    };
    
    return Results.Ok(new { 
        data = products, 
        count = products.Length,
        timestamp = DateTime.UtcNow 
    });
})
.WithName("GetProducts")
.WithOpenApi();

app.MapGet("/api/info", () =>
{
    var info = new
    {
        ApplicationName = "CI/CD POC Application",
        Version = System.Reflection.Assembly.GetExecutingAssembly().GetName().Version?.ToString(),
        Environment = app.Environment.EnvironmentName,
        MachineName = Environment.MachineName,
        OSVersion = Environment.OSVersion.ToString(),
        ProcessorCount = Environment.ProcessorCount,
        WorkingSet = Environment.WorkingSet,
        Timestamp = DateTime.UtcNow
    };
    
    return Results.Ok(info);
})
.WithName("GetApplicationInfo")
.WithOpenApi();

app.Run();

// Make the implicit Program class accessible to tests
public partial class Program { }