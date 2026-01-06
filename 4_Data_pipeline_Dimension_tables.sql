/*
Title: Data_pipeline for ER Analytics Dashboard
Script: Dimensions table
Goal: Supporting the "Condition Profile" section of the Power BI dashboard
Author: Babatunde Owolabi
*/

DROP TABLE IF EXISTS dim_medical_conditions;

CREATE TABLE dim_medical_conditions (
    Condition_ID INT IDENTITY(1,1) PRIMARY KEY,
    Condition_Name VARCHAR(100) UNIQUE NOT NULL,
    Condition_Category VARCHAR(50),
    Condition_Description VARCHAR(1000),
    Image_URL VARCHAR(500)
);

-- 1. Pulling the unique conditions from the main data
-- ======================================================
INSERT INTO dim_medical_conditions (Condition_Name, Condition_Category)
SELECT DISTINCT 
    Medical_Condition,
    CASE 
        WHEN Medical_Condition IN ('Diabetes', 'Hypertension', 'Asthma', 'Cancer', 'Arthritis', 'Obesity') THEN 'Chronic'
        ELSE 'Acute'
    END
FROM ER_Reporting
WHERE Medical_Condition IS NOT NULL;


-- Manual addition of the medical conditions descriptions & image paths
-- =====================================================================
UPDATE dim_medical_conditions 
SET Condition_Description = 'Arthritis is the swelling & tenderness of one or more joints. The main symptoms are joint pain & stiffness.',
    Image_URL = 'https://springloadedtechnology.com/wp-content/uploads/2019/01/Asset-2-e1547822599337.png'
WHERE Condition_Name = 'Arthritis';

UPDATE dim_medical_conditions 
SET Condition_Description = 'Asthma is a condition in which airways narrow & swell & may produce extra mucus.',
    Image_URL = 'https://secure.caes.uga.edu/extension/publications/files/html/C1270/images/mceclip0.jpg'
WHERE Condition_Name = 'Asthma';

UPDATE dim_medical_conditions 
SET Condition_Description = 'Cancer is a condition in which some of the body’s cells grow uncontrollably & spread to other parts of the body.',
    Image_URL = 'https://ric.psu.edu.sa/assets/images/coronavirus1.png'
WHERE Condition_Name = 'Cancer';

UPDATE dim_medical_conditions 
SET Condition_Description = 'Chronic condition affecting blood sugar regulation & insulin production.',
    Image_URL = 'https://www.niddk.nih.gov/-/media/Images/Health-Information/Diabetes/BloodGlucoseImage2Feb231200x800.jpg'
WHERE Condition_Name = 'Diabetes';

UPDATE dim_medical_conditions 
SET Condition_Description = 'Hypertension is a condition that affects the body''s arteries.',
    Image_URL = 'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcROmyzuMnVyp0RxnRNboS77x059gDwD5nuEGAFknUP2Fr0LBZyi'
WHERE Condition_Name = 'Hypertension';

UPDATE dim_medical_conditions 
SET Condition_Description = 'Excessive body fat that increases risk of health problems such as heart disease, diabetes, & high blood pressure.',
    Image_URL = 'https://img.freepik.com/free-vector/obesity-problem-overweight-man-medical-consultation-diagnostics-negative-impact-obesity-humans-health-internal-organs-vector-isolated-concept-metaphor-illustration_335657-1305.jpg?semt=ais_hybrid&w=740&q=80'
WHERE Condition_Name = 'Obesity';

-- 2. Date Dimension (Calendar Table)
-- =================================
DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_date (
    Date_Key DATE PRIMARY KEY,
    Year INT,
    Quarter INT,
    Month INT,
    Month_Name VARCHAR(20),
    Day INT,
    Day_of_Week INT,
    Day_Name VARCHAR(20),
    Is_Weekend BIT,
    Fiscal_Year INT,
    Fiscal_Quarter INT)

-- Populate date dimension (2019-2024)
DECLARE @StartDate DATE = '2019-01-01';
DECLARE @EndDate DATE = '2024-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO dim_date VALUES (
        @StartDate,
        YEAR(@StartDate),
        DATEPART(quarter, @StartDate),
        MONTH(@StartDate),
        DATENAME(month, @StartDate),
        DAY(@StartDate),
        DATEPART(weekday, @StartDate),
        DATENAME(weekday, @StartDate),
        CASE WHEN DATEPART(weekday, @StartDate) IN (1,7) THEN 1 ELSE 0 END,
        YEAR(DATEADD(month, 6, @StartDate)), -- Fiscal year (July-June)
        DATEPART(quarter, DATEADD(month, 6, @StartDate)))
    SET @StartDate = DATEADD(day, 1, @StartDate);
END
