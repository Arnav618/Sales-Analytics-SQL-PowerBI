-- =====================================================
-- DATA CLEANING & DATA LOADING
-- Superstore Sales Analysis
-- =====================================================

-- =====================================================
-- SECTION 1: Split Shipment Handling
-- =====================================================
-- During exploration, repeated order-product combinations
-- were identified in the source dataset.
--
-- Investigation showed that sales, profit and quantity
-- values differed across records, indicating legitimate
-- split shipments rather than duplicate entries.
--
-- Decision:
-- Preserve all transaction records to maintain
-- transaction-level accuracy and prevent loss of
-- business information.

-- =====================================================
-- SECTION 2: Customer Dimension Loading
-- =====================================================
-- Customer information was separated into a dedicated
-- dimension table to eliminate redundancy and support
-- customer-level analysis.
--
-- Location attributes excluded from this table
-- as they describe the delivery location per order
-- not the permanent customer profile.
-- Geographic attributes loaded into orders dimension.

INSERT INTO customers (
    customer_id,
    customer_name,
    segment
)
SELECT DISTINCT customer_id, customer_name, segment
FROM raw_sales;

-- =====================================================
-- SECTION 3: Product Dimension Loading
-- =====================================================
-- Product information was separated into a dedicated
-- dimension table to support category and sub-category
-- analysis while reducing duplication across transactions.
--
-- Product identifier inconsistencies were identified
-- during exploration.
-- DISTINCT applied on both product_id and product_name
-- to capture all unique product combinations.
-- product_key auto generates as surrogate PRIMARY KEY.

INSERT INTO products (
    product_id,
    product_name,
    category,
    sub_category
)
SELECT DISTINCT product_id, product_name, category, sub_category
FROM raw_sales;

-- =====================================================
-- SECTION 4: Orders Dimension Loading
-- =====================================================
-- Order-level attributes and geographic information
-- were isolated into an Orders dimension to support
-- regional and shipping analysis.
--
-- Geographic attributes placed here because location
-- describes delivery destination per transaction
-- not permanent customer address.
--
-- row_id used as surrogate PRIMARY KEY because
-- order_id appeared multiple times in source data
-- due to split shipments.
-- DISTINCT applied to create unique order-level records
-- for the Orders dimension.

INSERT INTO orders (
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    country,
    city,
    state,
    postal_code,
    region
)
SELECT DISTINCT order_id, order_date, ship_date, ship_mode,
               customer_id, country, city, state,
               postal_code, region
FROM raw_sales;

-- =====================================================
-- SECTION 5: Sales Fact Table Loading
-- =====================================================
-- The sales fact table stores transaction-level business
-- metrics including sales, profit, quantity and discount.
--
-- Product records were mapped using both product_id and
-- product_name to ensure accurate assignment of product_key
-- despite identifier inconsistencies discovered during
-- exploration.
--
-- No DISTINCT operation was applied during fact loading
-- because valid split shipment transactions must be
-- preserved at transaction level.

INSERT INTO sales (
    customer_id,
    order_id,
    product_key,
    quantity,
    sales,
    profit,
    discount
)
SELECT
    r.customer_id,
    r.order_id,
    p.product_key,
    r.quantity,
    r.sales,
    r.profit,
    r.discount
FROM raw_sales r
JOIN products p
    ON r.product_id = p.product_id
   AND r.product_name = p.product_name;

-- =====================================================
-- SECTION 6: Data Validation
-- =====================================================
-- Validation checks were performed after loading to
-- ensure that all dimension and fact tables were
-- populated successfully.

SELECT COUNT(*) AS customer_count FROM customers;
SELECT COUNT(*) AS product_count FROM products;
SELECT COUNT(*) AS order_count FROM orders;
SELECT COUNT(*) AS sales_count FROM sales;

-- Null check on fact table key columns
SELECT COUNT(*) AS null_keys FROM sales
WHERE product_key IS NULL
OR order_id IS NULL
OR customer_id IS NULL;
-- Expected result: 0

-- Surrogate key mapping validation
-- Confirms every raw_sales record
-- successfully matched to a product_key
SELECT COUNT(*) AS unmatched_products
FROM raw_sales r
LEFT JOIN products p
    ON r.product_id = p.product_id
   AND r.product_name = p.product_name
WHERE p.product_key IS NULL;
-- Expected result: 0
-- Any value above 0 indicates data loss
-- during sales fact table loading
