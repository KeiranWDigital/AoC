namespace AdventOfCodeSharp.Util
{
    public class Result
    {
        public Result(string challengeName, object? partOne = null, object? partTwo = null, DateTime date = default)
        {
            ChallengeName = challengeName;
            PartOne = partOne;
            PartTwo = partTwo;
            Date = date;
        }

        public static implicit operator Result(string result) => new(result);

        public string ChallengeName { get; set; }
        public object? PartOne { get; set; }
        public object? PartTwo { get; set; }
        public DateTime Date { get; set; }
    }
}
