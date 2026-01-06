/*
Title: Data_pipeline for ER Analytics Dashboard
Script: Calculated columns for visualization
Goal Creating final table for Power BI import
Author: Babatunde Owolabi
*/

-- 1. Create the final reporting table
-- ==================================
DROP TABLE IF EXISTS ER_Reporting

SELECT Age,
    Gender,
    Blood_Type,
    Medical_Condition,
    Date_of_Admission,
    Insurance_Provider,
    Billing_Amount,
    Admission_Type,
    Discharge_Date,
    Medication,
    Test_Results,
    DATEDIFF(day, Date_of_Admission, Discharge_Date) AS Length_of_Stay,

CASE 
	WHEN Age < 25 THEN 'Pediatric (0-24)'
	WHEN Age BETWEEN 25 AND 49 THEN 'Adult (25-49)'
	WHEN Age BETWEEN 50 AND 74 THEN 'Middle Age (50-74)'
	ELSE 'Senior (75+)'
END AS Age_Group,

YEAR(Date_of_Admission) AS Admission_Year,
MONTH(Date_of_Admission) AS Admission_Month,
DATENAME(month, Date_of_Admission) AS Month_Name,
DATEPART(quarter, Date_of_Admission) AS Admission_Quarter,

CASE 
    WHEN DATEDIFF(day, Date_of_Admission, Discharge_Date) <= 2 THEN 'Observation (1-2 days)'
    WHEN DATEDIFF(day, Date_of_Admission, Discharge_Date) BETWEEN 3 AND 5 THEN 'Short Stay (3-5 days)'
    WHEN DATEDIFF(day, Date_of_Admission, Discharge_Date) BETWEEN 6 AND 10 THEN 'Moderate (6-10 days)'
    WHEN DATEDIFF(day, Date_of_Admission, Discharge_Date) BETWEEN 11 AND 20 THEN 'Extended (11-20 days)'
    ELSE 'Long Stay (21+ days)'
END AS Stay_Category,

CASE 
    WHEN Billing_Amount < 5000 THEN 'Low Cost (<$5K)'
    WHEN Billing_Amount BETWEEN 5000 AND 15000 THEN 'Medium Cost ($5K-$15K)'
    WHEN Billing_Amount BETWEEN 15000 AND 30000 THEN 'High Cost ($15K-$30K)'
    ELSE 'Premium Cost (>$30K)'
END AS Billing_Tier

INTO ER_Reporting
	FROM ER_data_Cleaned
WHERE Discharge_Date IS NOT NULL  
  AND Date_of_Admission IS NOT NULL

-- 2. Filter out the "Impossible" data (Discharge before admission)
-- ================================================================
DELETE FROM ER_Reporting
WHERE Length_of_Stay < 0           
   OR Date_of_Admission > GETDATE()