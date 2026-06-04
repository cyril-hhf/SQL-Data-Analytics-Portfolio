-- Create production core schema
CREATE SCHEMA IF NOT EXISTS core;

-- Drop tables in reverse order of dependencies to avoid constraint errors
DROP TABLE IF EXISTS core.fact_order_items;
DROP TABLE IF EXISTS core.fact_orders;
DROP TABLE IF EXISTS core.dim_products;
DROP TABLE IF EXISTS core.dim_sellers;
DROP TABLE IF EXISTS core.dim_customers;

-- ============================================================================
-- 1. DIMENSION: CUSTOMERS
-- ============================================================================
CREATE TABLE core.dim_customers (
    customer_key VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50) NOT NULL,    
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

-- ============================================================================
-- 2. DIMENSION: SELLERS
-- ============================================================================
CREATE TABLE core.dim_sellers (
    seller_key VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);

-- ============================================================================
-- 3. DIMENSION: PRODUCTS
-- ============================================================================
CREATE TABLE core.dim_products (
    product_key VARCHAR(50) PRIMARY KEY,
    product_category_name_pt VARCHAR(100),
    product_category_name_en VARCHAR(100), -- populate in later
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- ============================================================================
-- 4. FACT: ORDERS
-- ============================================================================
CREATE TABLE core.fact_orders (
    order_key VARCHAR(50) PRIMARY KEY,
    customer_key VARCHAR(50) REFERENCES core.dim_customers(customer_key), -- enforces referential integrity
    order_status VARCHAR(20) NOT NULL,
    purchase_at TIMESTAMP NOT NULL,
    approved_at TIMESTAMP,
    delivered_carrier_at TIMESTAMP,
    delivered_customer_at TIMESTAMP,
    estimated_delivery_at TIMESTAMP
);

-- ============================================================================
-- 5. FACT: ORDER ITEMS
-- ============================================================================
CREATE TABLE core.fact_order_items (
    order_item_id INT NOT NULL,
    order_key VARCHAR(50) REFERENCES core.fact_orders(order_key),
    product_key VARCHAR(50) REFERENCES core.dim_products(product_key),
    seller_key VARCHAR(50) REFERENCES core.dim_sellers(seller_key),
    shipping_limit_at TIMESTAMP,
    price NUMERIC(10, 2) NOT NULL,
    freight_value NUMERIC(10, 2) NOT NULL,
    PRIMARY KEY (order_key, order_item_id)
);