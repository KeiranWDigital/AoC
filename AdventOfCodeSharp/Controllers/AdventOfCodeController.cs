using System.Reflection;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using static System.IO.File;

namespace AdventOfCodeSharp.Controllers;

[Route("[controller]")]
[ApiController]
public class AdventOfCodeController : ControllerBase
{
    private readonly IHostEnvironment _environment;

    public AdventOfCodeController(IHostEnvironment environment)
    {
        _environment = environment;
    }

    [HttpGet]
    [Route("Today")]
    public async Task<Result> DoAoCTask()
    {
        var results = await RunAoCTask(DateTime.Today);
        return results.First();
    }

    [HttpPost]
    [Route("Year")]
    public async Task<IEnumerable<Result>> DoAoCTask(int? year)
    {
        year = year ?? DateTime.Today.Year;
        return await RunAoCTask(new DateTime((int)year, 12, 01), new DateTime((int)year, 12, 25));
    }

    [HttpGet]
    [Route("All")]
    public async Task<IEnumerable<Result>> DoAoCTaskTest()
    {
        return await RunAoCTask(new DateTime(2021,12,01), new DateTime(2030, 12, 25));
    }

    private protected async Task<IEnumerable<Result>> RunAoCTask(DateTime? startDateTime, DateTime? endDateTime = null)
    {
        startDateTime ??= DateTime.Today;
        if (startDateTime.Value.Month != 12 || startDateTime.Value.Day > 25)
            return new Result[] { "You can only play this between 1-25th December" };
        if (startDateTime.Value.Year < 2021 || startDateTime.Value > DateTime.Today)
            return new Result[] { "This project does not support this challenge" };

        var implementedChallengeTypes = Assembly.GetEntryAssembly()!.GetTypes()
            .Where(t => t.GetTypeInfo().IsClass && typeof(IChallenge).IsAssignableFrom(t))
            .OrderBy(t => t.FullName)
            .ToArray();
        var implementedChallenges = GetChallenges(implementedChallengeTypes);

        var results = new List<Result>();

        foreach (var challenge in implementedChallenges.Where(c => ChallengeExtensions.IsChallenge(c.GetType(), startDateTime.Value, endDateTime)))
        {
            var result = await Process(challenge);

            results.Add(result);
        }

        if(results.Count == 0) results.Add(new Result("Challenge Not Implemented Yet"));

        return results;
    }

    private async Task<Result> Process(IChallenge? challenge)
    {
        if (challenge == null) return "Challenge Not Implemented Yet";

        string input;
        await using (var stream = typeof(Program).Assembly.GetManifestResourceStream($"AdventOfCodeSharp.Challenge.{challenge.WorkingDir().Replace("\\",".")}.data.input"))
        using (var reader = new StreamReader(stream))
            input = await reader.ReadToEndAsync();

        var basePath = _environment.ContentRootPath;
        var challengePath = Path.Combine(basePath, "Challenge", challenge.WorkingDir());

        var result = await challenge.CompleteChallenge(input);
        await WriteAllLinesAsync(Path.Combine(challengePath, "result.output"), new[] { JsonConvert.SerializeObject(result, Formatting.Indented) ?? "" });

        return result;
    }

    private static IEnumerable<IChallenge?> GetChallenges(IEnumerable<Type> challenges)
    {
        return challenges.Select(c => Activator.CreateInstance(c) as IChallenge).ToArray();
    }
}