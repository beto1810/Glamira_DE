{{ config(
    materialized='table'  
) }}

SELECT 
    DISTINCT 
    ip AS ip_address,  -- Use DISTINCT to ensure unique IPs
    city_name,
    country_code,
    country_name,
    latitude,
    longitude,
    region_name,
    timezone,
    zipcode
FROM 
    `dek9-glamira-18.glamira_raw.glamira_data`
