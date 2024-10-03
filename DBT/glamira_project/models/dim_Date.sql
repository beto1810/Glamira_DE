CREATE OR REPLACE TABLE `glamira_transform.dim_date` AS
WITH DateRange AS (
    SELECT 
        MIN(DATE_TRUNC(TIMESTAMP_SECONDS(time_stamp), MONTH)) AS start_date,
        MAX(DATE_TRUNC(TIMESTAMP_SECONDS(time_stamp), MONTH)) AS end_date
    FROM 
            `dek9-glamira-18.glamira_raw.glamira_data`
),
DateSeries AS (
    SELECT 
        DATE_ADD(DATE(start_date), INTERVAL n DAY) AS date
    FROM 
        DateRange,
        UNNEST(GENERATE_ARRAY(0, DATE_DIFF(DATE(end_date), DATE(start_date), DAY))) AS n
),
DateAttributes AS (
    SELECT 
        date AS date_key,
        date,
        EXTRACT(YEAR FROM date) AS year,
        EXTRACT(QUARTER FROM date) AS quarter,
        EXTRACT(MONTH FROM date) AS month,
        EXTRACT(DAY FROM date) AS day,
        EXTRACT(DAYOFWEEK FROM date) AS day_of_week,
        EXTRACT(WEEK FROM date) AS week_of_year,
        CASE 
            WHEN EXTRACT(DAYOFWEEK FROM date) IN (1, 7) THEN TRUE
            ELSE FALSE
        END AS is_weekend
    FROM 
        DateSeries
)

SELECT *
FROM 
    DateAttributes;