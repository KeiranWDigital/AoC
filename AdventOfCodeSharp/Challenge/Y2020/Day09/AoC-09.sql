IF NOT EXISTS (
                  SELECT    *
                  FROM      [INFORMATION_SCHEMA].[SCHEMATA] AS [S]
                  WHERE     [S].[SCHEMA_NAME] = 'AoC'
              )
BEGIN
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA AoC';
END;
DROP TABLE IF EXISTS [AoC].[AoC_Dec9];
CREATE TABLE [AoC].[AoC_Dec9]
(
    [ID] int IDENTITY,
    [input] bigint NOT NULL
);
GO
DROP VIEW IF EXISTS [AoC].[Dec9Bulk];
GO
CREATE VIEW [AoC].[Dec9Bulk]
AS
SELECT  [input]
FROM    [AoC].[AoC_Dec9];
GO

DECLARE @BulkSQL nvarchar(1000);
SET @BulkSQL = N'BULK INSERT AoC.Dec9Bulk
FROM ''F:\ElusiveChaos\Advent of Code\inputFiles\day9.txt''
WITH (
		 FIELDTERMINATOR = '','',
         ROWTERMINATOR = ''' + CHAR(13) + CHAR(10) + N'''
     );';
EXEC [sys].[sp_executesql] @BulkSQL;

SELECT      TOP 1
            *
FROM        [AoC].[AoC_Dec9] AS [ACD]
WHERE       NOT EXISTS (
                           SELECT   *
                           FROM     [AoC].[AoC_Dec9] AS [ACD2]
                                    CROSS JOIN [AoC].[AoC_Dec9] AS [ACD3]
                           WHERE    [ACD2].[ID] < [ACD3].[ID]
                                    AND [ACD].[input] = [ACD2].[input] + [ACD3].[input]
                                    AND [ACD2].[ID] BETWEEN ([ACD].[ID] - 25) AND ([ACD].[ID] - 1)
                                    AND [ACD3].[ID] BETWEEN ([ACD].[ID] - 25) AND ([ACD].[ID] - 1)
                       )
            AND [ACD].[ID] > 25
ORDER BY    [ACD].[ID] ASC;

WITH
[CTE_contiguous] AS
(
    SELECT  [ACD].[input],
            [ACD].[ID],
            [ACD].[input] AS [start],
            [ACD].[input] AS [end],
			id AS startid
    FROM    [AoC].[AoC_Dec9] AS [ACD]
    WHERE   [ACD].[input] <= 90433990
    UNION ALL
    SELECT  [ACD].[input] + [C].[input],
            [ACD].[ID],
            CASE WHEN [ACD].[input] > c.[start] THEN c.[start] ELSE [ACD].[input] end,
            CASE WHEN [ACD].[input] < c.[end] THEN c.[end] ELSE [ACD].[input] END,
			startid
    FROM    [AoC].[AoC_Dec9] AS [ACD]
            INNER JOIN [CTE_contiguous] AS [C]
                ON [ACD].[ID] = [C].[ID] + 1
    WHERE   [ACD].[input] + [C].[input] <= 90433990
)
SELECT  [c].[start] + [c].[end]
FROM    [CTE_contiguous] AS [c]
WHERE [c].[input] = 90433990
AND c.[start] <> c.[end]
OPTION (MAXRECURSION 32767);