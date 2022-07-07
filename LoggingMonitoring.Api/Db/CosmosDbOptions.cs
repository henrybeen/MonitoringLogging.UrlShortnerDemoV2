namespace LoggingMonitoring.Api.Db;

public class CosmosDbOptions
{
    public const string ConfigurationSectionName = "CosmosDb";

    public string AccountUri { get; set; }
    public string TenantId { get; set; }
    public string DataBaseName { get; set; }
    public string ContainerName { get; set; }
    public string ManagedIdentityClientId { get; set; }
}