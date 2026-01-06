/*
Title: Emergency Room (ER) Data Analysis
Script: Data Cleaning & Transformation
Goal: Creating a cleaned table for analysis
Author: Babatunde Owolabi
*/

-- STEP 1: Create a cleaned table and handle basic formatting
-- ===========================================================
DROP TABLE IF EXISTS ER_Data_Cleaned

SELECT DISTINCT
    Age,
	Gender,
    UPPER(LEFT(Medical_Condition, 1)) + LOWER(SUBSTRING(Medical_Condition, 2, LEN(Medical_Condition))) AS Medical_Condition, 
	Date_of_Admission,
    Discharge_Date,
    COALESCE(Insurance_Provider, 'Unknown/Self-Pay') AS Insurance_Provider, 
    
	CASE 
        WHEN Billing_Amount < 0 THEN 0 
        ELSE Billing_Amount 
	END AS Billing_Amount,

	Admission_Type, Medication, Blood_Type, Test_Results

INTO ER_Data_Cleaned 
FROM ER_Data
WHERE Date_of_Admission IS NOT NULL;