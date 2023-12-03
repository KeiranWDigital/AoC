IF NOT EXISTS (SELECT * FROM [INFORMATION_SCHEMA].[SCHEMATA] AS [S] WHERE [S].[SCHEMA_NAME] = 'AoC')
BEGIN
EXEC sp_executesql N'CREATE SCHEMA AoC'
END
DROP TABLE IF EXISTS [AoC].[AoC_Dec5];
CREATE TABLE [AoC].[AoC_Dec5]
(
    [ID] int IDENTITY,
    [input] varchar(MAX) NOT NULL
);
GO
DROP VIEW IF EXISTS [AoC].[Dec5Bulk];
GO
CREATE VIEW [AoC].[Dec5Bulk]
AS
SELECT  [input]
FROM    [AoC].[AoC_Dec5];
GO

DECLARE @BulkSQL nvarchar(1000);
SET @BulkSQL = N'BULK INSERT AoC.Dec5Bulk
FROM ''F:\ElusiveChaos\Advent of Code\inputFiles\day5.txt''
WITH (
		 FIELDTERMINATOR = '','',
         ROWTERMINATOR = ''' + CHAR(10) + N'''
     );';
EXEC [sys].[sp_executesql] @BulkSQL;

SELECT  MAX(CAST(CONVERT(   varbinary(2),
                            '0x0' + CAST([A].[hex1] AS char(1)) + CASE
                                                                      WHEN [A].[hex2] < 10 THEN CAST([A].[hex2] AS char(1))
                                                                      WHEN [A].[hex2] = 10 THEN 'A'
                                                                      WHEN [A].[hex2] = 11 THEN 'B'
                                                                      WHEN [A].[hex2] = 12 THEN 'C'
                                                                      WHEN [A].[hex2] = 13 THEN 'D'
                                                                      WHEN [A].[hex2] = 14 THEN 'E'
                                                                      WHEN [A].[hex2] = 15 THEN 'F'
                                                                      ELSE NULL
                                                                  END + CASE
                                                                            WHEN [A].[hex3] < 10 THEN CAST([A].[hex3] AS char(1))
                                                                            WHEN [A].[hex3] = 10 THEN 'A'
                                                                            WHEN [A].[hex3] = 11 THEN 'B'
                                                                            WHEN [A].[hex3] = 12 THEN 'C'
                                                                            WHEN [A].[hex3] = 13 THEN 'D'
                                                                            WHEN [A].[hex3] = 14 THEN 'E'
                                                                            WHEN [A].[hex3] = 15 THEN 'F'
                                                                            ELSE NULL
                                                                        END,
                            1
                        ) AS int)
           )
FROM    (
            SELECT  CASE
                        WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 1, 1) = 1 THEN 2
                        ELSE 0
                    END + CASE
                              WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 2, 1) = 1 THEN 1
                              ELSE 0
                          END AS [hex1],
                    CASE
                        WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 3, 1) = 1 THEN 8
                        ELSE 0
                    END + CASE
                              WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 4, 1) = 1 THEN 4
                              ELSE 0
                          END + CASE
                                    WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 5, 1) = 1 THEN 2
                                    ELSE 0
                                END + CASE
                                          WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 6, 1) = 1 THEN 1
                                          ELSE 0
                                      END AS [hex2],
                    CASE
                        WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 7, 1) = 1 THEN 8
                        ELSE 0
                    END + CASE
                              WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 8, 1) = 1 THEN 4
                              ELSE 0
                          END + CASE
                                    WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 9, 1) = 1 THEN 2
                                    ELSE 0
                                END + CASE
                                          WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 10, 1) = 1 THEN 1
                                          ELSE 0
                                      END AS [hex3]
            FROM    [AoC].[AoC_Dec5] AS [ACD]
        ) AS [A];

--SELECT  MAX([BP].[seatID])
--FROM    @BoardingPass AS [BP];

