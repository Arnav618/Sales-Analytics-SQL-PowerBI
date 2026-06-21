-- =====================================================
-- BUSINESS ANALYSIS
-- Superstore Sales Analysis
-- =====================================================
-- This file contains analytical queries that translate
-- cleaned data into actionable business insights.
-- All queries run against the normalized star schema.
-- =====================================================

-- =====================================================
-- SECTION 1: Overall Business Performance
-- =====================================================
-- Business Question: How is the company performing overall?
-- Goal: Measure overall revenue generation and profitability.
-- Insight: Company generates strong revenue but operates
-- with a relatively thin profit margin of ~12%.

SELECT
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit)*100/SUM(sales), 2) AS profit_margin_pct
FROM sales;

-- =====================================================
-- SECTION 2: Category Performance
-- =====================================================
-- Business Question: Which product categories drive the business?
-- Goal: Identify categories contributing most to sales and profit.
-- Insight: A category may generate high sales but contribute
-- relatively little profit due to heavy discounting.

SELECT
    p.category,
    ROUND(SUM(s.sales),2) AS total_sales,
    ROUND(SUM(s.profit),2) AS total_profit,
    ROUND(SUM(s.profit)*100/SUM(s.sales),2) AS profit_margin
FROM sales s
JOIN products p USING(product_key)
GROUP BY p.category
ORDER BY total_sales DESC;

-- =====================================================
-- SECTION 3: Loss-Making Subcategories
-- =====================================================
-- Business Question: Which areas of the product portfolio
-- hurt profitability?
-- Goal: Identify subcategories generating negative profit.
-- Insight: Tables and Bookcases generate revenue but
-- consistently destroy profit due to heavy discounting.

SELECT
    p.sub_category,
    ROUND(SUM(s.sales),2) AS total_sales,
    ROUND(SUM(s.profit),2) AS total_profit,
    ROUND(SUM(s.profit)*100/SUM(s.sales),2) AS profit_margin,
    ROUND(AVG(s.discount)*100,2) AS avg_discount_pct
FROM sales s
JOIN products p USING(product_key)
GROUP BY p.sub_category
ORDER BY total_profit ASC;

-- =====================================================
-- SECTION 4: Discount Impact Analysis
-- =====================================================
-- Business Question: How do discounts affect profitability?
-- Goal: Determine at what discount level profit turns negative.
-- Insight: Profitability drops significantly once discounts
-- exceed 20%. Heavy discounting is the primary driver of losses.

SELECT
    CASE
        WHEN discount = 0 THEN '0%'
        WHEN discount <= 0.20 THEN '1-20%'
        WHEN discount <= 0.40 THEN '21-40%'
        ELSE '40%+'
    END AS discount_band,
    COUNT(*) AS total_orders,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit,
    ROUND(SUM(profit)*100/SUM(sales),2) AS profit_margin
FROM sales
GROUP BY discount_band
ORDER BY MIN(discount);

-- =====================================================
-- SECTION 5: Loss-Making Products
-- =====================================================
-- Business Question: Which individual products create losses?
-- Goal: Identify products responsible for largest profit erosion.
-- Insight: A small number of products account for a
-- disproportionate share of total losses.
-- Recommendation: Discontinue or reprice these products.

SELECT
    DENSE_RANK() OVER (ORDER BY SUM(s.profit) ASC) AS loss_rank,
    p.product_name,
    ROUND(SUM(s.sales),2) AS total_sales,
    ROUND(SUM(s.profit),2) AS total_profit
FROM sales s
JOIN products p USING(product_key)
GROUP BY p.product_name
HAVING SUM(s.profit) < 0
ORDER BY total_profit ASC;

-- =====================================================
-- SECTION 6: Regional Profitability
-- =====================================================
-- Business Question: Which regions perform best and worst?
-- Goal: Compare revenue and profitability across regions.
-- Insight: Some regions generate high revenue but
-- underperform significantly on profit margin.

SELECT
    o.region,
    ROUND(SUM(s.sales),2) AS total_sales,
    ROUND(SUM(s.profit),2) AS total_profit,
    ROUND(SUM(s.profit)*100/SUM(s.sales),2) AS profit_margin
FROM sales s
JOIN orders o USING(order_id)
GROUP BY o.region
ORDER BY total_profit DESC;

-- =====================================================
-- SECTION 7: Customer Segment Analysis
-- =====================================================
-- Business Question: Which customer segment is most valuable?
-- Goal: Compare revenue and profitability across segments.
-- Insight: Focus marketing and retention efforts on
-- most profitable customer segment.

SELECT
    c.segment,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    ROUND(SUM(s.sales),2) AS total_sales,
    ROUND(SUM(s.profit),2) AS total_profit,
    ROUND(SUM(s.profit)*100/SUM(s.sales),2) AS profit_margin
FROM sales s
JOIN customers c USING(customer_id)
GROUP BY c.segment
ORDER BY total_profit DESC;

-- =====================================================
-- SECTION 8: Top Customers by Profit
-- =====================================================
-- Business Question: Who are the most valuable customers?
-- Goal: Identify customers contributing highest profit.
-- Insight: A small group of customers contributes
-- a large share of overall profit.
-- SQL Skill: CTE + DENSE_RANK()

