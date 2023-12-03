IF NOT EXISTS (
                  SELECT    *
                  FROM      [INFORMATION_SCHEMA].[SCHEMATA] AS [S]
                  WHERE     [S].[SCHEMA_NAME] = 'AoC'
              )
BEGIN
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA AoC';
END;
DROP TABLE IF EXISTS [AoC].[AoC_Dec6];
CREATE TABLE [AoC].[AoC_Dec6]
(
    [ID] int IDENTITY,
    [input] varchar(MAX) NOT NULL,
    [OriginalInput] varchar(MAX) NULL
);
GO
DROP VIEW IF EXISTS [AoC].[Dec6Bulk];
GO
CREATE VIEW [AoC].[Dec6Bulk]
AS
SELECT  [input]
FROM    [AoC].[AoC_Dec6];
GO

DECLARE @BulkSQL nvarchar(1000);
SET @BulkSQL = N'BULK INSERT AoC.Dec6Bulk
FROM ''F:\ElusiveChaos\Advent of Code\inputFiles\day6.txt''
WITH (
		 FIELDTERMINATOR = '','',
         ROWTERMINATOR = ''' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + N'''
     );';
EXEC [sys].[sp_executesql] @BulkSQL;

UPDATE  [AoC].[AoC_Dec6]
SET     [input] = REPLACE([input], CHAR(13) + CHAR(10), ''),
        [OriginalInput] = REPLACE([input], CHAR(13), '');

WITH
[LetterSplitCTE] AS
(
    SELECT  [ACD].[ID],
            SUBSTRING([ACD].[input], [V].[number] + 1, 1) AS [Letter]
    FROM    [AoC].[AoC_Dec6] AS [ACD]
            INNER JOIN [master].[dbo].[spt_values] AS [V]
                ON [V].[number] < LEN([ACD].[input])
    WHERE   [V].[type] = 'P'
)
SELECT  SUM([CG].[CountNum])
FROM    (
            SELECT      COUNT(DISTINCT [LG].[Letter]) AS [CountNum]
            FROM        [LetterSplitCTE] AS [LG]
            GROUP BY    [LG].[ID]
        ) AS [CG];

WITH
[LetterSplitCTE] AS
(
    SELECT  [ACD].[ID],
            SUBSTRING([ACD].[input], [V].[number] + 1, 1) AS [Letter]
    FROM    [AoC].[AoC_Dec6] AS [ACD]
            INNER JOIN [master].[dbo].[spt_values] AS [V]
                ON [V].[number] < LEN([ACD].[input])
    WHERE   [V].[type] = 'P'
),
[GroupCTE] AS
(
    SELECT  [ACD].[ID] AS [GroupID],
            [SS].[value] AS [input]
    FROM    [AoC].[AoC_Dec6] AS [ACD]
            CROSS APPLY [STRING_SPLIT]([ACD].[OriginalInput], CHAR(10)) AS [SS]
),
[LettesAnsweredByFullGroupCTE] AS
(
    SELECT      [A].[ID],
                [A].[Letter],
                [B].[GroupCount]
    FROM        [LetterSplitCTE] AS [A]
                CROSS APPLY (
                                SELECT      COUNT([GA].[input]) AS [GroupCount],
                                            [GA].[GroupID]
                                FROM        [GroupCTE] AS [GA]
                                WHERE       [GA].[GroupID] = [A].[ID]
                                GROUP BY    [GA].[GroupID]
                            ) AS [B]
    GROUP BY    [A].[ID],
                [A].[Letter],
                [B].[GroupCount]
    HAVING      COUNT([A].[Letter]) = [B].[GroupCount]
)
SELECT  SUM([Yes].[yesGroup])
FROM    (
            SELECT      COUNT([C].[ID]) AS [yesGroup]
            FROM        [LettesAnsweredByFullGroupCTE] AS [C]
            GROUP BY    [C].[ID]
        ) AS [Yes];
