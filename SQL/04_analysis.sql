-- ============================================
-- 📊 BUSINESS ANALYSIS & INSIGHTS
-- ============================================
-- Description:
-- This script generates business insights from the
-- cleaned e-commerce dataset.
-- This analysis simulates real-world business reporting
-- used by e-commerce companies for decision making
------------------------------

-- Focus Areas:
-- 1. Customer Behavior
-- 2. Seller Performance
-- 3. Delivery Impact
-- 4. Revenue Trends
--------------------

-- NOTE:
-- Run AFTER 03_data_cleaning.sql
-- ============================================

USE olist;

-- =====================================================
-- 1. CUSTOMER BEHAVIOR ANALYSIS
-- =====================================================

SELECT
COUNT(customer_id) AS total_customer_ids,
COUNT(DISTINCT customer_unique_id) AS unique_customers,
ROUND(
(COUNT(customer_id) - COUNT(DISTINCT customer_unique_id)) * 100.0
/ COUNT(customer_id), 2
) AS repeat_customer_pct
FROM customers;

/*
Insight:
Low repeat % (~3%) → major retention problem
*/

-- =====================================================
-- 2. ORDER STATUS DISTRIBUTION
-- =====================================================

SELECT
order_status,
COUNT(*) AS total_orders,
SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS pending_or_not_delivered
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

/*
Insight:
NULL delivery dates are NOT data issues
They represent ongoing / canceled orders
*/

-- =====================================================
-- 3. PAYMENT ANALYSIS
-- =====================================================

SELECT
payment_type,
COUNT(*) AS transactions,
ROUND(SUM(payment_value), 2) AS total_value,
ROUND(AVG(payment_value), 2) AS avg_transaction_value
FROM payments
GROUP BY payment_type
ORDER BY total_value DESC;

/*
Insight:
Identifies dominant payment methods → pricing & UX decisions
*/

-- =====================================================
-- 4. CUSTOMER SENTIMENT (REVIEWS)
-- =====================================================

SELECT
review_score,
COUNT(*) AS total_reviews,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct_distribution
FROM reviews
GROUP BY review_score
ORDER BY review_score;

/*
Insight:
Bimodal pattern → customers either LOVE or HATE the experience
*/

-- =====================================================
-- 5. CUSTOMER SEGMENTATION (LTV ANALYSIS)
-- =====================================================

WITH customer_orders AS (
SELECT
c.customer_unique_id,
COUNT(DISTINCT o.order_id) AS order_count,
ROUND(SUM(p.payment_value), 2) AS total_spend
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
)
SELECT
CASE
WHEN order_count = 1 THEN 'One-time'
WHEN order_count = 2 THEN 'Returning'
ELSE 'Loyal (3+)'
END AS customer_segment,
COUNT(*) AS customers,
ROUND(AVG(total_spend), 2) AS avg_spend
FROM customer_orders
GROUP BY customer_segment
ORDER BY customers DESC;

/*
Insight:
Loyal customers spend ~4x more → retention is more valuable than acquisition
*/

-- =====================================================
-- 6. SELLER PERFORMANCE ANALYSIS
-- =====================================================

WITH seller_metrics AS (
SELECT
s.seller_id,
s.seller_state,
COUNT(DISTINCT oi.order_id) AS total_orders,
ROUND(SUM(oi.price), 2) AS total_revenue
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id, s.seller_state
)
SELECT
seller_id,
seller_state,
total_orders,
total_revenue,
RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
NTILE(4) OVER (ORDER BY total_revenue DESC) AS performance_quartile
FROM seller_metrics
ORDER BY total_revenue DESC
LIMIT 10;

/*
Insight:
Top sellers drive majority revenue → key for partnerships & incentives
*/

-- =====================================================
-- 7. DELIVERY VS CUSTOMER SATISFACTION (CRITICAL)
-- =====================================================

WITH order_delivery_review AS (
SELECT
o.order_id,
r.review_score,
DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) AS delivery_days
FROM orders o
JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
)
SELECT
review_score,
COUNT(*) AS orders,
ROUND(AVG(delivery_days), 1) AS avg_delivery_days
FROM order_delivery_review
GROUP BY review_score
ORDER BY review_score;

/*
🚨 CRITICAL BUSINESS INSIGHT:
Delivery speed is the STRONGEST driver of customer satisfaction

Slower deliveries → lower ratings
Faster deliveries → higher ratings

This directly impacts:

* Customer retention
* Brand perception
* Revenue growth
  */

-- =====================================================
-- 8. MONTHLY REVENUE TREND
-- =====================================================

WITH monthly_revenue AS (
SELECT
DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
ROUND(SUM(payment_value), 2) AS revenue
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
)
SELECT
month,
revenue,
LAG(revenue) OVER (ORDER BY month) AS previous_month,
ROUND(
(revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0
/ LAG(revenue) OVER (ORDER BY month), 1
) AS growth_pct
FROM monthly_revenue
ORDER BY month;

/*
Insight:
Tracks business growth and seasonality patterns
*/

-- =====================================================
-- KPI SUMMARY (EXECUTIVE VIEW)
-- =====================================================

SELECT
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_revenue,
    ROUND(AVG(p.payment_value), 2) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id;

-- ============================================
-- ✅ ANALYSIS COMPLETE
-- ============================================
