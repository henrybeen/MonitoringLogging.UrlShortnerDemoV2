using System.Text.Json.Serialization;
using Newtonsoft.Json;

namespace LoggingMonitoring.Api.Model
{
    public class Todo
    {
        [JsonProperty(PropertyName="id")] public Guid Id { get; set; }

        [JsonProperty(PropertyName = "title")] public string Title { get; set; }

        [JsonProperty(PropertyName = "description")] public string Description { get; set; }
    }
}
