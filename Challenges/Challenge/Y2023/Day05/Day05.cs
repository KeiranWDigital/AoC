

using Challenges.Util;
using System.Linq;
using System.Reflection.Metadata;

namespace Challenges.Challenge.Y2023.Day05
{
    [ChallengeName("Day 5: If You Give A Seed A Fertilizer")]
    public class Day05 : IChallenge
    {
        private class Map
        {
            public List<MapItem> MapItems = new();
            public string SourceName { get; set; }
            public string DestinationName { get; set; }
            public long Convert(long number)
            {
                foreach (var item in MapItems)
                {
                    if(item.IsInMapItem(number)) return number + item.Difference;
                }

                return number;

            }
        }

        private class MapItem
        {
            public long SourceId { get; set; }
            public long DestinationId { get; set; }

            public long Difference => (DestinationId - SourceId);
            public long Range { get; set; }

            public bool IsInMapItem(long number)
            {
                if(number >= SourceId && number <= SourceId + Range) return true;

                return false;
            }
        }

        private static Dictionary<long, long> GetItems(List<MapItem> MapItems)
        {
            Dictionary<long, long> items = new();
            foreach (var item in MapItems)
            {
                for(long i=0;i < item.Range;i++)
                {
                    items.Add(item.SourceId + i, item.DestinationId + i);
                }
            }

            return items;
        }

        public async Task<object> TaskPartOne(string input)
        {
            var inputLines = input.GetLines().ToList();

            var maps = new Dictionary<string,Map>();

            var seeds = new List<long>();

            var seedParts = inputLines[0].Split(":")[1].Trim().Split(" ");

            foreach(var seed in seedParts)
            {
                if (long.TryParse(seed, out long seedid))
                {
                    seeds.Add(seedid);
                }
            }

            inputLines.RemoveAt(0);

            var currentMapName = "";

            foreach (var line in inputLines)
            {
                if(line == "") continue;

                if (line.Contains("map"))
                {

                    var mapParts = line.Split("-");
                    var map = new Map()
                    {
                        SourceName = mapParts[0],
                        DestinationName = mapParts[2].Split(" ")[0]
                    };
                    maps.Add(mapParts[0],map);
                    currentMapName = mapParts[0];
                    continue;
                }

                var mapItemsParts = line.Split(" ");
                if (mapItemsParts.Length == 3)
                {
                    maps[currentMapName].MapItems.Add(new MapItem()
                    {
                        DestinationId = long.Parse(mapItemsParts[0]),
                        SourceId = long.Parse(mapItemsParts[1]),
                        Range = long.Parse(mapItemsParts[2])
                    });
                }

            }
            List<long> locations = new List<long>();

            foreach (var seed in seeds)
            {

                Map mapToUse;

                long nextNumber = seed;

                string[] categories = { "seed","soil", "fertilizer", "water", "light", "temperature", "humidity" };

                foreach (var category in categories)
                {
                    mapToUse = maps[category];

                    nextNumber = mapToUse.Convert(nextNumber);
                }

                //nextNumber should be location by now

                locations.Add(nextNumber);

            }

            return locations.Min();
        }

        public class SeedPart
        {
            public long Start { get; set; }
            public long Range { get;set; }
        }

        public async Task<object> TaskPartTwo(string input)
        {
            var min = long.MaxValue;
            var inputLines = input.GetLines().ToList();

            var maps = new Dictionary<string, Map>();

            var locations = new List<long>();

            var seedParts = inputLines[0].Split(":")[1].Trim().Split(" ");
            inputLines.RemoveAt(0);

            var currentMapName = "";

            List<SeedPart> objSeedParts = new List<SeedPart>();

            for (var i = 0; i < seedParts.Length; i += 2)
            {
                var seedStart = long.Parse(seedParts[i]);
                var seedRange = long.Parse(seedParts[i + 1]);
                objSeedParts.Add(new SeedPart()
                {
                    Start = seedStart,
                    Range = seedRange
                });
            }

            
            foreach (var line in inputLines)
            {
                if (line == "") continue;

                if (line.Contains("map"))
                {

                    var mapParts = line.Split("-");
                    var map = new Map()
                    {
                        SourceName = mapParts[0],
                        DestinationName = mapParts[2].Split(" ")[0]
                    };
                    maps.Add(mapParts[0], map);
                    currentMapName = mapParts[0];
                    continue;
                }

                var mapItemsParts = line.Split(" ");
                if (mapItemsParts.Length == 3)
                {
                    maps[currentMapName].MapItems.Add(new MapItem()
                    {
                        DestinationId = long.Parse(mapItemsParts[0]),
                        SourceId = long.Parse(mapItemsParts[1]),
                        Range = long.Parse(mapItemsParts[2])
                    });
                }
            }


            int numThreads = objSeedParts.Count / 2;

            // Array to hold the threads
            Thread[] threads = new Thread[numThreads];

            for (int i = 0; i < numThreads; i++)
            {
                threads[i]=(new Thread(new ParameterizedThreadStart(Calculate)));
                threads[i].Start(i.ToString());
            }

            // Wait for all threads to complete
            for (int i = 0; i < numThreads; i++)
            {
                threads[i].Join();
            }

            return locations.Min();

            void Calculate(object number)
            {
                var i = int.Parse(number.ToString());
                for (var j = objSeedParts[i].Start; j < objSeedParts[i].Start + objSeedParts[i].Range; j++)
                {
                    {
                        Map mapToUse;

                        long nextNumber = j;

                        string[] categories =
                            { "seed", "soil", "fertilizer", "water", "light", "temperature", "humidity" };

                        foreach (var category in categories)
                        {
                            mapToUse = maps[category];

                            nextNumber = mapToUse.Convert(nextNumber);
                        }

                        lock (locations)
                        {
                            locations.Add(nextNumber);
                        }
                    }
                }
            }
        }

       

    }
}