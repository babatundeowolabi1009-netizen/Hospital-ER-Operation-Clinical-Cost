/*
Title: Emergency Room (ER) Data Analysis
Script: Initial Data Profiling & Quality Check
Goal: To identify errors and clea data before analysis
Author: Babatunde Owolabi
*/

-- 1. Schema Overview & Null Check
-- =================================
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ER_Data';

-- Counting nulls in critical columns
SELECT
    COUNT(*) AS total_records,
    COUNT(CASE WHEN Billing_Amount IS NULL THEN 1 END) AS null_billing,
    COUNT(CASE WHEN date_of_admission IS NULL THEN 1 END) AS null_admission,
    COUNT(CASE WHEN discharge_date IS NULL THEN 1 END) AS null_discharge,
    COUNT(CASE WHEN medical_condition IS NULL OR medical_condition = '' THEN 1 END) AS missing_medical_condition,
    COUNT(CASE WHEN insurance_provider IS NULL OR insurance_provider = '' THEN 1 END) AS missing_insurance_provider
FROM ER_Data;

-- 2. Logic Check for Invalid Dates (where discharge is < admission or dates are in the future)
-- ==========================================================================================
SELECT 
    'Discharge before admission' AS issue_type,
    COUNT(*) AS record_count
FROM ER_Data
WHERE discharge_date < date_of_admission

UNION ALL

SELECT 
    'Future Admission Date',
    COUNT(*)
FROM ER_Data
WHERE date_of_admission > GETDATE();

-- 3. Outlier Detection (STD Method)
-- ==================================
WITH billing_stats AS (
    SELECT 
        AVG(Billing_Amount) AS avg_bill,
        STDEV(Billing_Amount) AS std_bill
    FROM ER_Data
    WHERE Billing_Amount IS NOT NULL
)
SELECT 
    'Outlier/Negative Bill' AS check_type,
    COUNT(*) AS outlier_count,
    MIN(Billing_Amount) AS min_val,
    MAX(Billing_Amount) AS max_val
FROM ER_Data
CROSS JOIN billing_stats
WHERE Billing_Amount > (avg_bill + (3 * std_bill))
   OR Billing_Amount < 0;

-- 4. Length of Stay (LOS) Validation
-- ===================================
WITH los_calculation AS (
    SELECT 
        Date_of_Admission,
        Discharge_Date,
        DATEDIFF(day, Date_of_Admission, Discharge_Date) AS days_stayed -- This is our "Helper Column"
    FROM ER_Data
    WHERE Discharge_Date IS NOT NULL
)
SELECT 
    COUNT(*) AS total_checked,
    SUM(CASE WHEN days_stayed < 0 THEN 1 ELSE 0 END) AS negative_stay_errors,
    SUM(CASE WHEN days_stayed > 180 THEN 1 ELSE 0 END) AS extreme_stay,
    AVG(days_stayed) AS avg_stay_duration,
    MAX(days_stayed) AS longest_stay
FROM los_calculation

-- 5. Duplicate Check (checking exact duplicates across all primary patient fields
-- ================================================================================
;WITH duplicate_finder AS (
    SELECT 
        Age, Gender, Date_of_Admission, Medical_Condition, Hospital, Billing_Amount,
        COUNT(*) AS occurrence_count
    FROM ER_Data
    GROUP BY Age, Gender, Date_of_Admission, Medical_Condition, Hospital, Billing_Amount
    HAVING COUNT(*) > 1
)
SELECT 
    COUNT(*) AS unique_groups_duplicated,
    SUM(occurrence_count) AS total_impacted_rows
FROM duplicate_finder

-- 6: Data Completeness by Year
-- ====================================
SELECT 
    YEAR(Date_of_Admission) AS admission_year,
    COUNT(*) AS encounter_count,
    MIN(Date_of_Admission) AS first_encounter,
    MAX(Date_of_Admission) AS last_encounter,
    DATEDIFF(month, MIN(Date_of_Admission), MAX(Date_of_Admission)) AS months_of_data,
    CASE 
        WHEN DATEDIFF(month, MIN(Date_of_Admission), MAX(Date_of_Admission)) < 11 
        THEN 'INCOMPLETE YEAR - POTENTIAL DATA ISSUE'
        ELSE 'Complete'
    END AS data_quality_flag
	FROM ER_data
WHERE Date_of_Admission IS NOT NULL
	GROUP BY YEAR(Date_of_Admission)
	ORDER BY admission_year

-- 7. Data Completeness
-- =======================
SELECT 
    YEAR(Date_of_Admission) AS adm_year,
    COUNT(*) AS total_encounters,
    DATEDIFF(month, MIN(Date_of_Admission), MAX(Date_of_Admission)) AS months_covered,
    CASE 
        WHEN DATEDIFF(month, MIN(Date_of_Admission), MAX(Date_of_Admission)) < 11 THEN 'Check for missing months'
        ELSE 'Full Year'
    END AS status
FROM ER_Data
WHERE Date_of_Admission IS NOT NULL
GROUP BY YEAR(Date_of_Admission)
ORDER BY adm_year;