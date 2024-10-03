{{ config(
    materialized='table'
) }}

WITH 
-- Step 1: Clean the price field
CleanedPrices AS (
    SELECT 
        A.order_id,
        B.product_id, 
        -- Convert timestamp to date
        DATE(TIMESTAMP_SECONDS(A.time_stamp)) AS order_date,
        A.ip, 
        B.option, 
        A.collection, 
        B.currency, 
        B.amount, 
        B.price,

        -- Clean the price field to handle various formats
        CASE 
            -- Format with dot as thousand separator and comma as decimal separator (e.g., 10.497.373,00)
            WHEN REGEXP_CONTAINS(TRIM(B.price), r'^[0-9]{1,3}(\.[0-9]{3})*,[0-9]{2}$') THEN 
                CAST(REPLACE(REPLACE(TRIM(B.price), '.', ''), ',', '.') AS FLOAT64)

            -- Format with comma as thousand separator and dot as decimal separator (e.g., 1,234.56)
            WHEN REGEXP_CONTAINS(TRIM(B.price), r'^[0-9]{1,3}(,[0-9]{3})*\.[0-9]{2}$') THEN 
                CAST(REPLACE(TRIM(B.price), ',', '') AS FLOAT64)

            -- Format with apostrophe as thousand separator and dot as decimal separator (e.g., 3'583.00)
            WHEN REGEXP_CONTAINS(TRIM(B.price), r"^\d+'?\d*\.\d{2}$") THEN 
                CAST(REPLACE(TRIM(B.price), "'", "") AS FLOAT64)

            -- Format with simple decimal (e.g., 1234.56 or 1234)
            WHEN REGEXP_CONTAINS(TRIM(B.price), r'^\d+(\.\d+)?$') THEN 
                CAST(TRIM(B.price) AS FLOAT64)

            -- Handle case like '20,933' converting to '20933'
            WHEN REGEXP_CONTAINS(TRIM(B.price), r'^\d{1,3}(,\d{3})*$') THEN 
                CAST(REPLACE(TRIM(B.price), ',', '') AS FLOAT64)

            -- Handle case like '61٫00' converting to '61'
            WHEN REGEXP_CONTAINS(TRIM(B.price), r'^\d+[\.٫]\d{2}$') THEN 
                CAST(TRIM(REGEXP_REPLACE(B.price, r'[٫.]', '')) AS FLOAT64)  -- Remove decimal for values like '61.00' or '61٫00'

            -- Handle multiple prices separated by spaces
            WHEN REGEXP_CONTAINS(TRIM(B.price), r'^\d+(\,\d{2})?(\s+\d+(\,\d{2})?)*$') THEN 
                CAST(REPLACE(TRIM(B.price), ',', '') AS FLOAT64)  -- Treat as one single price for now

            -- Format where other characters need to be replaced
            ELSE 
                NULL  -- Return NULL for unrecognized formats

        END AS new_price,

        -- Calculate total amount (price * quantity)
        B.amount * 
        CASE 
            -- Format with dot as thousand separator and comma as decimal separator (e.g., 10.497.373,00)
            WHEN REGEXP_CONTAINS(TRIM(B.price), r'^[0-9]{1,3}(\.[0-9]{3})*,[0-9]{2}$') THEN 
                CAST(REPLACE(REPLACE(TRIM(B.price), '.', ''), ',', '.') AS FLOAT64)

            -- Format with comma as thousand separator and dot as decimal separator (e.g., 1,234.56)
            WHEN REGEXP_CONTAINS(TRIM(B.price), r'^[0-9]{1,3}(,[0-9]{3})*\.[0-9]{2}$') THEN 
                CAST(REPLACE(TRIM(B.price), ',', '') AS FLOAT64)

            -- Format with apostrophe as thousand separator and dot as decimal separator (e.g., 3'583.00)
            WHEN REGEXP_CONTAINS(TRIM(B.price), r"^\d+'?\d*\.\d{2}$") THEN 
                CAST(REPLACE(TRIM(B.price), "'", "") AS FLOAT64)

            -- Format with simple decimal (e.g., 1234.56 or 1234)
            WHEN REGEXP_CONTAINS(TRIM(B.price), r'^\d+(\.\d+)?$') THEN 
                CAST(TRIM(B.price) AS FLOAT64)

            -- Handle case like '20,933' converting to '20933'
            WHEN REGEXP_CONTAINS(TRIM(B.price), r'^\d{1,3}(,\d{3})*$') THEN 
                CAST(REPLACE(TRIM(B.price), ',', '') AS FLOAT64)

            -- Handle case like '61٫00' converting to '61'
            WHEN REGEXP_CONTAINS(TRIM(B.price), r'^\d+[\.٫]\d{2}$') THEN 
                CAST(TRIM(REGEXP_REPLACE(B.price, r'[٫.]', '')) AS FLOAT64)  -- Remove decimal for values like '61.00' or '61٫00'

            -- Handle multiple prices separated by spaces
            WHEN REGEXP_CONTAINS(TRIM(B.price), r'^\d+(\,\d{2})?(\s+\d+(\,\d{2})?)*$') THEN 
                CAST(REPLACE(TRIM(B.price), ',', '') AS FLOAT64)  -- Treat as one single price for now

            -- Format where other characters need to be replaced
            ELSE 
                NULL  -- Return NULL for unrecognized formats

        END AS total_price

    FROM 
        `dek9-glamira-18.glamira_raw.glamira_data` A, 
        UNNEST(A.cart_products) AS B
    WHERE  
        A.collection = "checkout_success"
)

-- Step 2: Final SELECT to output the results
SELECT 
    A.order_id,
    C.product_id, 
    A.order_date,  -- Use the converted date
    A.ip, 
    A.collection, 
    A.currency, 
    A.amount, 
    A.price,
    A.new_price,
    A.total_price,
    A.total_price * ER.exchange_rate as usd_price,
    C.jewelry_category,
    -- Use conditional aggregation to get both diamond_id and alloy_id
    CASE WHEN B.option_label = "diamond" THEN B.value_id END AS main_stone_id,
    CASE WHEN B.option_label = "alloy" THEN B.value_id END AS alloy_id
FROM 
    CleanedPrices A,
    UNNEST(A.option) AS B
JOIN `dek9-glamira-18.glamira_transform.dim_product_info` C 
ON C.product_id = A.product_id
JOIN `glamira_transform.dim_exchange_rate` AS ER
ON A.currency = ER.currency 
WHERE A.new_price IS NOT NULL AND C.new_category != "Not Found"    -- Use IS NOT NULL to filter valid new prices
