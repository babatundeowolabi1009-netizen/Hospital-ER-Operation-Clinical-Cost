# Hospital-ER-Operation-Clinical-Cost
Hospital administrators often struggle to balance quality of care (clinical outcomes) with operational efficiency (billing and hospital stay duration). I built this project to bridge that gap. Using a synthetic dataset of 55,500 ER encounters, I analyzed and developed a full data pipeline that powers BI visualizations.

I structured this project like a real-world healthcare data task. After analyzing various categories, I built a SQL foundation to ensure any potential dashboard or reporting remains fast and accurate.
Phase 1 - The data audit: I started by testing the Kaggle data. I wrote cleaning scripts to handle all nulls, errors, and negative billing amounts. 
Phase 2 - Dimensional modeling: To optimize Power BI performance, I created a Star Schema with dedicated lookup tables for Dates and Medical Conditions.
Phase 3 - Clinical enrichment: I noticed the raw data lacked context. I manually enriched the Medical Condition dimension with clinical descriptions and image URLs to create an interactive "Condition Profile" feature in the dashboard.
Phase 4 - Advanced analytics: I used Window Functions (RANK, NTILE, etc.) to identify the top 10% most expensive patient cohorts and analyze year-over-year revenue growth.
