namespace AdventOfCodeSharp.Challenge.Y2022.Day01
{
    public class Day01 : IChallenge
    {
        public async Task<object> TaskPartOne(string input) => await calculateCalories(ChallengeExtensions.GetNumberEnumerableIncNull(input));
        public async Task<object> TaskPartTwo(string input) => await calculateCaloriesTopThree(ChallengeExtensions.GetNumberEnumerableIncNull(input));


        public async Task<object> calculateCalories(IEnumerable<int?> challenge)
        {
            int elf = 1;
            int elfVal = 0;
            int highest = 0;
            int highestelf = 0;
            foreach (var challengeItem in challenge)
            {
                if (challengeItem != null)
                {
                    elfVal += challengeItem.Value;
                    
                    continue;
                }

                if (elfVal > highest)
                {
                    highest = elfVal;
                    highestelf = elf;
                }

                elfVal = 0;
                elf++;

            }

            return highest;
        }

        public async Task<object> calculateCaloriesTopThree(IEnumerable<int?> challenge)
        {

            var elves = new List<int>();
            int elfVal = 0;
            foreach (var challengeItem in challenge)
            {
                if (challengeItem != null)
                {
                    elfVal += challengeItem.Value;

                    continue;
                }

                elves.Add(elfVal);
                elfVal = 0;
            }
            elves.Add(elfVal);


            return elves.OrderByDescending(i => i).Take(3).Sum(x => x);
        }

    }
}
