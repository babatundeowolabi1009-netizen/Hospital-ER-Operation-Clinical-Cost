/*
Title: ER Operational Analysis
Script: Length of Stay
Goal: Analyzing hospital efficiency 
Author: Babatunde Owolabi
*/

-- 1. LOS Stats by Condition
-- ==========================
SELECT 
    Medical_Condition,
    COUNT(*) AS Total_Patients,
    ROUND(AVG(CAST(Length_of_Stay AS FLOAT)), 1) AS Avg_Days,
    MIN(Length_of_Stay) AS Min_Days,
    MAX(Length_of_Stay) AS Max_Days,
    ROUND(STDEV(Length_of_Stay), 2) AS LOS_Standard_Dev,
    
    CASE 
        WHEN STDEV(Length_of_Stay) > (SELECT AVG(Length_of_Stay) FROM ER_Reporting) 
        THEN 'High Variance'
        ELSE 'Stable'
    END AS Predictability_Status
FROM ER_Reporting
GROUP BY Medical_Condition
HAVING COUNT(*) >= 50 
ORDER BY Avg_Days DESC;

-- 2. Distribution by Stay Category
-- ==================================
SELECT 
    Stay_Category,
    COUNT(*) AS Patient_Count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 1) AS Pct_Total,
    ROUND(AVG(Billing_Amount), 2) AS Avg_Bill
FROM ER_Reporting
GROUP BY Stay_Category
ORDER BY MIN(Length_of_Stay)

-- 3. Long Stay Drivers (21+ Days)
-- =================================
;WITH long_stay_data AS (
    SELECT 
        Medical_Condition,
        Admission_Type,
        Age_Group,
        COUNT(*) AS Volume,
        AVG(Length_of_Stay) AS Avg_LOS,
        SUM(Billing_Amount) AS Total_Billing
    FROM ER_Reporting
    WHERE Length_of_Stay >= 21
    GROUP BY Medical_Condition, Admission_Type, Age_Group
)
SELECT *,
    RANK() OVER (ORDER BY Volume DESC) AS Driver_Rank
FROM long_stay_data
WHERE Volume > 1
ORDER BY Volume DESC