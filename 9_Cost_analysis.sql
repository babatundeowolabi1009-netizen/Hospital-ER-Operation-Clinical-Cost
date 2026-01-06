/*
Project: ER Billing Analysis
Script: Patient Segmentation
Goal: To identify cost efficiency and medical conditions with the highest financial impact
Author: Babatunde Owolabi
*/

-- 1. Cost per Day Efficiency
-- ============================
SELECT 
    Medical_Condition,
    Stay_Category,
    COUNT(*) AS Patient_Volume,
    ROUND(AVG(Billing_Amount), 2) AS Avg_Total_Bill,
    ROUND(AVG(CAST(Length_of_Stay AS FLOAT)), 1) AS Avg_Stay,
    ROUND(AVG(Billing_Amount) / NULLIF(AVG(Length_of_Stay), 0), 2) AS Avg_Cost_Per_Day
FROM ER_Reporting
GROUP BY Medical_Condition, Stay_Category
ORDER BY Avg_Cost_Per_Day DESC;

-- 2. Billing Distribution (Quartile Analysis)
-- ===========================================
WITH billing_distribution AS (
    SELECT 
        Medical_Condition,
        Billing_Amount,
        NTILE(4) OVER (PARTITION BY Medical_Condition ORDER BY Billing_Amount) AS Cost_Quartile
    FROM ER_Reporting
)
SELECT 
    Medical_Condition,
    Cost_Quartile,
    COUNT(*) AS Patient_Count,
    ROUND(MIN(Billing_Amount), 2) AS Min_In_Quartile,
    ROUND(AVG(Billing_Amount), 2) AS Avg_In_Quartile,
    ROUND(MAX(Billing_Amount), 2) AS Max_In_Quartile
FROM billing_distribution
GROUP BY Medical_Condition, Cost_Quartile
ORDER BY Medical_Condition, Cost_Quartile;

-- 3. Total billing Revenue by condition 
-- =======================================
WITH condition_totals AS (
    SELECT 
        Medical_Condition,
        SUM(Billing_Amount) AS Total_Condition_Billing,
        COUNT(*) AS Patient_Volume
    FROM ER_Reporting
    GROUP BY Medical_Condition
)
SELECT 
    Medical_Condition,
    Total_Condition_Billing,
    Patient_Volume,
    RANK() OVER (ORDER BY Total_Condition_Billing DESC) AS Billing_Rank,
    SUM(Total_Condition_Billing) OVER (ORDER BY Total_Condition_Billing DESC) AS Running_Total_Billing,
    ROUND(100.0 * SUM(Total_Condition_Billing) OVER (ORDER BY Total_Condition_Billing DESC) / 
          SUM(Total_Condition_Billing) OVER (), 1) AS Cumulative_Pct
FROM condition_totals
ORDER BY Billing_Rank