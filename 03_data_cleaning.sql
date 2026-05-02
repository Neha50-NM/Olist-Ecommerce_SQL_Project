-- ============================================
-- 🧹 DATA CLEANING & TRANSFORMATION LAYER
-- ============================================
-- Author: Meraj Sheikh
-- Description:
-- This script converts raw data into structured format.
-- It handles NULLs, fixes data types, enforces constraints,
-- and prepares data for analysis.
-- Business Rule:
-- Missing delivery dates are preserved as NULL since they indicate
-- undelivered or in-progress orders
----------------------------------

-- NOTE:
-- Run AFTER 02_data_loading.sql
-- ============================================

USE olist;

-- =====================================================
-- 1. ORDERS CLEANING
-- =====================================================

-- Convert empty strings to NULL
UPDATE orders
SET
order_approved_at = NULLIF(order_approved_at, ''),
order_delivered_carrier_date = NULLIF(order_delivered_carrier_date, ''),
order_delivered_customer_date = NULLIF(order_delivered_customer_date, '');

-- Convert data types + enforce PK
ALTER TABLE orders
MODIFY order_id VARCHAR(50) PRIMARY KEY,
MODIFY order_purchase_timestamp DATETIME,
MODIFY order_approved_at DATETIME,
MODIFY order_delivered_carrier_date DATETIME,
MODIFY order_delivered_customer_date DATETIME,
MODIFY order_estimated_delivery_date DATETIME;

-- =====================================================
-- 2. PRODUCTS CLEANING
-- =====================================================

-- Handle missing category names
UPDATE products
SET product_category_name = 'unknown'
WHERE product_category_name IS NULL;

-- Fix data types + PK
ALTER TABLE products
MODIFY product_id VARCHAR(50) PRIMARY KEY,
MODIFY product_category_name VARCHAR(100);

-- =====================================================
-- 3. ORDER ITEMS CLEANING
-- =====================================================

-- Fix datetime column
ALTER TABLE order_items
MODIFY shipping_limit_date DATETIME;

-- Ensure composite key uniqueness
ALTER TABLE order_items
ADD PRIMARY KEY (order_id, order_item_id);

-- =====================================================
-- 4. SELLERS CLEANING
-- =====================================================

-- Clean state column
UPDATE sellers
SET seller_state = TRIM(REPLACE(REPLACE(seller_state, '\r', ''), '\n', ''));

-- Remove invalid records
DELETE FROM sellers
WHERE LENGTH(seller_state) != 2;

-- Add primary key
ALTER TABLE sellers
ADD PRIMARY KEY (seller_id);

-- Remove orphan seller records from order_items
DELETE oi
FROM order_items oi
LEFT JOIN sellers s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- =====================================================
-- 5. PAYMENTS CLEANING
-- =====================================================

-- Fix formatting issues
UPDATE payments
SET order_id = REPLACE(order_id, '"', '');

-- Remove invalid payment types
DELETE FROM payments
WHERE payment_type = 'not_defined';

-- Add composite primary key
ALTER TABLE payments
ADD PRIMARY KEY (order_id, payment_sequential);

-- =====================================================
-- 6. REVIEWS TRANSFORMATION (RAW → CLEAN)
-- =====================================================

-- Create clean reviews table
CREATE TABLE reviews AS
SELECT
review_id,
order_id,
review_score,
review_comment_title,
review_comment_message,
NULLIF(review_creation_date, '0000-00-00 00:00:00') AS review_creation_date,
NULLIF(review_answer_timestamp, '0000-00-00 00:00:00') AS review_answer_timestamp
FROM reviews_raw;

-- Convert to datetime
ALTER TABLE reviews
MODIFY review_creation_date DATETIME,
MODIFY review_answer_timestamp DATETIME;

-- Add primary key
ALTER TABLE reviews
ADD PRIMARY KEY (review_id, order_id);

-- =====================================================
-- 7. GEOLOCATION TRANSFORMATION (RAW → AGGREGATED)
-- =====================================================

CREATE TABLE geolocation AS
SELECT
geolocation_zip_code_prefix AS zip_code_prefix,
AVG(CAST(geolocation_lat AS DECIMAL(10,6))) AS lat,
AVG(CAST(geolocation_lng AS DECIMAL(10,6))) AS lng,
MIN(geolocation_city) AS city,
MIN(geolocation_state) AS state
FROM geolocation_raw
GROUP BY geolocation_zip_code_prefix;

-- Add primary key
ALTER TABLE geolocation
MODIFY zip_code_prefix VARCHAR(10);

ALTER TABLE geolocation
ADD PRIMARY KEY (zip_code_prefix);

-- =====================================================
-- 8. CATEGORY TABLE
-- =====================================================

ALTER TABLE category_translation
ADD PRIMARY KEY (product_category_name);

-- =====================================================
-- 9. REFERENTIAL INTEGRITY CHECKS
-- =====================================================

-- Orders without customers
SELECT COUNT(*) AS invalid_orders
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Order items without orders
SELECT COUNT(*) AS invalid_order_items
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Order items without products
SELECT COUNT(*) AS invalid_products
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Payments without orders
SELECT COUNT(*) AS invalid_payments
FROM payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Reviews without orders
SELECT COUNT(*) AS invalid_reviews
FROM reviews r
LEFT JOIN orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- =====================================================
-- 10. FOREIGN KEY CONSTRAINTS
-- =====================================================

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_items_orders
FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_items_products
FOREIGN KEY (product_id) REFERENCES products(product_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_items_sellers
FOREIGN KEY (seller_id) REFERENCES sellers(seller_id);

ALTER TABLE payments
ADD CONSTRAINT fk_payments_orders
FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_orders
FOREIGN KEY (order_id) REFERENCES orders(order_id);

-- ============================================
-- ✅ DATA CLEANING COMPLETE
-- ============================================
