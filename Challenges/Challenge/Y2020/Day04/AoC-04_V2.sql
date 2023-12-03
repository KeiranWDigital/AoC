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
         ROWTERMINATOR = ''' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + N'''
     );';
EXEC [sys].[sp_executesql] @BulkSQL;

UPDATE [AoC].[AoC_Dec4]
SET [input] = REPLACE([input], CHAR(13) + CHAR(10), ' ')

SELECT count(*)
FROM    [AoC].[AoC_Dec4] AS IT
WHERE   IT.input LIKE '%byr%'
        AND IT.input LIKE '%iyr%'
        AND IT.input LIKE '%eyr%'
        AND IT.input LIKE '%hgt%'
        AND IT.input LIKE '%hcl%'
        AND IT.input LIKE '%ecl%'
        AND IT.input LIKE '%pid%';

SELECT count(*)
FROM    [AoC].[AoC_Dec4] AS IT
WHERE   IT.input LIKE '%byr%'
        AND SUBSTRING(IT.input, CHARINDEX('byr:', IT.input, 1) + 4, 4) BETWEEN 1920 AND 2002
        AND IT.input LIKE '%iyr%'
        AND SUBSTRING(IT.input, CHARINDEX('iyr:', IT.input, 1) + 4, 4) BETWEEN 2010 AND 2020
        AND IT.input LIKE '%eyr%'
        AND SUBSTRING(IT.input, CHARINDEX('eyr:', IT.input, 1) + 4, 4) BETWEEN 2020 AND 2030
        AND IT.input LIKE '%hgt%'
        AND CASE
                WHEN CHARINDEX('in', SUBSTRING(IT.input, CHARINDEX('hgt:', IT.input, 1) + 4, 7), 1) IS NOT NULL
                     AND SUBSTRING(SUBSTRING(IT.input, CHARINDEX('hgt:', IT.input, 1) + 4, 7), 1, ISNULL(NULLIF(CHARINDEX('in', SUBSTRING(IT.input, CHARINDEX('hgt:', IT.input, 1) + 4, 7), 1) - 1, -1), 1)) BETWEEN 59 AND 76 THEN 1
                WHEN CHARINDEX('cm', SUBSTRING(IT.input, CHARINDEX('hgt:', IT.input, 1) + 4, 7), 1) IS NOT NULL
                     AND SUBSTRING(SUBSTRING(IT.input, CHARINDEX('hgt:', IT.input, 1) + 4, 7), 1, ISNULL(NULLIF(CHARINDEX('cm', SUBSTRING(IT.input, CHARINDEX('hgt:', IT.input, 1) + 4, 7), 1) - 1, -1), 1)) BETWEEN 150 AND 193 THEN 1
                ELSE 3
            END = 1
        AND IT.input LIKE '%hcl%'
        AND SUBSTRING(IT.input, CHARINDEX('hcl:', IT.input, 1) + 4, 7) LIKE '%#[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]%'
        AND IT.input LIKE '%ecl%'
        AND SUBSTRING(IT.input, CHARINDEX('ecl:', IT.input, 1) + 4, 3) IN ('amb', 'blu', 'brn', 'gry', 'grn', 'hzl', 'oth')
        AND IT.input LIKE '%pid%'
        AND TRY_PARSE(SUBSTRING(IT.input, CHARINDEX('pid:', IT.input, 1) + 4, 10)AS int) IS NOT NULL
        AND LEN(TRIM(SUBSTRING(IT.input, CHARINDEX('pid:', IT.input, 1) + 4, 10))) = 9;