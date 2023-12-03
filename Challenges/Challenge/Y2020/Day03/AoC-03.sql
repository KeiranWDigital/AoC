IF NOT EXISTS (SELECT * FROM [INFORMATION_SCHEMA].[SCHEMATA] AS [S] WHERE [S].[SCHEMA_NAME] = 'AoC')
BEGIN
EXEC sp_executesql N'CREATE SCHEMA AoC'
END
DROP TABLE IF EXISTS [AoC].[AoC_Dec3];
CREATE TABLE [AoC].[AoC_Dec3]
(
    [ID] int IDENTITY,
    [Input] varchar(MAX)
);
GO
DROP VIEW IF EXISTS [AoC].[Dec3Bulk];
GO
CREATE VIEW [AoC].[Dec3Bulk]
AS
SELECT  [Input]
FROM    [AoC].[AoC_Dec3];
GO

DECLARE @BulkSQL nvarchar(1000);
SET @BulkSQL = N'BULK INSERT AoC.Dec3Bulk
FROM ''F:\ElusiveChaos\Advent of Code\inputFiles\day3.txt''
WITH (
         ROWTERMINATOR = ''' + CHAR(10) + N'''
     );';
EXEC [sys].[sp_executesql] @BulkSQL;

DECLARE @PosTable table
(
    [ID] int IDENTITY,
    [X] int NOT NULL,
    [Y] int NOT NULL,
    [countNum] int DEFAULT (0) NOT NULL
);

INSERT INTO @PosTable
(
    [X],
    [Y]
)
VALUES
(
    3,
    1
),
(
    1,
    1
),
(
    5,
    1
),
(
    7,
    1
),
(
    1,
    2
);

DECLARE @Across int = 3,
        @Down int = 1;

DECLARE @x int = 1;
DECLARE @y int = 1;
DECLARE @RowNum int = 0;

DECLARE @MaxY int;
SELECT  @MaxY = COUNT(*)
FROM    [AoC].[AoC_Dec3] AS [ACD];

DECLARE @Count int = 0;

DECLARE [Curs1] CURSOR FOR
SELECT  [PT].[ID],
        [PT].[X],
        [PT].[Y],
        1,
        1,
        [PT].[countNum]
FROM    @PosTable AS [PT];

OPEN [Curs1];
FETCH NEXT FROM [Curs1]
INTO @RowNum,
     @Across,
     @Down,
     @x,
     @y,
     @Count;

WHILE @@FETCH_STATUS = 0
BEGIN
    WHILE (@y <= @MaxY)
    BEGIN

        IF EXISTS (
                      SELECT    *
                      FROM      [AoC].[AoC_Dec3] AS [IT]
                      WHERE     SUBSTRING(   [IT].[Input],
                                             CASE
                                                 WHEN @x % LEN([IT].[Input]) = 0 THEN LEN([IT].[Input])
                                                 ELSE @x % LEN([IT].[Input])
                                             END,
                                             1
                                         ) = '#'
                                AND [IT].[ID] = @y
                  )
        BEGIN
            SET @Count = @Count + 1;
        END;


        SET @y = @y + @Down;
        SET @x = @x + @Across;
    END;

    UPDATE  @PosTable
    SET     [countNum] = @Count
    WHERE   [ID] = @RowNum;

    FETCH NEXT FROM [Curs1]
    INTO @RowNum,
         @Across,
         @Down,
         @x,
         @y,
         @Count;
END;

SELECT  *
FROM    @PosTable AS [PT]
WHERE   [PT].[ID] = 1;

SELECT  ROUND(EXP(SUM(LOG([PT].[countNum]))), 1)
FROM    @PosTable AS [PT];