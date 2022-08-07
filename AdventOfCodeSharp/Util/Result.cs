namespace AdventOfCodeSharp.Util
{
    public class Result
    {
        public Result(string challengeName, object? partOne = null, object? partTwo = null)
        {
            ChallengeName = challengeName;
            PartOne = partOne;
            PartTwo = partTwo;
        }

        public static implicit operator Result(string result) => new(result);

        public string ChallengeName { get; set; }
        public object? PartOne { get; set; }
        public object? PartTwo { get; set; }

    }
}
