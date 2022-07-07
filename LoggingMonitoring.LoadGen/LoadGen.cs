using System;
using System.Net.Http;
using System.Threading.Tasks;
using LoggingMonitoring.Api.Model;
using Microsoft.ApplicationInsights;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace LoggingMonitoring.LoadGen;

public class LoadGen
{
    private readonly ILogger<LoadGen> _logger;
    private readonly TelemetryClient _telemetryClient;

    private readonly Random _random = new Random();
    private readonly HttpClient _httpClient = new HttpClient();

    public LoadGen(ILogger<LoadGen> logger, TelemetryClient telemetryClient)
    {
        _logger = logger;
        _telemetryClient = telemetryClient;

        _httpClient.BaseAddress = new Uri(@"https://todoapi-hb.azurewebsites.net");
    }

    [FunctionName("LoadGen")]
    public async Task Run([TimerTrigger("*/4 * * * * *")]TimerInfo myTimer)
    {
        _logger.LogInformation("Starting loadgen");

        var todoToCreate = new Todo
        {
            Id = Guid.NewGuid(),
            Description = "Stuff, things, and what not more!",
            Title = "Something I have to do"
        };

        var response = await _httpClient.PostAsJsonAsync("/api/todos", todoToCreate);
        response.EnsureSuccessStatusCode();
        var createdTodo = await response.Content.ReadAsAsync<Todo>();

        _telemetryClient
            .GetMetric("Todos Added")
            .TrackValue(1);

        var count = _random.Next(1, 6);

        for (var i = 0; i < count; i++)
        {
            var result = await _httpClient.GetAsync($"/api/todos/{createdTodo.Id}");
            result.EnsureSuccessStatusCode();
        }

        _telemetryClient
            .GetMetric("Todos Added")
            .TrackValue(count);

        var result2 = await _httpClient.GetAsync($"/api/todos");
        result2.EnsureSuccessStatusCode();

        _logger.LogInformation("Completed loadgen");
    }
}