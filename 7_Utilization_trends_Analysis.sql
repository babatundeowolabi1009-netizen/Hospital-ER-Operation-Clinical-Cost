/*
Title: ER Operational Analysis
Script: Admission Trends
Goal: To identify demographic trends.
Author: Babatunde Owolabi
*/

-- 1. Monthly Trends 
-- ===================
WITH monthly_data AS (
    SELECT 
        Admission_Year,
        Admission_Month,
        Month_Name,
        COUNT(*) AS Monthly_Admissions,
        SUM(Billing_Amount) AS Monthly_Billing
    FROM ER_Reporting
    GROUP BY Admission_Year, Admission_Month, Month_Name
)
SELECT 
    Admission_Year,
    Month_Name,
    Monthly_Admissions,
    Monthly_Billing,
    AVG(Monthly_Admissions) OVER (
        ORDER BY Admission_Year, Admission_Month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS Moving_Avg_3M,
    LAG(Monthly_Admissions, 12) OVER (ORDER BY Admission_Year, Admission_Month) AS Prev_Year_Month_Vol
FROM monthly_data
ORDER BY Admission_Year, Admission_Month

-- 2. Weekly Load Patterns
-- ========================
SELECT 
    DATENAME(weekday, Date_of_Admission) AS Day_of_Week,
    Admission_Type,
    COUNT(*) AS Total_Admissions,
    ROUND(AVG(Billing_Amount), 2) AS Avg_Bill,
    CASE 
        WHEN DATEPART(weekday, Date_of_Admission) IN (1,7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type
FROM ER_Reporting
GROUP BY 
    DATENAME(weekday, Date_of_Admission),
    DATEPART(weekday, Date_of_Admission),
    Admission_Type
ORDER BY DATEPART(weekday, Date_of_Admission), Admission_Type;

-- 3. Admission Type Mix 
-- ======================
SELECT 
    Admission_Year,
    Admission_Type,
    COUNT(*) AS Encounter_Volume,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY Admission_Year), 1) AS Pct_Share_of_Year
FROM ER_Reporting
GROUP BY Admission_Year, Admission_Type
ORDER BY Admission_Year, Encounter_Volume DESC