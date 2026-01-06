/*
Title: ER charge and insurance provider analysis
Script: Insurance_analysis
Goal: Demonstrate analytical SQL for payer mix and revenue analysis
Author: Babatunde Owolabi
*/

-- 1. Payer Mix & Share
-- =======================
SELECT 
    Insurance_Provider,
    COUNT(*) AS Encounter_Count,
    SUM(Billing_Amount) AS Total_Billing,
    AVG(Billing_Amount) AS Avg_Billing,
    
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS Pct_Volume,
    ROUND(100.0 * SUM(Billing_Amount) / SUM(SUM(Billing_Amount)) OVER(), 2) AS Pct_of_Total_Billing,
    
    RANK() OVER (ORDER BY SUM(Billing_Amount) DESC) AS Billing_Rank
FROM ER_Reporting
GROUP BY Insurance_Provider
ORDER BY Total_Billing DESC;

-- 2. Admissions by Provider
-- ==========================
SELECT 
    Insurance_Provider,
    Admission_Type,
    COUNT(*) AS Encounter_Count,
    ROUND(AVG(Billing_Amount), 2) AS Avg_Bill
FROM ER_Reporting
GROUP BY Insurance_Provider, Admission_Type
ORDER BY Insurance_Provider, Encounter_Count DESC;

-- 3. Year-over-Year (YoY) Growth
-- ===============================
WITH annual_metrics AS (
    SELECT 
        YEAR(Date_of_Admission) AS Calendar_Year,
        Insurance_Provider,
        COUNT(*) AS Total_Encounters,
        SUM(Billing_Amount) AS Annual_Revenue
    FROM ER_Reporting
    GROUP BY YEAR(Date_of_Admission), Insurance_Provider
)
SELECT 
    curr.Insurance_Provider,
    curr.Calendar_Year,
    curr.Total_Encounters AS Current_Vol,
    prev.Total_Encounters AS Previous_Vol,
    
    curr.Total_Encounters - prev.Total_Encounters AS Volume_Change,
    ROUND(100.0 * (curr.Total_Encounters - prev.Total_Encounters) / NULLIF(prev.Total_Encounters, 0), 1) AS Total_Billing_Growth_Pct
FROM annual_metrics curr
LEFT JOIN annual_metrics prev 
    ON curr.Insurance_Provider = prev.Insurance_Provider 
    AND curr.Calendar_Year = prev.Calendar_Year + 1
WHERE curr.Calendar_Year > (SELECT MIN(YEAR(Date_of_Admission)) FROM ER_Reporting)
ORDER BY curr.Calendar_Year DESC, curr.Insurance_Provider