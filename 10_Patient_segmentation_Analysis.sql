/*
Project: ER Patient Population Analysis
Script: Patient Segmentation
Goal: To identify demographic trends.
Author: Babatunde Owolabi
*/

-- 1. High-Cost Patient Identification (Top 10%)
-- ==============================================
WITH patient_percentiles AS (
    SELECT 
        Age_Group,
        Medical_Condition,
        Billing_Amount,
        NTILE(100) OVER (ORDER BY Billing_Amount) AS Cost_Percentile
	FROM ER_Reporting
)
SELECT 
    Age_Group,
    Medical_Condition,
    COUNT(*) AS High_Cost_Patient_Count,
    ROUND(AVG(Billing_Amount), 2) AS Avg_Cost,
    ROUND(MIN(Billing_Amount), 2) AS Min_Cost,
    ROUND(MAX(Billing_Amount), 2) AS Max_Cost
FROM patient_percentiles
WHERE Cost_Percentile >= 90
GROUP BY Age_Group, Medical_Condition
ORDER BY High_Cost_Patient_Count DESC

-- 2. Age Group & Admission Dynamics 
-- ===================================
SELECT 
    Age_Group,
    Admission_Type,
    COUNT(*) AS Patient_Count,
	ROUND(AVG(CAST(Length_of_Stay AS FLOAT)), 1) AS Avg_Stay,
	ROUND(AVG(Billing_Amount), 2) AS Avg_Bill,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY Age_Group), 1) AS Pct_of_Age_Group
FROM ER_Reporting
GROUP BY Age_Group, Admission_Type
ORDER BY Age_Group, Patient_Count DESC

-- 3. Condition-Based Demographic Profiles
-- ========================================
SELECT 
    Medical_Condition,
    AVG(Age) AS Avg_Patient_Age,
    ROUND(SUM(CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS Male_Pct,
    ROUND(SUM(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS Female_Pct,
    ROUND(AVG(CAST(Length_of_Stay AS FLOAT)), 1) AS Avg_Stay,
    COUNT(*) AS Total_Encounters
FROM ER_Reporting
GROUP BY Medical_Condition
ORDER BY Total_Encounters DESC