

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
            /*public Dictionary<Int64,Int64> Items => GetItems(MapItems);*/
            public Int64 Convert(Int64 number)
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
            public Int64 SourceId { get; set; }
            public Int64 DestinationId { get; set; }

            public Int64 Difference => (DestinationId - SourceId);
            public Int64 Range { get; set; }

            public bool IsInMapItem(Int64 number)
            {
                if(number >= SourceId && number <= SourceId + Range) return true;

                return false;
            }
        }

        private static Dictionary<Int64, Int64> GetItems(List<MapItem> MapItems)
        {
            Dictionary<Int64, Int64> items = new();
            foreach (var item in MapItems)
            {
                for(Int64 i=0;i < item.Range;i++)
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

            var seeds = new List<Int64>();

            var seedParts = inputLines[0].Split(":")[1].Trim().Split(" ");

            foreach(var seed in seedParts)
            {
                if (Int64.TryParse(seed, out Int64 seedid))
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
                        DestinationId = Int64.Parse(mapItemsParts[0]),
                        SourceId = Int64.Parse(mapItemsParts[1]),
                        Range = Int64.Parse(mapItemsParts[2])
                    });
                }

            }
            List<Int64> locations = new List<Int64>();

            foreach (var seed in seeds)
            {

                Map mapToUse;

                Int64 nextNumber = seed;

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


        public async Task<object> TaskPartTwo(string input)
        {
            return 0;
        }

    }
}