/* 
Project: ER Clinical Analysis
Script: Impact of Test Results by LOS and Billing
Author: Babatunde Owolabi
Goal: Determining results impact by condition, LOS, and billing
*/

-- 1. Test Results Impact Summary
-- ===============================
SELECT 
    Test_Results,
    COUNT(*) AS Patient_Volume,
    ROUND(AVG(CAST(Length_of_Stay AS FLOAT)), 1) AS Avg_Stay_Days,
    ROUND(AVG(Billing_Amount), 2) AS Avg_Bill_Amount,
    ROUND(AVG(Billing_Amount) - FIRST_VALUE(AVG(Billing_Amount)) OVER (ORDER BY AVG(Billing_Amount) ASC), 2) AS Cost_Increase_Over_Base
FROM ER_Reporting
GROUP BY Test_Results
ORDER BY Avg_Bill_Amount DESC;

-- 2. Condition-specific Analysis
-- ===============================
SELECT 
    Medical_Condition,
    Test_Results,
    COUNT(*) AS Encounter_Count,
    ROUND(AVG(CAST(Length_of_Stay AS FLOAT)), 1) AS Avg_LOS,
    ROUND(AVG(Billing_Amount), 2) AS Avg_Billing
FROM ER_Reporting
WHERE Medical_Condition IN ('Cancer', 'Diabetes', 'Hypertension', 'Asthma', 'Obesity', 'Athritis')
GROUP BY Medical_Condition, Test_Results
ORDER BY Medical_Condition, Avg_LOS DESC;

-- 3. Result-specific (Abnormal Test Result and Very Short Hospital Stay) 
-- =====================================================================
SELECT 
    Medical_Condition,
    Admission_Type,
    Age_Group,
    Length_of_Stay,
    Billing_Amount
FROM ER_Reporting
WHERE Test_Results = 'Abnormal' 
  AND Length_of_Stay <= 1
ORDER BY Billing_Amount DESC