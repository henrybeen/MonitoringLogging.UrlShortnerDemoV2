using Microsoft.Azure.Cosmos;

namespace LoggingMonitoring.Api.Db;

public interface ICosmosDbContainerProvider
{
    Task<Container> GetTodoContainerAsync();
}