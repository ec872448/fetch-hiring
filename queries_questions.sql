

-----Comparing Average Spend Between 'Accepted' and 'Rejected' Receipts
SELECT 
    RewardsReceiptStatus,
    AVG(TotalSpent) AS AvgSpend
FROM Receipts
WHERE RewardsReceiptStatus IN ('FINISHED', 'Rejected')
GROUP BY RewardsReceiptStatus;

------Comparing Total Items Purchased Between 'Accepted' and 'Rejected' Receipts
SELECT 
    RewardsReceiptStatus,
    SUM(PurchasedItemCount) AS TotalItemsPurchased
FROM Receipts
WHERE RewardsReceiptStatus IN ('FINISHED', 'Rejected')
GROUP BY RewardsReceiptStatus;



------------------combined
SELECT 
    rewardsReceiptStatus,
    AVG(CAST(TotalSpent AS FLOAT)) AS Avg_Spend,
    SUM(CAST(PurchasedItemCount AS INT)) AS Total_Items_Purchased
FROM Receipts
WHERE rewardsReceiptStatus IN ('FINISHED', 'Rejected')
GROUP BY rewardsReceiptStatus;