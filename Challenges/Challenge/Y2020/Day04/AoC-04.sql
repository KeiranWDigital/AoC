IF NOT EXISTS (SELECT * FROM [INFORMATION_SCHEMA].[SCHEMATA] AS [S] WHERE [S].[SCHEMA_NAME] = 'AoC')
BEGIN
EXEC sp_executesql N'CREATE SCHEMA AoC'
END
DROP TABLE IF EXISTS [AoC].[AoC_Dec4];
CREATE TABLE [AoC].[AoC_Dec4]
(
    [ID] int IDENTITY,
    [input] varchar(MAX) NOT NULL
);
GO
DROP VIEW IF EXISTS [AoC].[Dec4Bulk];
GO
CREATE VIEW [AoC].[Dec4Bulk]
AS
SELECT  [input]
FROM    [AoC].[AoC_Dec4];
GO

DECLARE @BulkSQL nvarchar(1000);
SET @BulkSQL = N'BULK INSERT AoC.Dec4Bulk
FROM ''F:\ElusiveChaos\Advent of Code\inputFiles\day4.txt''
WITH (
		 FIELDTERMINATOR = '','',
         ROWTERMINATOR = ''' + CHAR(10) + N'''
     );';
EXEC [sys].[sp_executesql] @BulkSQL;

UPDATE  [AoC].[AoC_Dec4]
SET     [input] = REPLACE([input], CHAR(13), '');

DECLARE @StagingTable table
(
    [id] int IDENTITY,
    [input] varchar(MAX) NOT NULL,
    [Passport] int NULL,
    [field] varchar(MAX) NULL,
    [Answer] varchar(MAX) NULL
);

INSERT INTO @StagingTable
(
    [input]
)
SELECT      [SS].[value]
FROM        [AoC].[AoC_Dec4] AS [ACD]
            CROSS APPLY [STRING_SPLIT]([ACD].[input], ' ') AS [SS]
ORDER BY    [ACD].[ID];

UPDATE  [ST]
SET     [ST].[Passport] = [PG].[passport]
FROM    @StagingTable AS [ST]
        CROSS APPLY (
                        SELECT  ROW_NUMBER() OVER (ORDER BY [ST].[id]) AS [passport],
                                [ST].[id] AS [ChangeID],
                                ISNULL([x].[id], 0) AS [start]
                        FROM    @StagingTable AS [ST]
                                OUTER APPLY (
                                                SELECT      TOP (1)
                                                            [ST2].[id]
                                                FROM        @StagingTable AS [ST2]
                                                WHERE       TRIM(REPLACE([ST2].[input], CHAR(13), '')) = ''
                                                            AND [ST2].[id] < [ST].[id]
                                                ORDER BY    [id] DESC
                                            ) AS [x]
                        WHERE   TRIM(REPLACE([ST].[input], CHAR(13), '')) = ''
                    ) AS [PG]
WHERE   [ST].[id] BETWEEN [PG].[start] + 1 AND [PG].[ChangeID];

UPDATE  [ST]
SET     [ST].[Passport] = [l].[passport]
FROM    @StagingTable AS [ST]
        CROSS JOIN (
                       SELECT   MAX([S].[Passport]) + 1 AS [passport],
                                MAX([S].[id]) AS [id]
                       FROM     @StagingTable AS [S]
                       WHERE    TRIM(REPLACE([S].[input], CHAR(13), '')) = ''
                   ) AS [l]
WHERE   [ST].[id] > [l].[id];

UPDATE  [ST]
SET     [ST].[field] = [ACD2].[1],
        [ST].[Answer] = [ACD2].[2]
FROM    @StagingTable AS [ST]
        INNER JOIN (
                       SELECT   *
                       FROM     (
                                    SELECT  *
                                    FROM    @StagingTable AS [IT]
                                            CROSS APPLY (
                                                            SELECT  ROW_NUMBER() OVER (ORDER BY (
                                                                                                    SELECT  NULL
                                                                                                )
                                                                                      ) AS [RowN],
                                                                    [value]
                                                            FROM    STRING_SPLIT([IT].[input], ':')
                                                        ) AS [d]
                                ) AS [src]
                       PIVOT (
                                 MAX([value])
                                 FOR [RowN] IN ([1], [2])
                             ) AS [p]
                   ) AS [ACD2]
            ON [ACD2].[id] = [ST].[id];

SELECT  COUNT(*)
FROM    (
            SELECT      [ST].[Passport]
            FROM        @StagingTable AS [ST]
            WHERE       [ST].[field] IN ('byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid')
            GROUP BY    [ST].[Passport]
            HAVING      COUNT([ST].[id]) = 7
        ) AS [d];

SELECT  COUNT(*)
FROM    (
            SELECT      [ST].[Passport]
            FROM        @StagingTable AS [ST]
            WHERE       [ST].[field] IN ('byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid')
                        AND CASE
                                WHEN [ST].[field] = 'byr'
                                     AND [ST].[Answer] BETWEEN 1920 AND 2002 THEN 1
                                WHEN [ST].[field] = 'iyr'
                                     AND [ST].[Answer] BETWEEN 2010 AND 2020 THEN 1
                                WHEN [ST].[field] = 'eyr'
                                     AND [ST].[Answer] BETWEEN 2020 AND 2030 THEN 1
                                WHEN [ST].[field] = 'hgt'
                                     AND CHARINDEX('in', [ST].[Answer], 1) IS NOT NULL
                                     AND SUBSTRING([ST].[Answer], 1, ISNULL(NULLIF(CHARINDEX('in', [ST].[Answer], 1) - 1, -1), 1)) BETWEEN 59 AND 76 THEN 1
                                WHEN [ST].[field] = 'hgt'
                                     AND CHARINDEX('cm', [ST].[Answer], 1) IS NOT NULL
                                     AND SUBSTRING([ST].[Answer], 1, ISNULL(NULLIF(CHARINDEX('cm', [ST].[Answer], 1) - 1, -1), 1)) BETWEEN 150 AND 193 THEN 1
                                WHEN [ST].[field] = 'hcl'
                                     AND [ST].[Answer] LIKE '%#[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]%' THEN 1
                                WHEN [ST].[field] = 'ecl'
                                     AND [ST].[Answer] IN ('amb', 'blu', 'brn', 'gry', 'grn', 'hzl', 'oth') THEN 1
                                WHEN [ST].[field] = 'PID'
                                     AND TRY_PARSE([ST].[Answer] AS int) IS NOT NULL
                                     AND LEN(TRIM([ST].[Answer])) = 9 THEN 1
                                ELSE 0
                            END = 1
            GROUP BY    [ST].[Passport]
            HAVING      COUNT([ST].[id]) = 7
        ) AS [d];
