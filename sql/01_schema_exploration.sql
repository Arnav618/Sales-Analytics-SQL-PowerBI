-- =====================================================
-- SCHEMA EXPLORATION
-- Superstore Sales Analysis
-- =====================================================

-- =====================================================
-- Basic Data Profiling
-- =====================================================

-- Check null values in key columns

SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_orders,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_products,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customers,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) AS null_profit
FROM raw_sales;

-- Check negative sales or quantities

SELECT COUNT(*)
FROM raw_sales
WHERE sales < 0 OR quantity < 0;

-- Check date range

SELECT
    MIN(order_date),
    MAX(order_date)
FROM raw_sales;

-- Finding:
-- Date range: 2014-01-04 to 2017-12-30
-- No significant null value or date quality issues were identified.
-- Further investigation focused on duplicate-looking records
-- and identifier consistency.


-- =====================================================
-- Investigation 1: Repeated Order Records
-- =====================================================

SELECT rs.*
FROM raw_sales rs
JOIN (
SELECT order_id, customer_id, product_id
FROM raw_sales
GROUP BY order_id, customer_id, product_id
HAVING COUNT(*) > 1
) dup
ON rs.order_id = dup.order_id
AND rs.customer_id = dup.customer_id
AND rs.product_id = dup.product_id
ORDER BY order_id, customer_id, product_id;

-- Finding:
-- During data exploration, 16 records across 8 (Order ID, Product ID) 
-- pairs were found sharing the same Order ID and Product ID combination.
-- Sales, quantity, and profit values differed across records,
-- therefore these rows were retained as distinct transaction lines
-- rather than treated as duplicate records.

-- =====================================================
-- Investigation 2: Product ID Mapping Consistency
-- =====================================================

SELECT
product_id,
COUNT(DISTINCT product_name) AS product_count,
GROUP_CONCAT(
DISTINCT product_name
ORDER BY product_name
SEPARATOR ' | '
) AS product_names
FROM raw_sales
GROUP BY product_id
HAVING COUNT(DISTINCT product_name) > 1;

-- Finding:
-- 30 product_ids were associated with multiple product names,
-- indicating source data inconsistencies.

-- =====================================================
-- Investigation 3: Multiple IDs Assigned To Same Product
-- =====================================================

SELECT
product_name,
COUNT(DISTINCT product_id) AS id_count,
GROUP_CONCAT(
DISTINCT product_id
SEPARATOR ' | '
) AS all_product_ids
FROM raw_sales
GROUP BY product_name
HAVING COUNT(DISTINCT product_id) > 1;

-- Finding:
-- 16 products were associated with multiple product IDs,
-- indicating identifier inconsistency within the source dataset.
