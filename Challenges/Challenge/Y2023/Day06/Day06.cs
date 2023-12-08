

namespace Challenges.Challenge.Y2023.Day06
{
    [ChallengeName("Day 6: Wait For It")]
    public class Day06 : IChallenge
    {
        public class RaceRecord
        {
            public int TotalTime { get; set; }
            public int Record { get; set; }
        }

        public static List<RaceRecord> ParseInput(string timeInput, string distanceInput)
        {
            var times = timeInput.Split(' ').Where(x => x != "" ).ToList();
            var distances = distanceInput.Split(' ').Where(x => x != "").ToList();

            var records = new List<RaceRecord>();

             for (int i = 0; i < records.Count; i++)
             {
                  records.Add(new RaceRecord { TotalTime = int.Parse(times[i]), Record = int.Parse(distances[i]) });
             }
            
            return records;
        }

        public async Task<object> TaskPartOne(string input)
        {
            var totalTimes = input.GetLines().ToList()[0].Split(":")[1].Trim();
            var records = input.GetLines().ToList()[1].Split(":")[1].Trim();
            List<RaceRecord> recordList = ParseInput(totalTimes, records);

           


            return 1;
        }


        public async Task<object> TaskPartTwo(string input)
        {
            return 1;
        }

        
    }
}