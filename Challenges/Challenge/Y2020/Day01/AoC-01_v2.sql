IF NOT EXISTS (SELECT * FROM [INFORMATION_SCHEMA].[SCHEMATA] AS [S] WHERE [S].[SCHEMA_NAME] = 'AoC')
BEGIN
EXEC sp_executesql N'CREATE SCHEMA AoC'
END
DROP TABLE IF EXISTS AoC.AoC_Dec1;
CREATE TABLE AoC.AoC_Dec1
(
    ID int IDENTITY,
    number int NOT NULL
);
GO
DROP VIEW IF EXISTS AoC.Dec1Bulk
GO
CREATE VIEW AoC.Dec1Bulk
AS
SELECT  number
FROM    AoC.AoC_Dec1;
GO

DECLARE @BulkSQL nvarchar(1000);
SET @BulkSQL = N'BULK INSERT AoC.Dec1Bulk
FROM ''F:\ElusiveChaos\Advent of Code\inputFiles\day1.txt''
WITH (
		 FIELDTERMINATOR = '','',
         ROWTERMINATOR = ''' + CHAR(10) + N'''
     );';
EXEC sys.sp_executesql @BulkSQL;

-- problem 1
SELECT  NT.number * NT2.number
FROM    AoC.AoC_Dec1 AS NT
        CROSS JOIN AoC.AoC_Dec1 AS NT2
WHERE   NT.ID < NT2.ID
        AND 2020 = NT.number + NT2.number;

-- problem 2
SELECT  NT.number * NT2.number * NT3.number
FROM    AoC.AoC_Dec1 AS NT
        CROSS JOIN AoC.AoC_Dec1 AS NT2
		CROSS JOIN AoC.AoC_Dec1 AS NT3
WHERE   NT.ID < NT2.ID
		AND NT2.id < NT3.ID
        AND 2020 = NT.number + NT2.number + nt3.number;