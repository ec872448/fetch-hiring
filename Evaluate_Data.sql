----Detect Missing Values in Key Fields

SELECT *
FROM Users
WHERE 
    role is null 
---------------------------
SELECT *
FROM Receipts
WHERE 
    ID IS NULL 
    OR UserId IS NULL 
    OR PurchaseDate IS NULL 
    OR TotalSpent IS NULL;
--------------------------
SELECT *
FROM Brands
WHERE 
    Id IS NULL 
    OR Barcode IS NULL 
    OR Name IS NULL;

-- Find Duplicate Records
SELECT Id, COUNT(*) AS DuplicateCount
FROM Brands
GROUP BY Id
HAVING COUNT(*) > 1;

SELECT ID, COUNT(*) AS DuplicateCount
FROM Users
GROUP BY ID
HAVING COUNT(*) > 1;

------Detect Invalid Date Formats

SELECT *
FROM Receipts
WHERE TRY_CONVERT(DATETIME, PurchaseDate) IS NULL;

----Identify Negative or Unrealistic Spend Amounts

SELECT *
FROM Receipts
WHERE TotalSpent < 0 OR TotalSpent > 10000; ---Adjust as needed


---Identify Inconsistent Categories

SELECT Category, COUNT(*) 
FROM Brands
GROUP BY Category
ORDER BY COUNT(*) DESC;
