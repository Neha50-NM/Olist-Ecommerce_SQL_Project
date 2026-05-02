-- ============================================
-- DATA LOADING SCRIPT (RAW → DATABASE)
-- ============================================
-- Description:
-- This script loads raw CSV files into MySQL tables.
-- Ensure correct file paths before execution.
-- NOTE:
-- This script assumes CSV files are downloaded locally.
-- Update file paths before execution.
-- ============================================

USE olist;

-- Enable file import (may require admin privileges)
SET GLOBAL local_infile = 1;

-- =========================
-- 1. CUSTOMERS
-- =========================
LOAD DATA LOCAL INFILE '/Users/meraz/Brazilian ECommerce/archive//olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =========================
-- 2. ORDERS
-- =========================
LOAD DATA LOCAL INFILE '/Users/meraz/Brazilian ECommerce/archive/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =========================
-- 3. PRODUCTS
-- =========================
LOAD DATA LOCAL INFILE '/Users/meraz/Brazilian ECommerce/archive/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =========================
-- 4. ORDER ITEMS
-- =========================
LOAD DATA LOCAL INFILE '/Users/meraz/Brazilian ECommerce/archive/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =========================
-- 5. SELLERS
-- =========================
LOAD DATA LOCAL INFILE '/Users/meraz/Brazilian ECommerce/archive/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =========================
-- 6. PAYMENTS
-- =========================
LOAD DATA LOCAL INFILE '/Users/meraz/Brazilian ECommerce/archive/olist_order_payments_dataset.csv'
INTO TABLE payments
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =========================
-- 7. REVIEWS (RAW LOAD)
-- =========================
LOAD DATA LOCAL INFILE '/Users/meraz/Brazilian ECommerce/archive/olist_order_reviews_dataset.csv'
INTO TABLE reviews_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =========================
-- 8. GEOLOCATION (RAW LOAD)
-- =========================
LOAD DATA LOCAL INFILE '/Users/meraz/Brazilian ECommerce/archive/olist_geolocation_dataset.csv'
INTO TABLE geolocation_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =========================
-- 9. CATEGORY TRANSLATION
-- =========================
LOAD DATA LOCAL INFILE '/Users/meraz/Brazilian ECommerce/archive/product_category_name_translation.csv'
INTO TABLE category_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =========================
-- ✅ QUICK DATA VALIDATION
-- =========================
SELECT 'customers' AS table_name, COUNT(*) AS rows_n FROM customers
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'reviews_raw', COUNT(*) FROM reviews_raw;


-- ============================================
-- ✅ DATA LOADING COMPLETE
-- ============================================
