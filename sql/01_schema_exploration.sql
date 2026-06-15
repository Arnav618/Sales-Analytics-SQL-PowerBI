-- =====================================================
-- SCHEMA EXPLORATION
-- Superstore Sales Analysis
-- =====================================================

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
-- Repeated order-product combinations were identified.
-- Sales, quantity, and profit values differed across records,
-- indicating distinct transaction lines rather than duplicate records.

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
-- Some product_ids were associated with multiple product names,
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
-- Several products were associated with multiple product IDs,
-- indicating identifier inconsistency within the source dataset.
