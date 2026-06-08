using Newtonsoft.Json;
using System.Xml;

var patient = new
{
    Id = 1001,
    Name = "A. Sharma",
    Active = true
};

string json = JsonConvert.SerializeObject(patient, Newtonsoft.Json.Formatting.Indented);
Console.WriteLine(json);
