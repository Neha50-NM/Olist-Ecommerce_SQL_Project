# 🛒 Olist E-Commerce Data Analysis (SQL Project)

> Learning Project | Practicing real-world SQL on a Brazilian e-commerce dataset  
> Status: Completed | Level: Beginner → Intermediate SQL

---

## About This Project

Hi! I'm Neha Mahawar, a QA Engineer actively transitioning into Data Science & Data Analytics.

This is my first end-to-end SQL project where I analyzed a real-world e-commerce dataset to uncover actionable business insights. It helped me practice writing analytical SQL queries, working with relational databases, and thinking like a data analyst.

I chose this dataset because it's messy, realistic, and multi-table — exactly the kind of data a real analyst would work with.

---

## Problem Statement

E-commerce businesses often face challenges such as:

- Low customer retention
- Delivery inefficiencies
- Uneven seller performance

 This project tries to answer:

- Why are customers not returning?
- What drives customer satisfaction?
- Which sellers generate the most revenue?

## Tech Stack

| Tool | Usage |
| SQL (MySQL) | Primary analysis language |
| Data Cleaning | Handling NULLs, type fixes, deduplication |
| Analytical SQL | CTEs, Window Functions, Aggregations |
| Database Design| Keys, Relationships, Indexing |

## Project Structure
olist-ecommerce_SQL_Project/
│
├── sql/
│   ├── 01_schema.sql          → Raw table structures
│   ├── 02_data_loading.sql    → Data ingestion
│   ├── 03_data_cleaning.sql   → Data transformation
│   └── 04_analysis.sql        → Business insights queries
│
├── insights/
│   └── business_insights.md   → Summary of findings
│
└── README.md                  → You are here!

## My Workflow (Step-by-Step)

## Step 1 — Data Ingestion
- Loaded raw CSV files into MySQL
- Maintained raw structure for flexibility and reproducibility

### Step 2 — Data Cleaning (this was the hardest part for me!)
- Handled missing values using `NULLIF()`
- Preserved meaningful NULLs (e.g., orders that were never delivered)
- Fixed data type inconsistencies across date and numeric columns
- Verified referential integrity across joined tables

## Step 3 — Data Transformation
- Created clean, structured tables from raw data
- Aggregated geolocation data by state/city
- Standardized product category names and seller data

## Step 4 — Data Analysis
- Customer segmentation by purchase behaviour
- Seller performance ranking using window functions
- Delivery time impact on review scores
- Monthly revenue trend analysis

## Key Insights I Found

##  Customer Retention
1.Only ~3% of customers made a repeat purchase
This was surprising to me. It means the business is almost entirely dependent on new customer acquisition — a very costly strategy. Retention campaigns could significantly improve profitability.

## Customer Lifetime Value
2.Loyal customers spend approximately 4× more than one-time buyers
This reinforced why retention matters more than just acquisition volume.

## Delivery Impact on Ratings
3. Faster delivery = higher review scores — consistently
I found a clear negative correlation between delivery delay and customer rating. This was my favourite insight — easy to visualise and immediately actionable for logistics teams.

## Seller Contribution (80/20 Pattern)
4.Top sellers drive a disproportionate share of total revenue
Classic Pareto distribution. A small % of sellers account for the majority of GMV. Supporting top sellers better could meaningfully move revenue numbers.

## SQL Concepts I Practiced

- ✅ Common Table Expressions (CTEs)
- ✅ Window Functions — `RANK()`, `NTILE()`, `LAG()`
- ✅ Multi-table JOINs (INNER, LEFT)
- ✅ Aggregate functions — `SUM`, `AVG`, `COUNT`, `GROUP BY`
- ✅ Data Cleaning — `NULLIF()`, `COALESCE()`, `CAST()`
- ✅ Primary Keys, Foreign Keys, Indexing

## What I Learned

This project taught me more than just SQL syntax. I learned:
1. Data is messy— most of my time was spent cleaning, not querying
2. Business context matters — knowing 'why' a metric matters makes queries better
3. SQL is enough for real insights — you don't always need Python or ML
