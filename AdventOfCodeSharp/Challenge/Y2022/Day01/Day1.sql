IF NOT EXISTS (
                  SELECT    *
                  FROM      [INFORMATION_SCHEMA].[SCHEMATA] AS [S]
                  WHERE     [S].[SCHEMA_NAME] = 'AoC22'
              )
BEGIN
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA AoC22';
END;
DROP TABLE IF EXISTS [AoC22].[AoC_Dec1];
CREATE TABLE [AoC22].[AoC_Dec1]
(
    [ID] int IDENTITY,
    [number] int NULL
);
GO
DROP VIEW IF EXISTS [AoC22].[Dec1Bulk];
GO
CREATE VIEW [AoC22].[Dec1Bulk]
AS
SELECT  [number]
FROM    [AoC22].[AoC_Dec1];
GO
DECLARE @Path nvarchar(max) = 'D:\Source Control\GitHub\AoCSharp'
DECLARE @BulkSQL nvarchar(1000);
SET @BulkSQL = N'BULK INSERT AoC22.Dec1Bulk
FROM '''+@path+'\AdventOfCodeSharp\Challenge\Y2022\Day01\data.input''
WITH (
		 FIELDTERMINATOR = '','',
         ROWTERMINATOR = ''' + CHAR(13) + CHAR(10) + N'''
     );';
EXEC [sys].[sp_executesql] @BulkSQL;

INSERT  [AoC22].[AoC_Dec1]
(
    [number]
)
VALUES
(
    NULL
); -- Makes easier life


WITH
[elfSnacks] AS
(
    SELECT  [ACD].[ID] AS [elf]
    FROM    [AoC22].[AoC_Dec1] AS [ACD]
    WHERE   [ACD].[number] IS NULL
),
[elves] AS
(
    SELECT  LAG([elfSnacks].[elf], 1, 0) OVER (ORDER BY [elfSnacks].[elf]) AS [start],
            [elfSnacks].[elf] AS [end]
    FROM    [elfSnacks]
)
SELECT      TOP 1
            [e].[start] + 1 AS [elf],
            SUM([ACD].[number])
FROM        [elves] AS [e]
            INNER JOIN [AoC22].[AoC_Dec1] AS [ACD]
                ON [ACD].[ID] < [e].[end]
                   AND [ACD].[ID] > [e].[start]
GROUP BY    [e].[start]
ORDER BY    SUM([ACD].[number]) DESC;


WITH
[elfSnacks] AS
(
    SELECT  [ACD].[ID] AS [elf]
    FROM    [AoC22].[AoC_Dec1] AS [ACD]
    WHERE   [ACD].[number] IS NULL
),
[elves] AS
(
    SELECT  LAG([elfSnacks].[elf], 1, 0) OVER (ORDER BY [elfSnacks].[elf]) AS [start],
            [elfSnacks].[elf] AS [end]
    FROM    [elfSnacks]
), Top3 AS (
SELECT      TOP 3
            [e].[start] + 1 AS [elf],
            SUM([ACD].[number]) AS SnacksCalories
FROM        [elves] AS [e]
            INNER JOIN [AoC22].[AoC_Dec1] AS [ACD]
                ON [ACD].[ID] < [e].[end]
                   AND [ACD].[ID] > [e].[start]
GROUP BY    [e].[start]
ORDER BY    SUM([ACD].[number]) DESC
)

SELECT SUM(SnacksCalories) FROM top3