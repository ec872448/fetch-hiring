-- Create Fetch_Exercise database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Fetch_Exercise')
BEGIN
    CREATE DATABASE Fetch_Exercise;
END
GO

USE Fetch_Exercise;
GO

-- Create Brands table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Brands')
BEGIN
    CREATE TABLE Brands (
        Id NVARCHAR(50) PRIMARY KEY,
        Barcode NVARCHAR(50),
        BrandCode NVARCHAR(255),
        Category NVARCHAR(255),
        CategoryCode NVARCHAR(255),
        CpgId NVARCHAR(50),
        CpgRef NVARCHAR(255),
        Name NVARCHAR(255),
        TopBrand BIT
    );
END
GO

-- Create Receipts table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Receipts')
BEGIN
    CREATE TABLE Receipts (
        Id NVARCHAR(50) PRIMARY KEY,
        BonusPointsEarned INT,
        BonusPointsEarnedReason NVARCHAR(500),
        CreateDate DATETIME,
        DateScanned DATETIME,
        FinishedDate DATETIME,
        ModifyDate DATETIME,
        PointsAwardedDate DATETIME,
        PointsEarned FLOAT,
        PurchaseDate DATETIME,
        PurchasedItemCount INT,
        RewardsReceiptStatus NVARCHAR(50),
        TotalSpent FLOAT,
        UserId NVARCHAR(50)
    );
END
GO



-- Create Users table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        Id NVARCHAR(50) PRIMARY KEY,
        Active BIT,
        CreatedDate DATETIME,
        LastLogin DATETIME,
        Role NVARCHAR(50),
        SignUpSource NVARCHAR(255),
        State NVARCHAR(10)
    );
END
GO

USE Fetch_Exercise;
GO

-- Drop Primary Key Constraint if Exists
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_NAME = 'Users' AND CONSTRAINT_TYPE = 'PRIMARY KEY')
BEGIN
    ALTER TABLE Users DROP CONSTRAINT PK__Users__3214EC07E89CCFAC;
END
GO

-- Modify Users Table to Allow Duplicates
ALTER TABLE Users DROP COLUMN Id;
ALTER TABLE Users ADD UserEntryId INT IDENTITY(1,1) PRIMARY KEY;  -- Auto-generated unique key
ALTER TABLE Users ADD Id NVARCHAR(50) NULL;  -- Allow duplicates
GO


-- Insert into Brands table
INSERT INTO Brands (Id, Barcode, BrandCode, Category, CategoryCode, CpgId, CpgRef, Name, TopBrand)
SELECT 
    JSON_VALUE(JsonObjects.[value], '$.id') AS Id,  -- Use "id" instead of "_id"
    JSON_VALUE(JsonObjects.[value], '$.barcode') AS Barcode,
    JSON_VALUE(JsonObjects.[value], '$.brandCode') AS BrandCode,
    JSON_VALUE(JsonObjects.[value], '$.category') AS Category,
    JSON_VALUE(JsonObjects.[value], '$.categoryCode') AS CategoryCode,
    JSON_VALUE(JsonObjects.[value], '$.cpgId') AS CpgId,  -- Use "cpgId" instead of "$id"
    JSON_VALUE(JsonObjects.[value], '$.cpgRef') AS CpgRef, -- Use "cpgRef" instead of "$ref"
    JSON_VALUE(JsonObjects.[value], '$.name') AS Name,
    CAST(JSON_VALUE(JsonObjects.[value], '$.topBrand') AS BIT) AS TopBrand
FROM OPENROWSET(
    BULK 'C:\temp\brands_fixed.json',
    SINGLE_CLOB
) AS RawJsonFile
CROSS APPLY OPENJSON(RawJsonFile.BulkColumn) AS JsonObjects;
GO
-- Insert into Receipts table
INSERT INTO Receipts (Id, BonusPointsEarned, BonusPointsEarnedReason, CreateDate, DateScanned, FinishedDate, ModifyDate, PointsAwardedDate, PointsEarned, PurchaseDate, PurchasedItemCount, RewardsReceiptStatus, TotalSpent, UserId)
SELECT 
    JSON_VALUE(JsonObjects.[value], '$.id') AS Id,
    CAST(JSON_VALUE(JsonObjects.[value], '$.bonusPointsEarned') AS INT) AS BonusPointsEarned,
    JSON_VALUE(JsonObjects.[value], '$.bonusPointsEarnedReason') AS BonusPointsEarnedReason,
    DATEADD(SECOND, CAST(JSON_VALUE(JsonObjects.[value], '$.createDate') AS BIGINT) / 1000, '1970-01-01') AS CreateDate,
    DATEADD(SECOND, CAST(JSON_VALUE(JsonObjects.[value], '$.dateScanned') AS BIGINT) / 1000, '1970-01-01') AS DateScanned,
    DATEADD(SECOND, CAST(JSON_VALUE(JsonObjects.[value], '$.finishedDate') AS BIGINT) / 1000, '1970-01-01') AS FinishedDate,
    DATEADD(SECOND, CAST(JSON_VALUE(JsonObjects.[value], '$.modifyDate') AS BIGINT) / 1000, '1970-01-01') AS ModifyDate,
    DATEADD(SECOND, CAST(JSON_VALUE(JsonObjects.[value], '$.pointsAwardedDate') AS BIGINT) / 1000, '1970-01-01') AS PointsAwardedDate,
    CAST(JSON_VALUE(JsonObjects.[value], '$.pointsEarned') AS FLOAT) AS PointsEarned,
    DATEADD(SECOND, CAST(JSON_VALUE(JsonObjects.[value], '$.purchaseDate') AS BIGINT) / 1000, '1970-01-01') AS PurchaseDate,
    CAST(JSON_VALUE(JsonObjects.[value], '$.purchasedItemCount') AS INT) AS PurchasedItemCount,
    JSON_VALUE(JsonObjects.[value], '$.rewardsReceiptStatus') AS RewardsReceiptStatus,
    CAST(JSON_VALUE(JsonObjects.[value], '$.totalSpent') AS FLOAT) AS TotalSpent,
    JSON_VALUE(JsonObjects.[value], '$.userId') AS UserId
FROM OPENROWSET(
    BULK 'C:\temp\receipts_fixed.json',
    SINGLE_CLOB
) AS RawJsonFile
CROSS APPLY OPENJSON(RawJsonFile.BulkColumn) AS JsonObjects;
GO
-- Insert into Users table (ALLOWING DUPLICATES)
INSERT INTO Users (Id, Active, CreatedDate, LastLogin, Role, SignUpSource, State)
SELECT 
    JSON_VALUE(JsonObjects.[value], '$.id') AS Id,
    CAST(JSON_VALUE(JsonObjects.[value], '$.active') AS BIT) AS Active,
    DATEADD(SECOND, CAST(JSON_VALUE(JsonObjects.[value], '$.createdDate') AS BIGINT) / 1000, '1970-01-01') AS CreatedDate,
    DATEADD(SECOND, CAST(JSON_VALUE(JsonObjects.[value], '$.lastLogin') AS BIGINT) / 1000, '1970-01-01') AS LastLogin,
    JSON_VALUE(JsonObjects.[value], '$.role') AS Role,
    JSON_VALUE(JsonObjects.[value], '$.signUpSource') AS SignUpSource,
    JSON_VALUE(JsonObjects.[value], '$.state') AS State
FROM OPENROWSET(
    BULK 'C:\temp\users_fixed.json',
    SINGLE_CLOB
) AS RawJsonFile
CROSS APPLY OPENJSON(RawJsonFile.BulkColumn) AS JsonObjects;
GO