--part 2-- Better solution for part 2
SELECT  [d].[seatid] - 1
FROM    (
            SELECT  [BP].[seatid],
                    LAG([BP].[seatid]) OVER (ORDER BY [BP].[seatid]) AS [Lag]
            FROM    (
                        SELECT  CAST(CONVERT(   varbinary(2),
                                                '0x0' + CAST([A].[hex1] AS char(1)) + CASE
                                                                                          WHEN [A].[hex2] < 10 THEN CAST([A].[hex2] AS char(1))
                                                                                          WHEN [A].[hex2] = 10 THEN 'A'
                                                                                          WHEN [A].[hex2] = 11 THEN 'B'
                                                                                          WHEN [A].[hex2] = 12 THEN 'C'
                                                                                          WHEN [A].[hex2] = 13 THEN 'D'
                                                                                          WHEN [A].[hex2] = 14 THEN 'E'
                                                                                          WHEN [A].[hex2] = 15 THEN 'F'
                                                                                          ELSE NULL
                                                                                      END + CASE
                                                                                                WHEN [A].[hex3] < 10 THEN CAST([A].[hex3] AS char(1))
                                                                                                WHEN [A].[hex3] = 10 THEN 'A'
                                                                                                WHEN [A].[hex3] = 11 THEN 'B'
                                                                                                WHEN [A].[hex3] = 12 THEN 'C'
                                                                                                WHEN [A].[hex3] = 13 THEN 'D'
                                                                                                WHEN [A].[hex3] = 14 THEN 'E'
                                                                                                WHEN [A].[hex3] = 15 THEN 'F'
                                                                                                ELSE NULL
                                                                                            END,
                                                1
                                            ) AS int) AS [seatid]
                        FROM    (
                                    SELECT  CASE
                                                WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 1, 1) = 1 THEN 2
                                                ELSE 0
                                            END + CASE
                                                      WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 2, 1) = 1 THEN 1
                                                      ELSE 0
                                                  END AS [hex1],
                                            CASE
                                                WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 3, 1) = 1 THEN 8
                                                ELSE 0
                                            END + CASE
                                                      WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 4, 1) = 1 THEN 4
                                                      ELSE 0
                                                  END + CASE
                                                            WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 5, 1) = 1 THEN 2
                                                            ELSE 0
                                                        END + CASE
                                                                  WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 6, 1) = 1 THEN 1
                                                                  ELSE 0
                                                              END AS [hex2],
                                            CASE
                                                WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 7, 1) = 1 THEN 8
                                                ELSE 0
                                            END + CASE
                                                      WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 8, 1) = 1 THEN 4
                                                      ELSE 0
                                                  END + CASE
                                                            WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 9, 1) = 1 THEN 2
                                                            ELSE 0
                                                        END + CASE
                                                                  WHEN SUBSTRING(TRANSLATE([ACD].[input], 'FBLR', '0101'), 10, 1) = 1 THEN 1
                                                                  ELSE 0
                                                              END AS [hex3]
                                    FROM    [AoC].[AoC_Dec5] AS [ACD]
                                ) AS [A]
                    ) AS [BP]
        ) AS [d]
WHERE   [d].[seatid] <> [d].[Lag] + 1;





SELECT  MAX(CAST(CONVERT(   varbinary(2),
                            '0x0' + CAST([A].[hex1] AS char(1)) + CASE
                                                                      WHEN [A].[hex2] < 10 THEN CAST([A].[hex2] AS char(1))
                                                                      WHEN [A].[hex2] = 10 THEN 'A'
                                                                      WHEN [A].[hex2] = 11 THEN 'B'
                                                                      WHEN [A].[hex2] = 12 THEN 'C'
                                                                      WHEN [A].[hex2] = 13 THEN 'D'
                                                                      WHEN [A].[hex2] = 14 THEN 'E'
                                                                      WHEN [A].[hex2] = 15 THEN 'F'
                                                                      ELSE NULL
                                                                  END + CASE
                                                                            WHEN [A].[hex3] < 10 THEN CAST([A].[hex3] AS char(1))
                                                                            WHEN [A].[hex3] = 10 THEN 'A'
                                                                            WHEN [A].[hex3] = 11 THEN 'B'
                                                                            WHEN [A].[hex3] = 12 THEN 'C'
                                                                            WHEN [A].[hex3] = 13 THEN 'D'
                                                                            WHEN [A].[hex3] = 14 THEN 'E'
                                                                            WHEN [A].[hex3] = 15 THEN 'F'
                                                                            ELSE NULL
                                                                        END,
                            1
                        ) AS int)
           )
