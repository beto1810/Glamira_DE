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
    B.value_id AS main_stone_id,
    B.value_label AS main_stone_value,
    B.quality AS main_stone_quality,
    B.quality_label AS main_stone_label

FROM 
    Option_CTE A,
    UNNEST(A.option) AS B  -- Unnest the option array to work with individual records
WHERE 
    B.option_label = 'diamond'  -- Filter for diamond options
