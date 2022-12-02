IF NOT EXISTS (
                  SELECT    *
                  FROM      [INFORMATION_SCHEMA].[SCHEMATA] AS [S]
                  WHERE     [S].[SCHEMA_NAME] = 'AoC22'
              )
BEGIN
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA AoC22';
END;
DROP TABLE IF EXISTS [AoC22].[AoC_Dec02];
CREATE TABLE [AoC22].[AoC_Dec02]
(
    [ID] int IDENTITY,
    [input] nvarchar(MAX) NULL,
    Opponent char(1) NULL,
    GameBook char(1) NULL
);
GO
DROP VIEW IF EXISTS [AoC22].[Dec02Bulk];
GO
CREATE VIEW [AoC22].[Dec02Bulk]
AS
SELECT  [input]
FROM    [AoC22].[AoC_Dec02];
GO
DECLARE @Path nvarchar(MAX) = N'K:\Development\AoCSharp';
DECLARE @BulkSQL nvarchar(1000);
SET @BulkSQL = N'BULK INSERT AoC22.Dec02Bulk
FROM ''' + @Path + N'\AdventOfCodeSharp\Challenge\Y2022\Day02\data.input''
WITH (
		 FIELDTERMINATOR = '','',
         ROWTERMINATOR = ''' + CHAR(13) + CHAR(10) + N'''
     );';
EXEC [sys].[sp_executesql] @BulkSQL;

UPDATE  a
SET     a.Opponent = PivotTables.Opponent,
        a.GameBook = PivotTables.Gamebook
FROM    (
            SELECT  PVT.ID,
                    PVT.[2] AS Gamebook,
                    PVT.[1] AS Opponent
            FROM    (
                        SELECT  ACD.ID,
                                S.value,
                                ROW_NUMBER() OVER (PARTITION BY ACD.ID
                                                   ORDER BY ACD.ID
                                                  ) AS RowNo
                        FROM    [AoC22].[AoC_Dec02] AS [ACD]
                                CROSS APPLY STRING_SPLIT(ACD.input, ' ') S
                    ) AS P
            PIVOT (
                      MAX(value)
                      FOR RowNo IN ([1], [2])
                  ) AS PVT
        ) AS PivotTables
        INNER JOIN [AoC22].[AoC_Dec02] a
            ON a.ID = PivotTables.ID;


			--A/X ROCK
			--B/Y Paper
			--C/Z Scisorrs
SELECT SUM(GameResult)
FROM (
SELECT  CASE
            WHEN Opponent = 'A'
                 AND GameBook = 'X' THEN 3
            WHEN Opponent = 'B'
                 AND GameBook = 'Y' THEN 3
			WHEN Opponent = 'C'
                 AND GameBook = 'Z' THEN 3
            WHEN Opponent = 'A'
                 AND GameBook = 'Y' THEN 6
			WHEN Opponent = 'B'
                 AND GameBook = 'Z' THEN 6
            WHEN Opponent = 'C'
                 AND GameBook = 'X' THEN 6
			ELSE 0
        END + CASE WHEN GameBook = 'X' THEN 1
		WHEN GameBook = 'Y' THEN 2
		WHEN GameBook = 'Z' THEN 3 END AS GameResult
FROM    aoc22.AoC_Dec02) AS A


SELECT SUM(GameResult)
FROM (
SELECT  CASE
            WHEN Opponent = myHand THEN 3
            WHEN Opponent = 'A' AND myHand = 'B' THEN 6
			WHEN Opponent = 'B' AND myHand = 'C' THEN 6
			WHEN Opponent = 'C' AND myHand = 'A' THEN 6
			ELSE 0
        END + CASE WHEN b.myHand = 'A' THEN 1
		WHEN myHand = 'B' THEN 2
		WHEN myHand = 'C' THEN 3 END AS GameResult
FROM    aoc22.AoC_Dec02 a
        JOIN (
                 SELECT CASE
                            WHEN Opponent = 'A'
                                 AND   GameBook = 'X' THEN 'C'
                            WHEN Opponent = 'B'
                                 AND   GameBook = 'X' THEN 'A'
                            WHEN Opponent = 'C'
                                 AND   GameBook = 'X' THEN 'B'
                            WHEN Opponent = 'A'
                                 AND   GameBook = 'Z' THEN 'B'
                            WHEN Opponent = 'B'
                                 AND   GameBook = 'Z' THEN 'C'
                            WHEN Opponent = 'C'
                                 AND   GameBook = 'Z' THEN 'A'
                            WHEN GameBook = 'Y' THEN Opponent
                        END AS myHand,
                        ID
                 FROM   aoc22.AoC_Dec02
             ) b
            ON a.ID = b.ID) AS res









