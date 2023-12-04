using static Challenges.Challenge.Y2022.Day02.Day02;
using System.Text;
using static Challenges.Challenge.Y2023.Day04.Day04;

namespace Challenges.Challenge.Y2023.Day04
{
    [ChallengeName("Day 4: Scratchcards")]
    public class Day04 : IChallenge
    {
        public class Card
        {
            public int Id;
            public List<int> WinningNumbers = new();
            public List<int> Numbers = new();
            public List<int> MatchedNumbers => (Numbers.Intersect(WinningNumbers).ToList());
            public int Matches => MatchedNumbers.Count;
            public int Score => CalculateScore(Matches);
            public bool Played = false;
        }

        public static class Game
        {
            public static List<Card> cards = new();

        }

        public static int CalculateScore(int matches)
        {
            if (matches == 0) return 0;
            if (matches == 1)
            {
                return 1;
            }

            int score = 1;
            for (int i = 1; i < matches; i++)
            {
                score *= 2;
            }

            return score;
        }

        private static Card ParseCard(string input)
        {
            Card card = new();
            string[] parts = input.Split(':');

            if (parts.Length >= 2)
            {
                if (int.TryParse(parts[0].Substring(parts[0].IndexOf("Card") + 4), out int cardId))
                {
                    card.Id = cardId;
                }
            }

            string[] numbers = parts[1].Split("|");

            string[] scratchNumbers = numbers[0].Split(" ");
            string[] winningNumbers = numbers[1].Split(" ");


            foreach (var winningNumber in winningNumbers)
            {
                if (int.TryParse(winningNumber, out int number))
                {
                    card.WinningNumbers.Add(number);
                }
            }

            foreach (var scratchNumber in scratchNumbers)
            {
                if (int.TryParse(scratchNumber, out int number))
                {
                    card.Numbers.Add(number);
                }
            }

            return card;
        }


        public async Task<object> TaskPartOne(string input)
        {
            List<Card> cards = new();

            var inputCards = input.GetLines();

            foreach (var inputCard in inputCards)
            {
                cards.Add(ParseCard(inputCard));
            }

            return cards.Sum(x => x.Score);
        }


        public async Task<object> TaskPartTwo(string input)
        {
            var inputCards = input.GetLines().ToList();

            int total = 0;

            foreach (var inputCard in inputCards)
            {
                var card = ParseCard(inputCard);
                Game.cards.Add(card);
            }

            var count = Game.cards.Count;

            for (int i = 0; i < count; i++)
            {
                PlayCard(i);
            }

            return Game.cards.Count;
        }

        public static void PlayCard(int index)
        {
            var card = Game.cards[index];

            for (int i = 1; i < card.Matches + 1; i++)
            {
                var copyCard = Game.cards.Find(x => x.Id == card.Id + i);
                Game.cards.Add(copyCard);
                PlayCard(i + index);
            }

        }

    }
}