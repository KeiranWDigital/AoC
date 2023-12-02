namespace AdventOfCodeSharp.Challenge.Y2023.Day02;

//Invoked Implicitly
[ChallengeName("Day 2: Cube Conundrum")]
public class Day02 : IChallenge
{

    private class Round
    {
        public int green { get; set; }
        public int blue { get; set; }
        public int red { get; set; }
    }

    private class Game
    {
        public int id { get; set; }
        public List<Round> rounds { get; set; }

        public int green => rounds.Max(x => x.green);
        public int blue => rounds.Max(x => x.blue);
        public int red => rounds.Max(x => x.red);
        public int power => red * green * blue;
        public Game()
        {
            rounds = [];
        }
    }

    private static Game ParseGame(string input)
    {
            Game game = new();
            string[] parts = input.Split(':');

            if (parts.Length >= 2)
            {
                if (int.TryParse(parts[0].Substring(parts[0].IndexOf("Game") + 4), out int gameId))
                {
                    game.id = gameId;
                }

                string[] roundStrings = parts[1].Split(';');

                foreach (string roundString in roundStrings)
                {
                    Round round = new Round();
                    string[] colors = roundString.Split(',');

                    round.blue = 0; 
                    round.red = 0;
                    round.green = 0;

                    foreach (string color in colors)
                    {
                        string[] colorParts = color.Trim().Split(' ');

                        if (colorParts.Length == 2 && int.TryParse(colorParts[0], out int count))
                        {
                            switch (colorParts[1])
                            {
                                case "green":
                                    round.green = count;
                                    break;
                                case "blue":
                                    round.blue = count;
                                    break;
                                case "red":
                                    round.red = count;
                                    break;
                            }
                        }
                    }

                    game.rounds.Add(round);
                }

            }

        return game;
    }

    public async Task<object> TaskPartOne(string input)
    {

        var allowedRed = 12;
        var allowedGreen = 13;
        var allowedBlue = 14;

        var inputArray = input.Split("\r\n");

        List<Game> games = new List<Game>();

        int total = 0;

        foreach (var game in inputArray)
        {
            var gameObj = ParseGame(game);
            games.Add(gameObj);
            var red = gameObj.red;
            var green = gameObj.green;
            var blue = gameObj.blue;

            if (green <= allowedGreen && blue <= allowedBlue && red <= allowedRed)
            {
                total += gameObj.id;
            }

        }

        return total;
    }

    public async Task<object> TaskPartTwo(string input)
    {

        var inputArray = input.Split("\r\n");

        List<Game> games = new List<Game>();

        int total = 0;

        foreach (var game in inputArray)
        {
            var gameObj = ParseGame(game);
            games.Add(gameObj);
            var red = gameObj.red;
            var green = gameObj.green;
            var blue = gameObj.blue;

            total += gameObj.power;
        }

        return total;
    }
}
