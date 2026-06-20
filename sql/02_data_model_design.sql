-- =====================================================
-- DATA MODEL DESIGN
-- Superstore Sales Analysis
-- =====================================================

-- =====================================================
-- MODEL OVERVIEW
-- =====================================================

-- Schema Type:
-- Star Schema

-- Fact Table:
-- sales

-- Dimension Tables:
-- customers
-- products
-- orders

-- Date Dimension:
-- Created in Power BI using DAX.

-- =====================================================
-- CUSTOMER DIMENSION DESIGN
-- =====================================================

-- customer_id selected as business key.

CREATE TABLE customers (
customer_id VARCHAR(20) PRIMARY KEY,
customer_name VARCHAR(100),
segment VARCHAR(50)
);

-- =====================================================
-- PRODUCT DIMENSION DESIGN
-- =====================================================

-- Exploration identified inconsistent product identifiers.

-- Findings:
-- Multiple product_ids were associated with the same
-- product_name and vice versa.

-- Decision:
-- Introduce product_key as a surrogate primary key.

-- product_id retained as source-system identifier.

-- product_name retained as primary business identifier.

CREATE TABLE products (
product_key INT AUTO_INCREMENT PRIMARY KEY,
product_id VARCHAR(50),
product_name VARCHAR(255),
category VARCHAR(100),
sub_category VARCHAR(100)
);

-- =====================================================
-- ORDERS DIMENSION DESIGN
-- =====================================================

-- order_id could not be used as a primary key because
-- same order_id appeared multiple times 

-- Decision:
-- Introduce row_id as surrogate key.

-- Geographic attributes moved to the Orders table.

CREATE TABLE orders (
    row_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50) ,
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(30),
    country VARCHAR(30),
    city VARCHAR(30),
    state VARCHAR(50),
    postal_code INT,
    region VARCHAR(50),
    customer_id VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- =====================================================
-- SALES FACT TABLE DESIGN
-- =====================================================

-- Grain:
-- One row per order-product transaction.

-- product_key added to the sales fact table.

-- Reason:
-- product_id alone could not establish a reliable
-- relationship with the product dimension.

-- During data loading, both product_id and product_name
-- are used to map records to product_key.

-- This ensures a one-to-many relationship between
-- Products and Sales and prevents many-to-many
-- relationships in the analytical model.

CREATE TABLE sales(
    sales_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(50),
    order_id VARCHAR(50),
    product_key INT,
    quantity INT,
    sales DECIMAL(10,2),
    profit DECIMAL(10,2),
    discount DECIMAL(4,2),

    FOREIGN KEY (product_key)
    REFERENCES products(product_key)
);

-- =====================================================
-- RELATIONSHIP DESIGN
-- =====================================================
-- customers → sales (via customer_id) One-to-Many
-- orders    → sales (via order_id)    One-to-Many  
-- products  → sales (via product_key) One-to-Many
--
-- Relationship Type: One-to-Many
-- All dimensions connect to sales fact table

-- =====================================================
-- MODEL OBJECTIVE
-- =====================================================

-- The model was designed to:
-- 1. Support scalable business analysis.
-- 2. Eliminate ambiguous product relationships.
-- 3. Enable efficient Power BI reporting.
-- 4. Follow dimensional modeling best practices.
