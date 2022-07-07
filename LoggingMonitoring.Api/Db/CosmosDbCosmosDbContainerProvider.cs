using Azure.Identity;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Options;

namespace LoggingMonitoring.Api.Db;

public class CosmosDbContainerProvider : ICosmosDbContainerProvider
{
    private readonly CosmosDbOptions _options;

    private CosmosClient _cosmosClient;
    private Container? _container;

    public CosmosDbContainerProvider(IOptions<CosmosDbOptions> options)
    {
        _options = options.Value;
    }

    public async Task<Container> GetTodoContainerAsync()
    {
        AssertClient();
        AssertContainer();

        return _container;
    }

    private void AssertClient()
    {
        if (_container == null)
        {
            var credential = new DefaultAzureCredential(new DefaultAzureCredentialOptions
            {
                ManagedIdentityClientId = _options.ManagedIdentityClientId,
                SharedTokenCacheTenantId = _options.TenantId,
                VisualStudioCodeTenantId = _options.TenantId,
                VisualStudioTenantId = _options.TenantId
            });

            _cosmosClient = new CosmosClient(_options.AccountUri, credential);
        }
    }

    private void AssertContainer()
    {
        if (_container == null)
        {
            _container = _cosmosClient.GetContainer(_options.DataBaseName, _options.ContainerName);
        }
    }
}