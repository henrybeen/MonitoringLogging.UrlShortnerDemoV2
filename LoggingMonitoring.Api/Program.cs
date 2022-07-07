using LoggingMonitoring.Api.Db;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddApplicationInsightsTelemetry();

builder.Services.AddSingleton<ICosmosDbContainerProvider, CosmosDbContainerProvider>();

builder.Services.Configure<CosmosDbOptions>(
    options => builder.Configuration.GetSection(CosmosDbOptions.ConfigurationSectionName).Bind(options));

var app = builder.Build();

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