WITH customer_profit AS (
    SELECT
        DENSE_RANK() OVER(ORDER BY SUM(s.profit) DESC) AS profit_rank,
        c.customer_name,
        c.segment,
        ROUND(SUM(s.sales),2) AS total_sales,
        ROUND(SUM(s.profit),2) AS total_profit,
        ROUND(SUM(s.profit)*100/SUM(s.sales),2) AS profit_margin
    FROM sales s
    JOIN customers c USING(customer_id)
    GROUP BY c.customer_name, c.segment
)
SELECT *
FROM customer_profit
WHERE profit_rank <= 10;

-- =====================================================
-- SECTION 9: Yearly Performance
-- =====================================================
-- Business Question: How has the business performed over time?
-- Goal: Compare yearly sales and profit with growth rates.
-- Insight: Business is growing in sales but profit growth
-- may not follow the same trend.
-- SQL Skill: CTE + LAG()

WITH yearly_sales AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date) AS year,
        ROUND(SUM(s.sales),2) AS yearly_sales,
        ROUND(SUM(s.profit),2) AS yearly_profit
    FROM sales s
    JOIN orders o USING(order_id)
    GROUP BY EXTRACT(YEAR FROM o.order_date)
)
SELECT
    year,
    yearly_sales,
    yearly_profit,
    ROUND(
        (yearly_sales - LAG(yearly_sales) OVER(ORDER BY year))
        * 100 / LAG(yearly_sales) OVER(ORDER BY year),
        2
    ) AS sales_growth_pct,
    ROUND(
        (yearly_profit - LAG(yearly_profit) OVER(ORDER BY year))
        * 100 / LAG(yearly_profit) OVER(ORDER BY year),
        2
    ) AS profit_growth_pct
FROM yearly_sales
ORDER BY year;

-- =====================================================
-- SECTION 10: Monthly Growth Analysis
-- =====================================================
-- Business Question: How does performance change month to month?
-- Goal: Track business momentum and identify seasonal patterns.
-- Insight: Certain months consistently outperform others
-- indicating seasonal demand patterns.
-- SQL Skill: CTE + LAG()

WITH monthly_sales AS (
    SELECT
        MONTHNAME(o.order_date) AS month,
        MONTH(o.order_date) AS month_no,
        EXTRACT(YEAR FROM o.order_date) AS year,
        ROUND(SUM(s.sales),2) AS monthly_sales,
        ROUND(SUM(s.profit),2) AS monthly_profit
    FROM sales s
    JOIN orders o USING(order_id)
    GROUP BY year, month, month_no
)
SELECT
    month,
    year,
    monthly_sales,
    monthly_profit,
    ROUND(
        (monthly_sales - LAG(monthly_sales) OVER(ORDER BY year, month_no))
        * 100 / LAG(monthly_sales) OVER(ORDER BY year, month_no),
        2
    ) AS sales_growth_pct,
    ROUND(
        (monthly_profit - LAG(monthly_profit) OVER(ORDER BY year, month_no))
        * 100 / LAG(monthly_profit) OVER(ORDER BY year, month_no),
        2
    ) AS profit_growth_pct
FROM monthly_sales
ORDER BY year, month_no;

-- =====================================================
-- SECTION 11: Top Products Within Each Category
-- =====================================================
-- Business Question: Which products drive category performance?
-- Goal: Identify strongest products inside each category.
-- Insight: A few products account for most category revenue.
-- SQL Skill: CTE + DENSE_RANK() + PARTITION BY

WITH ranked_products AS (
    SELECT
        p.category,
        p.product_name,
        ROUND(SUM(s.sales),2) AS product_sales,
        ROUND(SUM(s.profit),2) AS product_profit,
        DENSE_RANK() OVER (
            PARTITION BY p.category
            ORDER BY SUM(s.sales) DESC
        ) AS product_rank
    FROM sales s
    JOIN products p USING(product_key)
    GROUP BY p.category, p.product_name
)
SELECT
    category,
    product_rank,
    product_name,
    product_sales,
    product_profit
FROM ranked_products
WHERE product_rank <= 5
ORDER BY category, product_rank;

-- =====================================================
-- SECTION 12: Ship Mode Analysis
-- =====================================================
-- Business Question: Which shipping methods are most used?
-- Goal: Understand shipping preferences and their impact.
-- Insight: Identifies if premium shipping affects profitability.

SELECT
    o.ship_mode,
    COUNT(*) AS total_orders,
    ROUND(SUM(s.sales),2) AS total_sales,
    ROUND(SUM(s.profit),2) AS total_profit,
    ROUND(SUM(s.profit)*100/SUM(s.sales),2) AS profit_margin
FROM sales s
JOIN orders o USING(order_id)
GROUP BY o.ship_mode
ORDER BY total_orders DESC;

-- =====================================================
-- BUSINESS RECOMMENDATIONS
-- =====================================================
-- Based on analysis findings:
--
-- 1. Cap discounts at 20% maximum
--    → Any discount above 20% generates negative profit
--
-- 2. Reassess Tables and Bookcases pricing
--    → Both subcategories consistently destroy profit
--
-- 3. Discontinue or reprice loss-making products
--    → Small number of products cause majority of losses
--
-- 4. Focus marketing on most profitable customer segment
--    → Highest profit segment deserves retention investment
--
-- 5. Investigate underperforming regions
--    → High revenue regions with low margins need review
