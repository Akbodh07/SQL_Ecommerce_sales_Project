# SQL_Ecommerce_sales_Project
E-Commerce Retail Data Analysis — SQL Server

## 📌 Project Overview
This project simulates a real-world scenario where a Data Analyst joins a company and is handed a raw, undocumented relational database for an e-commerce/retail business. The goal was to take the database from a raw, unstructured state to a fully cleaned, structured, and analysis-ready system — and then extract meaningful business insights from it using SQL Server (T-SQL).

The project covers the **complete lifecycle of a real analytics workflow**: data discovery, profiling, cleaning, structuring (constraints & indexing), exploratory analysis, and advanced customer/business analytics — exactly how an experienced analyst approaches a fresh dataset on Day 1 of a new role.

## 🎯 Objective / Motive
The primary motive of this project was to:
1. Practice and demonstrate **real-world SQL Server (T-SQL) skills** end-to-end — not just isolated queries, but the full workflow a professional analyst follows.
2. Take an **unstructured, undocumented raw database** (no primary keys, no foreign keys, no data type validation) and turn it into a clean, reliable, production-style database.
3. Apply that clean data to answer **real business questions** — revenue trends, customer behavior, product performance, delivery performance, and customer segmentation.
4. Build a portfolio-ready project that reflects how data analysis is actually done in industry, rather than just showcasing syntax.

## 🗂️ Dataset
A 10-table relational schema representing a retail/e-commerce business:

| Table | Description |
|---|---|
| `customers` | Customer master data |
| `employees` | Staff data, including manager hierarchy |
| `suppliers` | Vendor/supplier master data |
| `shippers` | Logistics/shipping partner data |
| `categories` | Product category master |
| `products` | Product catalog |
| `orders` | Order-level transactions |
| `order_items` | Line-item level transaction detail (grain of the fact table) |
| `payments` | Payment transactions per order |
| `returns` | Product return/refund records |

**Scale:** ~50,000 orders, ~120,000 order line items, ~10,000 customers, spanning a 2-year transaction history.

## 🔍 Problems Identified in the Raw Data
When the database was first received, it had no documentation and several structural issues that had to be diagnosed and resolved before any analysis could be trusted:

- **No constraints at all** — no Primary Keys, Foreign Keys, or NOT NULL enforcement on any table.
- **Duplicate records** across almost every table (e.g., duplicate `customer_id`, `order_id`, `product_id` rows) caused by a flawed data load.
- **Data type inconsistencies** — e.g., `employees.manager_id` was stored as `VARCHAR` with values like `"18.0"` (a classic Excel-export artifact) instead of `INT`.
- **Nullable primary-key candidate columns** (e.g., `categories.category_id` allowed NULLs, blocking key creation).
- **No indexes** on any foreign-key columns, meaning every join across the ~120K-row fact table would require a full table scan.
- Multiple payment attempts per order (by design, via a `retry_count` field) that required deduplication logic before joining `orders` to `payments`.

## 🛠️ What Was Done — Step by Step

### 1. Discovery & Profiling
- Queried system catalogs (`sys.tables`, `INFORMATION_SCHEMA`) to inventory row counts, column structures, and existing constraints.
- Ran duplicate-detection queries (`GROUP BY ... HAVING COUNT(*) > 1`) on every table's primary-key candidate.
- Ran orphan-record checks (`LEFT JOIN ... IS NULL`) to confirm referential integrity between fact and dimension tables.
- Profiled NULLs across business-critical columns.

### 2. Data Cleaning
- Took full backups of every table before any destructive operation.
- Verified duplicates were true full-row duplicates (not conflicting versions of the same key) before removing them.
- Used `ROW_NUMBER() OVER (PARTITION BY ...)` inside a CTE to safely identify and remove duplicate rows.
- Fixed the `manager_id` data type issue using a safe migration pattern (`TRY_CAST` → new column → validate → drop old column → rename).
- Fixed nullable primary-key candidate columns with `ALTER COLUMN ... NOT NULL`.

### 3. Structuring the Database
- Added **Primary Keys** to all 10 tables.
- Added **Foreign Keys** to enforce all fact-to-dimension relationships (orders→customers, order_items→products, payments→orders, etc.), including a self-referencing FK for the employee-manager hierarchy.
- Added **non-clustered indexes** on all foreign-key columns to optimize join performance across the large fact tables.

### 4. Business Analysis
Using the now-clean, constrained database, analysis was performed in increasing order of complexity:
- **Core aggregation & filtering** — revenue snapshots, order/payment status breakdowns, city and category-level summaries.
- **Ranking & Top-N analysis** — top customers, top products per category using `ROW_NUMBER`, `RANK`, `DENSE_RANK`.
- **Time-series analysis** — month-over-month revenue growth, order gaps between purchases, delivery delay analysis using `LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE`, `DATEDIFF`, `DATEADD`.
- **Text & data cleaning functions** — email domain extraction, whitespace/formatting fixes using `SUBSTRING`, `CONCAT`, `REPLACE`, `TRIM`.
- **Advanced customer analytics**:
  - **RFM Segmentation** (Recency, Frequency, Monetary) using `NTILE` and CTEs to classify customers into segments like *Champions*, *Loyal Customers*, and *At Risk*.
  - **Cohort Analysis** to track customer retention by signup month.
  - **Running totals & moving averages** using window functions for cumulative revenue and trend smoothing.
- **Subqueries & set operators** — scalar, multi-row, and correlated subqueries; `EXISTS`; `UNION`, `UNION ALL`, `INTERSECT`, `EXCEPT` to answer questions like "customers who ordered but never returned anything."
- **Reporting layer** — built reusable SQL `VIEWs` (Customer 360, Monthly Performance, Product Performance) to simulate a lightweight dashboard layer on top of raw tables.

## 📊 Key Insights Uncovered
- Identified customers who registered but never placed an order (a re-engagement/marketing opportunity).
- Segmented the customer base into actionable groups (Champions, At Risk, etc.) using RFM analysis.
- Quantified how many orders had payment retries, which affects any 1:1 join assumption between `orders` and `payments`.
- Flagged products with zero units sold ("dead stock") for inventory review.
- Measured delivery performance (Late / On Time / Early) as an operational KPI.

## 🧰 Tools & Concepts Used
`SQL Server (T-SQL)` · Joins (`INNER`, `LEFT`, self-join) · `GROUP BY` / `HAVING` · Window Functions (`ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`, `LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE`) · CTEs · Subqueries (scalar, multi-row, correlated) · `EXISTS` · Set Operators (`UNION`, `INTERSECT`, `EXCEPT`) · String & Date functions · `CAST`/`CONVERT` · `COALESCE`/`ISNULL` · Constraints (PK/FK) · Indexing · Views

## 📁 Repository Structure
SQL_Ecommerce_sales_Project/
│
├── sql/
│ ├── bronze_table_creation.sql
│ ├── bronze_import_data.sql
│ ├── silver_data_cleaning.sql
│ ├── gold_business_analysis_1.sql
│ ├── gold_business_analysis_2.sql
│
└── README.md

## 🔮 Future Scope
- Automate the profiling/cleaning steps into a stored procedure or SSIS package.
- Convert key views into a Power BI / Tableau dashboard.
- Add data quality monitoring using SQL Agent jobs.

## 👤 Author
*Aman Kumar AK* — Data Analyst  
akky7982@gmail.com
