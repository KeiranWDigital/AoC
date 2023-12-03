namespace Challenges.Challenge.Y2023.Day01;

//Invoked Implicitly
[ChallengeName("Day 1: Trebuchet?!")]
public class Day01 : IChallenge
{


    public async Task<object> TaskPartOne(string input)
    {

        var inputArray = input.Split("\r\n");

        int total = 0;

        foreach (var s in inputArray)
        {
            char firstDigit = s.FirstOrDefault(char.IsDigit);
            char lastDigit = s.LastOrDefault(char.IsDigit);

            string numberToSum = firstDigit + lastDigit.ToString();

            total += int.Parse(numberToSum);
        }

        return total;
    }

    public async Task<object> TaskPartTwo(string input)
    {
        string[] digits = new string[] { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

        var inputArray = input.Split("\r\n");

        int total = 0;

        foreach (var s in inputArray)
        {

            int minDigitIndex = int.MaxValue;
            int maxDigitIndex = int.MinValue;
            int firstDigit = 0;
            int lastDigit = 0;

            for (int i = 0; i < digits.Length; i++)
            {
                string digit = digits[i];

                int index = s.IndexOf(digits[i]);

                if (index < minDigitIndex && index != -1)
                {
                    minDigitIndex = index;
                    firstDigit = int.Parse(i > 9 ? digits[i - 10] : digits[i]);
                }

                int lastIndex = s.LastIndexOf(digits[i]);

                if (lastIndex <= maxDigitIndex || lastIndex == -1) continue;
                maxDigitIndex = lastIndex;

                lastDigit = int.Parse(i > 9 ? digits[i - 10] : digits[i]);
            }

            string numberToSum = firstDigit + lastDigit.ToString();

            total += int.Parse(numberToSum);
        }

        return total;
    }
}
