namespace AdventOfCodeSharp.Challenge.Y2022.Day02
{
    [ChallengeName("Day 02: Rock Paper Scissors")]
    public class Day02: IChallenge
    {
        public async Task<object> TaskPartOne(string input) => await RockPaperScissors(input, true);

        public async Task<object> TaskPartTwo(string input) => await RockPaperScissors(input, false);

        public async Task<object> RockPaperScissors(string input, bool plan)
        {
            var rps = input.Split("\r\n", StringSplitOptions.RemoveEmptyEntries).Select(x => x.Split(" ", StringSplitOptions.RemoveEmptyEntries).ToArray()).ToArray();

            return rps.Select(x => Score(x, plan)).Sum();
        }

        public int Score(string[] hand, bool plan)
        {
            var opponent = hand[0] switch
            {
                "A" => Game.Rock,
                "B" => Game.Paper,
                "C" => Game.Scissors
            };

            var myHand = hand[1] switch
            {
                "X" => plan switch
                {
                    true => Game.Rock,
                    false when Equals(opponent, Game.Rock) => Game.Scissors,
                    false when Equals(opponent, Game.Paper) => Game.Rock,
                    false when Equals(opponent, Game.Scissors) => Game.Paper
                },
                "Y" => plan switch
                {
                    true => Game.Paper,
                    false when Equals(opponent, Game.Rock) => Game.Rock,
                    false when Equals(opponent, Game.Paper) => Game.Paper,
                    false when Equals(opponent, Game.Scissors) => Game.Scissors
                },
                "Z" => plan switch
                {
                    true => Game.Scissors,
                    false when Equals(opponent, Game.Rock) => Game.Paper,
                    false when Equals(opponent, Game.Paper) => Game.Scissors,
                    false when Equals(opponent, Game.Scissors) => Game.Rock
                }
            };
            return myHand switch
            {
                var x when Equals(myHand, opponent) => (int)Game.Draw + (int)myHand,
                Game.Rock when Equals(opponent, Game.Scissors) => (int)Game.Win + (int)myHand,
                Game.Paper when Equals(opponent, Game.Rock) => (int)Game.Win + (int)myHand,
                Game.Scissors when Equals(opponent, Game.Paper) => (int)Game.Win + (int)myHand,
                _ => (int)Game.Loss + (int)myHand
            };
        }

        public enum Game
        {
            Rock = 1,
            Paper = 2,
            Scissors = 3,
            Win = 6,
            Loss = 0,
            Draw = 3
        }
    }
}
