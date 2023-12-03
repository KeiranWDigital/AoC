IF NOT EXISTS (
                  SELECT    *
                  FROM      [INFORMATION_SCHEMA].[SCHEMATA] AS [S]
                  WHERE     [S].[SCHEMA_NAME] = 'AoC'
              )
BEGIN
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA AoC';
END;
DROP TABLE IF EXISTS [AoC].[AoC_Dec7];
CREATE TABLE [AoC].[AoC_Dec7]
(
    [ID] int IDENTITY,
    [input] varchar(MAX) NOT NULL
);
GO
DROP VIEW IF EXISTS [AoC].[Dec7Bulk];
GO
CREATE VIEW [AoC].[Dec7Bulk]
AS
SELECT  [input]
FROM    [AoC].[AoC_Dec7];
GO

DECLARE @BulkSQL nvarchar(1000);
SET @BulkSQL = N'BULK INSERT AoC.Dec7Bulk
FROM ''F:\ElusiveChaos\Advent of Code\inputFiles\day7.txt''
WITH (
		 FIELDTERMINATOR = '','',
         ROWTERMINATOR = ''' + CHAR(10) + N'''
     );';
EXEC [sys].[sp_executesql] @BulkSQL;

DECLARE @TempStorageTable table
(
    [id] int IDENTITY,
    [groupID] int,
    [input] varchar(MAX)
);

INSERT INTO @TempStorageTable
(
    [groupID],
    [input]
)
SELECT  [ACD].[ID],
        [SS].[value]
FROM    [AoC].[AoC_Dec7] AS [ACD]
        CROSS APPLY [STRING_SPLIT](REPLACE([ACD].[input], 'contain', '#'), '#') AS [SS];

DECLARE @BagsTable table
(
    [id] int,
    [bag] varchar(MAX)
);

INSERT INTO @BagsTable
(
    [id],
    [bag]
)
SELECT  [bags].[ID],
        [TST].[input]
FROM    @TempStorageTable AS [TST]
        INNER JOIN (
                       SELECT   MIN([TST2].[id]) AS [ID]
                       FROM     @TempStorageTable AS [TST2]
                       GROUP BY [TST2].[groupID]
                   ) AS [bags]
            ON [bags].[ID] = [TST].[id];

DECLARE @BagsContainsTable table
(
    [id] int,
    [bag] varchar(MAX),
    [bagID] int,
    [bagCount] int
);

INSERT  @BagsContainsTable
(
    [id],
    [bag]
)
SELECT  [bags].[ID] - 1,
        [SS].[value]
FROM    @TempStorageTable AS [TST]
        INNER JOIN (
                       SELECT   MAX([TST2].[id]) AS [ID]
                       FROM     @TempStorageTable AS [TST2]
                       GROUP BY [TST2].[groupID]
                   ) AS [bags]
            ON [bags].[ID] = [TST].[id]
        CROSS APPLY STRING_SPLIT([TST].[input], ',') AS [SS];

UPDATE  [BCT]
SET     [BCT].[bagID] = [BagID].[id],
        [BCT].[bagCount] = [BagCount].[CountVal]
FROM    @BagsContainsTable AS [BCT]
        OUTER APPLY (
                        SELECT  [BT].[id]
                        FROM    @BagsTable AS [BT]
                        WHERE   [BCT].[bag] LIKE '%' + SUBSTRING([BT].[bag], 1, LEN([BT].[bag]) - 1) + '%'
                    ) AS [BagID]
        OUTER APPLY (
                        SELECT  TRY_PARSE(SUBSTRING(TRIM([BT].[bag]), 1, 1)AS int) AS [CountVal]
                        FROM    @BagsContainsTable AS [BT]
                        WHERE   TRY_PARSE(SUBSTRING(TRIM([BT].[bag]), 1, 1)AS int) IS NOT NULL
                                AND [BT].[id] = [BCT].[id]
                                AND [BT].[bag] = [BCT].[bag]
                    ) AS [BagCount];

WITH
[cteBags] AS
(
    SELECT  [BT2].[bag] AS [Bag]
    FROM    @BagsContainsTable AS [BCT]
            INNER JOIN @BagsTable AS [BT]
                ON [BT].[id] = [BCT].[bagID]
            INNER JOIN @BagsTable AS [BT2]
                ON [BT2].[id] = [BCT].[id]
    WHERE   [BT].[bag] = 'shiny gold bags'
    UNION ALL
    SELECT  [BT2].[bag]
    FROM    @BagsContainsTable AS [BCT]
            INNER JOIN @BagsTable AS [BT]
                ON [BT].[id] = [BCT].[bagID]
            INNER JOIN @BagsTable AS [BT2]
                ON [BT2].[id] = [BCT].[id]
            INNER JOIN [cteBags] AS [c]
                ON [BT].[bag] LIKE '%' + [c].[Bag] + '%'
)
SELECT  COUNT(DISTINCT [cteBags].[Bag])
FROM    [cteBags];

WITH
[cteBagsWithin] AS
(
    SELECT  [BCT].[bagID] AS [innerBagID],
            [BCT].[bagCount] AS [innerBagCount]
    FROM    @BagsContainsTable AS [BCT]
            INNER JOIN @BagsTable AS [BT]
                ON [BT].[id] = [BCT].[id]
    WHERE   [BT].[bag] = 'shiny gold bags'
    UNION ALL
    SELECT  [BCT].[bagID] AS [innerBagID],
            [BCT].[bagCount] * [c].[innerBagCount] AS [innerBagCount]
    FROM    @BagsContainsTable AS [BCT]
            INNER JOIN @BagsTable AS [BT]
                ON [BT].[id] = [BCT].[id]
            INNER JOIN [cteBagsWithin] AS [c]
                ON [c].[innerBagID] = [BCT].[id]
)
SELECT  SUM([cteBagsWithin].[innerBagCount])
FROM    [cteBagsWithin];
