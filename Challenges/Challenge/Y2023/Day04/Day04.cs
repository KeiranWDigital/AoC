
namespace Challenges.Challenge.Y2023.Day04
{
    [ChallengeName("Day 4: Scratchcards")]
    public class Day0 : IChallenge
    {
        public class Card
        {
            public int Id;
            public List<int> WinningNumbers = new();
            public List<int> Numbers = new();
            public List<int> MatchedNumbers => (Numbers.Intersect(WinningNumbers).ToList());
            public int Matches => MatchedNumbers.Count;
            public int Score => CalculateScore(Matches);
        }

        public static class Game
        {
            public static List<Card> cards = new();
        }

        public static int CalculateScore(int matches)
        {
            switch (matches)
            {
                case 0:
                    return 0;
                case 1:
                    return 1;
            }

            var score = 1;
            for (var i = 1; i < matches; i++)
            {
                score *= 2;
            }

            return score;
        }

        private static Card ParseCard(string input)
        {
            Card card = new();
            var parts = input.Split(':');

            if (parts.Length >= 2)
            {
                if (int.TryParse(parts[0][(parts[0].IndexOf("Card") + 4)..], out var cardId))
                {
                    card.Id = cardId;
                }
            }

            var numbers = parts[1].Split("|");

            var scratchNumbers = numbers[0].Split(" ");
            var winningNumbers = numbers[1].Split(" ");

            foreach (var winningNumber in winningNumbers)
            {
                if (int.TryParse(winningNumber, out var number))
                {
                    card.WinningNumbers.Add(number);
                }
            }

            foreach (var scratchNumber in scratchNumbers)
            {
                if (int.TryParse(scratchNumber, out var number))
                {
                    card.Numbers.Add(number);
                }
            }

            return card;
        }


        public async Task<object> TaskPartOne(string input)
        {
            var inputCards = input.GetLines();

            var cards = inputCards.Select(ParseCard).ToList();

            return cards.Sum(x => x.Score);
        }


        public async Task<object> TaskPartTwo(string input)
        {
            var inputCards = input.GetLines().ToList();

            foreach (var inputCard in inputCards)
            {
                var card = ParseCard(inputCard);
                Game.cards.Add(card);
            }

            var count = Game.cards.Count;

            for (var i = 0; i < count; i++)
            {
                PlayCard(i);
            }

            return Game.cards.Count;
        }

        public static void PlayCard(int index)
        {
            var card = Game.cards[index];

            for (var i = 1; i < card.Matches + 1; i++)
            {
                var copyCard = Game.cards.Find(x => x.Id == card.Id + i);
                Game.cards.Add(copyCard);
                PlayCard(i + index);
            }
        }
    }
}