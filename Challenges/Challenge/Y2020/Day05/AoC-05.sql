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

DECLARE @BoardingPass table
(
    [ID] int IDENTITY,
    [BoardingPass] varchar(MAX) NOT NULL,
    [rowID] int NOT NULL,
    [ColumnID] int NOT NULL,
    [seatID] int NOT NULL
);

DECLARE @string varchar(MAX) = '';

DECLARE @RowMax int = 127,
        @RowMin int = 0,
        @ColumnMax int = 7,
        @ColumnMin int = 0,
        @pos int = 1;

DECLARE [Curs] CURSOR LOCAL READ_ONLY STATIC FORWARD_ONLY FOR
SELECT  [IT].[input]
FROM    [AoC].[AoC_Dec5] AS [IT];

OPEN [Curs];

FETCH NEXT FROM [Curs]
INTO @string;

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT  @RowMax = 127,
            @RowMin = 0,
            @ColumnMax = 7,
            @ColumnMin = 0,
            @pos = 1;

    WHILE @pos <= 7
    BEGIN

        SELECT  @RowMax = CASE
                              WHEN SUBSTRING(@string, @pos, 1) = 'F' THEN ((@RowMax - @RowMin) / 2) + @RowMin
                              ELSE @RowMax
                          END,
                @RowMin = CASE
                              WHEN SUBSTRING(@string, @pos, 1) = 'B' THEN ((@RowMax - @RowMin) / 2) + 1 + @RowMin
                              ELSE @RowMin
                          END;
        SELECT  @pos = @pos + 1;

    END;

    WHILE @pos <= LEN(@string)
    BEGIN
        SELECT  @ColumnMax = CASE
                                 WHEN SUBSTRING(@string, @pos, 1) = 'L' THEN ((@ColumnMax - @ColumnMin) / 2) + @ColumnMin
                                 ELSE @ColumnMax
                             END,
                @ColumnMin = CASE
                                 WHEN SUBSTRING(@string, @pos, 1) = 'R' THEN ((@ColumnMax - @ColumnMin) / 2) + 1 + @ColumnMin
                                 ELSE @ColumnMin
                             END;
        SELECT  @pos = @pos + 1;
    END;

    INSERT INTO @BoardingPass
    (
        [BoardingPass],
        [rowID],
        [ColumnID],
        [seatID]
    )
    VALUES
    (
        @string, -- BoardingPass - varchar(max)
        @RowMax, -- rowID - int
        @ColumnMax, -- ColumnID - int
        (@RowMax * 8) + @ColumnMax -- seatID - int
    );

    FETCH NEXT FROM [Curs]
    INTO @string;
END;

DEALLOCATE [Curs];

SELECT  MAX([BP].[seatID])
FROM    @BoardingPass AS [BP];

--part 2-- Better solution for part 2
SELECT  [d].[seatID] - 1
FROM    (
            SELECT  [BP].[seatID],
                    LAG([BP].[seatID]) OVER (ORDER BY [BP].[seatID]) AS [Lag]
            FROM    @BoardingPass AS [BP]
        ) AS [d]
WHERE   [d].[seatID] <> [d].[Lag] + 1;


