IF NOT EXISTS (SELECT * FROM [INFORMATION_SCHEMA].[SCHEMATA] AS [S] WHERE [S].[SCHEMA_NAME] = 'AoC')
BEGIN
EXEC sp_executesql N'CREATE SCHEMA AoC'
END
DROP TABLE IF EXISTS [AoC].[AoC_Dec2];
CREATE TABLE [AoC].[AoC_Dec2]
(
    [ID] int IDENTITY,
    [password] nvarchar(MAX) NOT NULL,
    [minMaxLetter] nvarchar(MAX) NOT NULL,
    [minMax] nvarchar(MAX) NULL,
    [min] int NULL,
    [max] int NULL,
    [letter] char(1) NULL
);
GO
DROP VIEW IF EXISTS [AoC].[Dec2Bulk];
GO
CREATE VIEW [AoC].[Dec2Bulk]
AS
SELECT  [minMaxLetter],
        [password]
FROM    [AoC].[AoC_Dec2];
GO

DECLARE @BulkSQL nvarchar(1000);
SET @BulkSQL = N'BULK INSERT AoC.Dec2Bulk
FROM ''F:\ElusiveChaos\Advent of Code\inputFiles\day2.txt''
WITH (
		 FIELDTERMINATOR = '': '',
         ROWTERMINATOR = ''' + CHAR(10) + N'''
     );';
EXEC [sys].[sp_executesql] @BulkSQL;

UPDATE  [ACD]
SET     [ACD].[letter] = TRIM([ACD2].[2]),
        [ACD].[minMax] = [ACD2].[1]
FROM    [AoC].[AoC_Dec2] AS [ACD]
        INNER JOIN (
                       SELECT   *
                       FROM     (
                                    SELECT  *
                                    FROM    [AoC].[AoC_Dec2] AS [IT]
                                            CROSS APPLY (
                                                            SELECT  ROW_NUMBER() OVER (ORDER BY (
                                                                                                    SELECT  NULL
                                                                                                )
                                                                                      ) AS [RowN],
                                                                    [value]
                                                            FROM    STRING_SPLIT([IT].[minMaxLetter], ' ')
                                                        ) AS [d]
                                ) AS [src]
                       PIVOT (
                                 MAX([value])
                                 FOR [RowN] IN ([1], [2])
                             ) AS [p]
                   ) AS [ACD2]
            ON [ACD2].id = [ACD].id;

UPDATE  [ACD]
SET     [ACD].[max] = TRIM([ACD2].[2]),
        [ACD].[min] = [ACD2].[1]
FROM    [AoC].[AoC_Dec2] AS [ACD]
        INNER JOIN (
                       SELECT   *
                       FROM     (
                                    SELECT  *
                                    FROM    [AoC].[AoC_Dec2] AS [IT]
                                            CROSS APPLY (
                                                            SELECT  ROW_NUMBER() OVER (ORDER BY (
                                                                                                    SELECT  NULL
                                                                                                )
                                                                                      ) AS [RowN],
                                                                    [value]
                                                            FROM    STRING_SPLIT([IT].[minMax], '-')
                                                        ) AS [d]
                                ) AS [src]
                       PIVOT (
                                 MAX([value])
                                 FOR [RowN] IN ([1], [2])
                             ) AS [p]
                   ) AS [ACD2]
            ON [ACD2].id = [ACD].id;;

SELECT  COUNT(*)
FROM    [AoC].[AoC_Dec2] AS [IT]
WHERE   (LEN([IT].[password]) - LEN(REPLACE([IT].[password], [IT].[letter], ''))) BETWEEN [IT].[min] AND [IT].[max];

SELECT  COUNT(*)
FROM    [AoC].[AoC_Dec2] AS [IT]
WHERE   (
            SUBSTRING([IT].[password], [IT].[min], 1) = [IT].[letter]
            AND SUBSTRING([IT].[password], [IT].[max], 1) <> [IT].[letter]
        )
        OR  (
                SUBSTRING([IT].[password], [IT].[min], 1) <> [IT].[letter]
                AND SUBSTRING([IT].[password], [IT].[max], 1) = [IT].[letter]
            );