FROM    (
            SELECT  CAST(TRANSLATE(SUBSTRING([ACD].[input], 1, 1), 'BF', '20') AS int) + CAST(TRANSLATE(SUBSTRING([ACD].[input], 2, 1), 'BF', '10') AS int) AS [hex1],
                    CAST(TRANSLATE(SUBSTRING([ACD].[input], 3, 1), 'BF', '80') AS int) + CAST(TRANSLATE(SUBSTRING([ACD].[input], 4, 1), 'BF', '40') AS int) + CAST(TRANSLATE(SUBSTRING([ACD].[input], 5, 1), 'BF', '20') AS int) + CAST(TRANSLATE(SUBSTRING([ACD].[input], 6, 1), 'BF', '10') AS int) AS [hex2],
                    CAST(TRANSLATE(SUBSTRING([ACD].[input], 7, 1), 'BF', '80') AS int) + CAST(TRANSLATE(SUBSTRING([ACD].[input], 8, 1), 'BFRL', '4040') AS int) + CAST(TRANSLATE(SUBSTRING([ACD].[input], 9, 1), 'BFRL', '2020') AS int) + CAST(TRANSLATE(SUBSTRING([ACD].[input], 10, 1), 'BFRL', '1010') AS int) AS [hex3]
            FROM    [AoC].[AoC_Dec5] AS [ACD]
        ) AS [A];


SELECT  [d].[seatid] - 1
FROM    (
            SELECT  [BP].[seatid],
                    LAG([BP].[seatid]) OVER (ORDER BY [BP].[seatid]) AS [Lag]
            FROM    (
                        SELECT  CAST(CONVERT(   varbinary(2),
                                                '0x0' + CAST([A].[hex1] AS char(1)) + CASE
                                                                                          WHEN [A].[hex2] < 10 THEN CAST([A].[hex2] AS char(1))
                                                                                          WHEN [A].[hex2] = 10 THEN 'A'
                                                                                          WHEN [A].[hex2] = 11 THEN 'B'
                                                                                          WHEN [A].[hex2] = 12 THEN 'C'
                                                                                          WHEN [A].[hex2] = 13 THEN 'D'
                                                                                          WHEN [A].[hex2] = 14 THEN 'E'
                                                                                          WHEN [A].[hex2] = 15 THEN 'F'
                                                                                          ELSE NULL
                                                                                      END + CASE
                                                                                                WHEN [A].[hex3] < 10 THEN CAST([A].[hex3] AS char(1))
                                                                                                WHEN [A].[hex3] = 10 THEN 'A'
                                                                                                WHEN [A].[hex3] = 11 THEN 'B'
                                                                                                WHEN [A].[hex3] = 12 THEN 'C'
                                                                                                WHEN [A].[hex3] = 13 THEN 'D'
                                                                                                WHEN [A].[hex3] = 14 THEN 'E'
                                                                                                WHEN [A].[hex3] = 15 THEN 'F'
                                                                                                ELSE NULL
                                                                                            END,
                                                1
                                            ) AS int) AS [seatid]
                        FROM    (
                                    SELECT  CAST(TRANSLATE(SUBSTRING([ACD].[input], 1, 1), 'BF', '20') AS int) + CAST(TRANSLATE(SUBSTRING([ACD].[input], 2, 1), 'BF', '10') AS int) AS [hex1],
                                            CAST(TRANSLATE(SUBSTRING([ACD].[input], 3, 1), 'BF', '80') AS int) + CAST(TRANSLATE(SUBSTRING([ACD].[input], 4, 1), 'BF', '40') AS int) + CAST(TRANSLATE(SUBSTRING([ACD].[input], 5, 1), 'BF', '20') AS int) + CAST(TRANSLATE(SUBSTRING([ACD].[input], 6, 1), 'BF', '10') AS int) AS [hex2],
                                            CAST(TRANSLATE(SUBSTRING([ACD].[input], 7, 1), 'BF', '80') AS int) + CAST(TRANSLATE(SUBSTRING([ACD].[input], 8, 1), 'BFRL', '4040') AS int) + CAST(TRANSLATE(SUBSTRING([ACD].[input], 9, 1), 'BFRL', '2020') AS int) + CAST(TRANSLATE(SUBSTRING([ACD].[input], 10, 1), 'BFRL', '1010') AS int) AS [hex3]
                                    FROM    [AoC].[AoC_Dec5] AS [ACD]
                                ) AS [A]
                    ) AS [BP]
        ) AS [d]
WHERE   [d].[seatid] <> [d].[Lag] + 1;