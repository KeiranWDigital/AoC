IF NOT EXISTS (
                  SELECT    *
                  FROM      [INFORMATION_SCHEMA].[SCHEMATA] AS [S]
                  WHERE     [S].[SCHEMA_NAME] = 'AoC'
              )
BEGIN
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA AoC';
END;
DROP TABLE IF EXISTS [AoC].[AoC_Dec1];
CREATE TABLE [AoC].[AoC_Dec1]
(
    [ID] int IDENTITY,
    [number] int NOT NULL
);
GO
DROP VIEW IF EXISTS [AoC].[Dec1Bulk];
GO
CREATE VIEW [AoC].[Dec1Bulk]
AS
SELECT  [number]
FROM    [AoC].[AoC_Dec1];
GO

DECLARE @BulkSQL nvarchar(1000);
SET @BulkSQL = N'BULK INSERT AoC.Dec1Bulk
FROM ''F:\ElusiveChaos\Advent of Code\inputFiles\day1.txt''
WITH (
		 FIELDTERMINATOR = '','',
         ROWTERMINATOR = ''' + CHAR(10) + N'''
     );';
EXEC [sys].[sp_executesql] @BulkSQL;

DECLARE @Numbers varchar(MAX),
        @Finished bit = 0,
        @num1 int,
        @num2 int,
        @num3 int;

-- problem 1
DECLARE @Pos int = 1,
        @Max int;

SELECT  @Max = COUNT(*)
FROM    [AoC].[AoC_Dec1] AS [ACD];

WHILE @Finished = 0
      AND   @Pos < @Max
BEGIN
    SELECT  @num1 = [NT].[number],
            @num2 = [test].[number]
    FROM    [AoC].[AoC_Dec1] AS [NT]
            CROSS APPLY (
                            SELECT  [NT2].[number]
                            FROM    [AoC].[AoC_Dec1] AS [NT2]
                            WHERE   [NT2].[ID] > @Pos
                        ) AS [test]
    WHERE   [NT].[ID] = @Pos
            AND ([NT].[number] + [test].[number]) = 2020;

    IF @num1 IS NOT NULL
       AND  @num2 IS NOT NULL
    BEGIN
        SET @Finished = 1;
    END;
    SET @Pos = @Pos + 1;

END;

SELECT  @num1 * @num2 AS [Problem1Answer];

-- Problem 2

SELECT  @Finished = 0,
        @Pos = 1;

WHILE @Finished = 0
      AND   @Pos < @Max
BEGIN
    SELECT  @num1 = [NT].[number],
            @num2 = [test1].[number],
            @num3 = [test2].[number]
    FROM    [AoC].[AoC_Dec1] AS [NT]
            CROSS APPLY (
                            SELECT  [NT2].[ID],
                                    [NT2].[number]
                            FROM    [AoC].[AoC_Dec1] AS [NT2]
                            WHERE   [NT2].[ID] > @Pos
                        ) AS [test1]
            CROSS APPLY (
                            SELECT  [NT2].[ID],
                                    [NT2].[number]
                            FROM    [AoC].[AoC_Dec1] AS [NT2]
                            WHERE   [NT2].[ID] > @Pos
                        ) AS [test2]
    WHERE   [NT].[ID] = @Pos
            AND ([NT].[number] + [test1].[number] + [test2].[number]) = 2020
            AND [test1].[ID] <> [test2].[ID];

    IF @num1 IS NOT NULL
       AND  @num2 IS NOT NULL
       AND  @num3 IS NOT NULL
    BEGIN
        SET @Finished = 1;
    END;
    SET @Pos = @Pos + 1;

END;

SELECT  @num1 * @num2 * @num3 AS [Problem2Answer];