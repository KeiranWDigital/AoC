SET NOCOUNT ON

IF NOT EXISTS (
                  SELECT    *
                  FROM      [INFORMATION_SCHEMA].[SCHEMATA] AS [S]
                  WHERE     [S].[SCHEMA_NAME] = 'AoC'
              )
BEGIN
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA AoC';
END;
DROP TABLE IF EXISTS [AoC].[AoC_Dec8];
CREATE TABLE [AoC].[AoC_Dec8]
(
    [ID] int IDENTITY,
    [input] varchar(MAX) NOT NULL,
    [command] char(3) NULL,
    [val] int NULL,
    [accessedbit] bit NULL
);
GO
DROP VIEW IF EXISTS [AoC].[Dec8Bulk];
GO
CREATE VIEW [AoC].[Dec8Bulk]
AS
SELECT  [input]
FROM    [AoC].[AoC_Dec8];
GO

DECLARE @BulkSQL nvarchar(1000);
SET @BulkSQL = N'BULK INSERT AoC.Dec8Bulk
FROM ''F:\ElusiveChaos\Advent of Code\inputFiles\day8.txt''
WITH (
		 FIELDTERMINATOR = '','',
         ROWTERMINATOR = ''' + CHAR(13) + CHAR(10) + N'''
     );';
EXEC [sys].[sp_executesql] @BulkSQL;

UPDATE  [ACD]
SET     [ACD].[command] = [1],
        [ACD].[val] = REPLACE([2], '+', '')
FROM    [AoC].[AoC_Dec8] AS [ACD]
        INNER JOIN (
                       SELECT   *
                       FROM     (
                                    SELECT  *
                                    FROM    [AoC].[AoC_Dec8] AS [IT]
                                            CROSS APPLY (
                                                            SELECT  ROW_NUMBER() OVER (ORDER BY (
                                                                                                    SELECT  NULL
                                                                                                )
                                                                                      ) AS [RowN],
                                                                    [value]
                                                            FROM    STRING_SPLIT([IT].[input], ' ')
                                                        ) AS [d]
                                ) AS [src]
                       PIVOT (
                                 MAX([value])
                                 FOR [RowN] IN ([1], [2])
                             ) AS [p]
                   ) AS [ACD2]
            ON [ACD2].[ID] = [ACD].[ID];

DECLARE @Accumalator int = 0,
        @nextId int = 1,
        @count int = 1,
        @AccumalatorFin int,
        @Finished bit = 0;


WHILE EXISTS (
                 SELECT *
                 FROM   [AoC].[AoC_Dec8] AS [ACD]
                 WHERE  [ACD].[ID] = @nextId
                        AND (
                                [ACD].[accessedbit] = 0
                                OR  [ACD].[accessedbit] IS NULL
                            )
             )
BEGIN

    UPDATE  [AoC].[AoC_Dec8]
    SET     [accessedbit] = 1
    WHERE   [ID] = @nextId;

    SELECT  @Accumalator = CASE
                               WHEN [ACD].[command] = 'ACC' THEN @Accumalator + [ACD].[val]
                               ELSE @Accumalator
                           END,
            @nextId = CASE
                          WHEN [ACD].[command] = 'jmp' THEN @nextId + [ACD].[val]
                          ELSE @nextId + 1
                      END
    FROM    [AoC].[AoC_Dec8] AS [ACD]
    WHERE   [ACD].[ID] = @nextId;

    SELECT  @count = @count + 1;
END;

SELECT  @Accumalator;



DECLARE [Curs1] CURSOR FOR
SELECT  [ACD].[ID]
FROM    [AoC].[AoC_Dec8] AS [ACD]
WHERE   [ACD].[command] IN ('nop', 'jmp');

DECLARE @idToReplaCE int;

OPEN [Curs1];
FETCH NEXT FROM [Curs1]
INTO @idToReplaCE;

WHILE @@FETCH_STATUS = 0
      AND   @Finished = 0
BEGIN

	UPDATE [AoC].[AoC_Dec8]
	SET [accessedbit] = 0

    SET @nextId = 1;
    SET @Accumalator = 0;
	SET @count = 1

    UPDATE  [AoC].[AoC_Dec8]
    SET     [command] = CASE
                            WHEN [command] = 'NOP' THEN 'JMP'
                            ELSE 'NOP'
                        END
    WHERE   [ID] = @idToReplaCE;

    WHILE EXISTS (
                     SELECT *
                     FROM   [AoC].[AoC_Dec8] AS [ACD]
                     WHERE  [ACD].[ID] = @nextId
                            AND (
                                    [ACD].[accessedbit] = 0
                                    OR  [ACD].[accessedbit] IS NULL
                                )
                 )
    BEGIN
        UPDATE  [AoC].[AoC_Dec8]
        SET     [accessedbit] = 1
        WHERE   [ID] = @nextId;

        SELECT  @Accumalator = CASE
                                   WHEN [ACD].[command] = 'ACC' THEN @Accumalator + [ACD].[val]
                                   ELSE @Accumalator
                               END,
                @nextId = CASE
                              WHEN [ACD].[command] = 'jmp' THEN @nextId + [ACD].[val]
                              ELSE @nextId + 1
                          END
        FROM    [AoC].[AoC_Dec8] AS [ACD]
        WHERE   [ACD].[ID] = @nextId;

        SELECT  @count = @count + 1;
    END;

    IF NOT EXISTS (
                      SELECT    *
                      FROM      [AoC].[AoC_Dec8] AS [ACD]
                      WHERE     [ACD].[ID] = @nextId
                  )
    BEGIN
        SET @Finished = 1;
        SET @AccumalatorFin = @Accumalator;
    END;

    UPDATE  [AoC].[AoC_Dec8]
    SET     [command] = CASE
                            WHEN [command] = 'NOP' THEN 'JMP'
                            ELSE 'NOP'
                        END
    WHERE   [ID] = @idToReplaCE;

    FETCH NEXT FROM [Curs1]
    INTO @idToReplaCE;
END;


SELECT  @Accumalator;

DEALLOCATE [Curs1];