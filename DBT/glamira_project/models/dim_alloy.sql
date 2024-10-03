{{ config(
    materialized='table'  
) }}

WITH
Option_CTE AS (
    SELECT 
        DISTINCT
        B.option
    FROM 
        `dek9-glamira-18.glamira_raw.glamira_data` A, 
        UNNEST(A.cart_products) AS B
    WHERE  
        A.collection = "checkout_success"
)

SELECT 
    DISTINCT
    B.value_id AS alloy_id,
    B.value_label AS alloy_value,   
    B.quality AS alloy_quality,
    B.quality_label AS alloy_quality_label

FROM 
    Option_CTE A,
    UNNEST(A.option) AS B  -- Unnest the option array to work with individual records
WHERE 
    B.option_label = 'alloy'  -- Filter for alloy options
