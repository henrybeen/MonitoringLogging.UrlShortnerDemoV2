using LoggingMonitoring.Api.Db;
using LoggingMonitoring.Api.Model;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;

namespace LoggingMonitoring.Api.Controllers
{
    [ApiController]
    [Route("/api/todos")]
    public class TodoController : ControllerBase
    {
        private static readonly Random _random = new Random();

        private readonly ICosmosDbContainerProvider _cosmosDbContainerProvider;
        private readonly ILogger<TodoController> _logger;
        private readonly TelemetryClient _telemetryClient;

        public TodoController(ICosmosDbContainerProvider cosmosDbContainerProvider, ILogger<TodoController> logger, TelemetryClient telemetryClient)
        {
            _cosmosDbContainerProvider = cosmosDbContainerProvider;
            _logger = logger;
            _telemetryClient = telemetryClient;
        }

        [HttpPost]
        public async Task<IActionResult> Post(Todo todo)
        {
            todo.Id = Guid.NewGuid();

            var container = await _cosmosDbContainerProvider.GetTodoContainerAsync();

            if (_random.Next(1, 1000) == 531)
            {
                throw new InvalidOperationException("I'm just throwing this to show we can capture exceptions");
            }


            var results = await container
                .CreateItemAsync(todo);

            _telemetryClient
                .GetMetric("FailedLogins", "Username")
                .TrackValue(1, "henry@azuresdlkfjdskl");

            _telemetryClient
                .GetMetric("TodosAdded")
                .TrackValue(1);

            _logger.LogInformation("Created a new Todo with id '{id}'", todo.Id);

            return Ok(todo);
        }


        [HttpGet]
        public async Task<IActionResult> Get(int skip = 0, int take = 25)
        {
            var container = await _cosmosDbContainerProvider.GetTodoContainerAsync();

            var results = container.GetItemLinqQueryable<Todo>(true)
                .Skip(skip)
                .Take(take)
                .ToArray();

            _logger.LogWarning("Returning a total of '{resultCount}' Todos", results.Length);

            return Ok(results);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(Guid id)
        {
            var container = await _cosmosDbContainerProvider.GetTodoContainerAsync();

            var result = container.GetItemLinqQueryable<Todo>(true)
                .Where(x => x.Id == id)
                .Take(1)
                .ToArray()
                .FirstOrDefault();

            if (result == null)
            {
                _logger.LogWarning("Requested Todo with id '{id}' is not found", id);
                return NotFound();
            }

            _logger.LogWarning("Requested Todo with id '{id}' is being returned", id);
            return Ok(result);
        }
    }
}