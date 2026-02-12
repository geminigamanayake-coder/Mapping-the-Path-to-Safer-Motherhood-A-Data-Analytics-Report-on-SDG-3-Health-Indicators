
--Remove rows with missing country names
DELETE FROM [Goal 3.1.1]
WHERE GeoAreaName IS NULL OR GeoAreaName = '';

DELETE FROM [Goal 3.1.2]
WHERE GeoAreaName IS NULL OR GeoAreaName = '';

DELETE FROM [Goal 3.7.1]
WHERE GeoAreaName IS NULL OR GeoAreaName = '';

--Convert text to numbers where needed

UPDATE [Goal 3.1.1]
SET Value = TRY_CAST(Value AS FLOAT);

UPDATE [Goal 3.1.2]
SET Value = TRY_CAST(Value AS FLOAT);

UPDATE [Goal 3.7.1]
SET Value = TRY_CAST(Value AS FLOAT);

--Standardize Column Names

EXEC sp_rename '[Goal 3.1.1].GeoAreaName', 'Country_Name', 'COLUMN';
EXEC sp_rename '[Goal 3.1.1].TimePeriod_Year', 'Year', 'COLUMN';

EXEC sp_rename '[Goal 3.1.2].GeoAreaName', 'Country_Name', 'COLUMN';

EXEC sp_rename '[Goal 3.7.1].GeoAreaName', 'Country_Name', 'COLUMN';


--Check for duplicates
SELECT Country_Name, TimePeriod_Year, COUNT(*) AS Count
FROM [Goal 3.1.1]
GROUP BY Country_Name, TimePeriod_Year
HAVING COUNT(*) > 1;

SELECT Country_Name, Year, COUNT(*) AS Count
FROM [Goal 3.1.2]
GROUP BY Country_Name, Year
HAVING COUNT(*) > 1;

SELECT Country_Name, Year, COUNT(*) AS Count
FROM [Goal 3.7.1]
GROUP BY Country_Name, Year
HAVING COUNT(*) > 1;

--Countries Dimension Table
CREATE TABLE Countries (
    CountryID INT IDENTITY(1,1) PRIMARY KEY,
    Country_Name NVARCHAR(200) UNIQUE
);

INSERT INTO Countries (Country_Name)
SELECT DISTINCT Country_Name FROM [Goal 3.1.1]
WHERE Country_Name NOT IN (SELECT Country_Name FROM Countries);

select* from Countries

--Add Foreign Keys to Each Fact Table
ALTER TABLE [Goal 3.1.1] ADD CountryID INT;

UPDATE g
SET g.CountryID = c.CountryID
FROM [Goal 3.1.1] g
JOIN Countries c ON g.Country_Name = c.Country_Name;

--Final Verification
SELECT * FROM [Goal 3.1.1] WHERE CountryID IS NULL;

SELECT MIN(Year), MAX(Year) FROM [Goal 3.1.1];

SELECT TOP 20 * FROM [Goal 3.1.1];
SELECT TOP 20 * FROM [Goal 3.1.2];
SELECT TOP 20 * FROM [Goal 3.7.1];



