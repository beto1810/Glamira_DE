CREATE OR REPLACE TABLE `glamira_transform.dim_exchange_rate` AS
SELECT '€' AS currency, 1.08 AS exchange_rate UNION ALL
SELECT 'CAD $' AS currency, 0.74 AS exchange_rate UNION ALL
SELECT 'kr' AS currency, 0.09 AS exchange_rate UNION ALL
SELECT 'Kč' AS currency, 0.045 AS exchange_rate UNION ALL
SELECT 'NZD $' AS currency, 0.62 AS exchange_rate UNION ALL
SELECT '£' AS currency, 1.25 AS exchange_rate UNION ALL
SELECT '$' AS currency, 1 AS exchange_rate UNION ALL
SELECT 'zł' AS currency, 0.23 AS exchange_rate UNION ALL
SELECT 'Ft' AS currency, 0.0027 AS exchange_rate UNION ALL
SELECT 'AU $' AS currency, 0.65 AS exchange_rate UNION ALL
SELECT 'CLP' AS currency, 0.0012 AS exchange_rate UNION ALL
SELECT 'SGD $' AS currency, 0.73 AS exchange_rate UNION ALL
SELECT 'CHF' AS currency, 1.12 AS exchange_rate UNION ALL
SELECT 'лв.' AS currency, 0.55 AS exchange_rate UNION ALL
SELECT 'kn' AS currency, 0.15 AS exchange_rate UNION ALL
SELECT '￥' AS currency, 0.0067 AS exchange_rate UNION ALL
SELECT 'MXN $' AS currency, 0.056 AS exchange_rate UNION ALL
SELECT 'HKD $' AS currency, 0.13 AS exchange_rate UNION ALL
SELECT '₱' AS currency, 0.017 AS exchange_rate;
