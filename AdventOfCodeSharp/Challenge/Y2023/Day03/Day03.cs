using Microsoft.AspNetCore.Http.Features;
using System.Security.Cryptography.X509Certificates;

namespace AdventOfCodeSharp.Challenge.Y2023.Day03
{

    public record coord(int x, int y);

    public class PartNumber
    {
        public List<coord> coords { get; set; }
        public int partNumber { get; set; }

        public PartNumber(List<coord> coords, int partNumber)
        {
            this.coords = coords;
            this.partNumber = partNumber;
        }

    }

    

    [ChallengeName("Day 3: Gear Ratios")]
    public class Day03 : IChallenge
    {
        public async Task<object> TaskPartOne(string input)
        {
            List<PartNumber> partNumbers = GetPartNumbers(input);

            return partNumbers.Sum(x => x.partNumber);

        }

        private List<PartNumber> GetPartNumbers(string input)
        {
            var partNumbers = new List<PartNumber>();

            List<string> lines = input.GetLines().ToList();
            List<coord> coords = new List<coord>();
            string currentItem = "";
            bool isPartNumber = false;

            for (int y = 0; y < lines.Count; y++)
            {
                if (isPartNumber)
                {
                    partNumbers.Add(new PartNumber(coords, int.Parse(currentItem)));
                }

                currentItem = "";
                isPartNumber = false;
                coords = new List<coord>();
                var line = lines[y];

                for (int x = 0; x < line.Length; x++)
                {
                    if (int.TryParse(line[x].ToString(), out int digit))
                    {
                        //the character is a digit
                        currentItem += digit;
                        coords.Add(new coord(x, y));


                        //does it have a symbol next to it?

                        if (y != 0)
                        { //not the first line
                          //above left

                            if (x != 0)
                            {
                                //not the first char
                                if (IsSymbol(lines[y - 1][x - 1]))
                                    isPartNumber = true;
                            }

                            //above 
                            if (IsSymbol(lines[y - 1][x]))
                                isPartNumber = true;

                            //above right
                            if (x < line.Length - 1)
                            {
                                //not the last char
                                if (IsSymbol(lines[y - 1][x + 1]))
                                    isPartNumber = true;
                            }
                        }
                        if (x != 0)
                        {
                            //not the first char
                            if (IsSymbol(lines[y][x - 1]))
                                isPartNumber = true;
                        }

                        if (x < line.Length - 1)
                        {
                            //not the last char
                            if (IsSymbol(lines[y][x + 1]))
                                isPartNumber = true;
                        }

                        if (y < lines.Count() - 1)
                        {
                            //not the last line
                            if (x != 0)
                            {
                                //not the first char
                                //below left
                                if (IsSymbol(lines[y + 1][x - 1]))
                                    isPartNumber = true;
                            }

                            //below 
                            if (IsSymbol(lines[y + 1][x]))
                                isPartNumber = true;

                            //below right
                            if (x < line.Length - 1)
                            {
                                //not the last char
                                if (IsSymbol(lines[y + 1][x + 1]))
                                    isPartNumber = true;
                            }
                        }

                    }
                    else
                    {
                        if (isPartNumber)
                        {
                            partNumbers.Add(new PartNumber(coords, int.Parse(currentItem)));
                        }

                        currentItem = "";
                        isPartNumber = false;
                        coords = new List<coord>();

                        currentItem = "";
                        isPartNumber = false;
                    }
                }



            }

            return partNumbers;
        }

        private bool IsSymbol(char x)
        {
            if (x == '.') return false;
            if (char.IsLetterOrDigit((char)x)) return false;
            return true;
        }


        public async Task<object> TaskPartTwo(string input)
        {
            int total = 0;

            Char[][] lines = input.GetLines().Select(x => x.ToCharArray()).ToArray();

            List<PartNumber> partNumbers = GetPartNumbers(input);

            for (int y = 0; y < lines.Length; y++)
            {
                for (int x = 0; x < lines[y].Length; x++)
                {
                    if (lines[y][x] == '*')
                    {
                        List<coord> coords =
                        [
                            new coord(x - 1, y - 1),
                            new coord(x, y - 1),
                            new coord(x + 1, y - 1),
                            new coord(x - 1, y + 1),
                            new coord(x, y + 1),
                            new coord(x + 1, y + 1),
                            new coord(x - 1, y),
                            new coord(x + 1, y),
                        ];

                        var matchingNumbers = partNumbers.FindAll(x => x.coords.Intersect(coords).Any());
                        if(matchingNumbers.Count == 2)
                        {
                            int multiplied = matchingNumbers[0].partNumber * matchingNumbers[1].partNumber;
                            total += multiplied;
                        }
                      
                    }
                }
            }

            return total;
            }
        }
    }
