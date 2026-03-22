/*
========================================================
Schema Exploration
========================================================
Purpose:
 - Understand database structure and available tables
*/

-- List all tables
SELECT *
FROM INFORMATION_SCHEMA.TABLES;

-- List columns for customer table
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';
```

---

```sql
/*
========================================================
Data Exploration
========================================================
Purpose:
 - Understand key dimensions and distributions
*/

USE DataWarehouse;

-- Customer countries
SELECT DISTINCT country
FROM gold.dim_customers;

-- Product hierarchy
SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM gold.dim_products
ORDER BY 1,2,3;

-- Sales date range
SELECT
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS total_years
FROM gold.fact_sales;

-- Customer age extremes
SELECT
    MIN(birthdate) AS oldest_customer,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS age_oldest,
    MAX(birthdate) AS youngest_customer,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS age_youngest
FROM gold.dim_customers;
```

---

```sql
/*
========================================================
Measures Exploration
========================================================
Purpose:
 - Calculate core KPIs for business performance
*/

-- Total sales
SELECT SUM(sales) AS total_sales
FROM gold.fact_sales;

-- Total quantity sold
SELECT SUM(quantity) AS total_quantity
FROM gold.fact_sales;

-- Average selling price (ASP)
SELECT
    SUM(sales) / NULLIF(SUM(quantity), 0) AS avg_selling_price
FROM gold.fact_sales;

-- Total orders
SELECT COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;

-- Total products
SELECT COUNT(DISTINCT product_id) AS total_products
FROM gold.dim_products;

-- Total customers (active)
SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales;
```

---

```sql
/*
========================================================
Magnitude Analysis
========================================================
Purpose:
 - Understand distribution across dimensions
*/

-- Customers by country
SELECT
    country,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Customers by gender
SELECT
    gender,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Products by category
SELECT
    category,
    COUNT(DISTINCT product_id) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- Average cost per category
SELECT
    category,
    AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- Revenue per customer
SELECT
    cu.customer_id,
    cu.first_name,
    COALESCE(SUM(sa.sales), 0) AS total_revenue
FROM gold.dim_customers cu
LEFT JOIN gold.fact_sales sa
    ON cu.customer_key = sa.customer_key
GROUP BY cu.customer_id, cu.first_name
ORDER BY total_revenue DESC;

-- Items sold by country
SELECT
    cu.country,
    SUM(sa.quantity) AS items_sold
FROM gold.fact_sales sa
LEFT JOIN gold.dim_customers cu
    ON sa.customer_key = cu.customer_key
GROUP BY cu.country
ORDER BY items_sold DESC;
```

---

```sql
/*
========================================================
Ranking Analysis
========================================================
Purpose:
 - Identify top and bottom performers
*/

-- Top 5 products by revenue
SELECT TOP 5
    p.product_name,
    SUM(s.sales) AS total_revenue
FROM gold.dim_products p
LEFT JOIN gold.fact_sales s
    ON p.product_key = s.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Bottom 5 products
SELECT TOP 5
    p.product_name,
    SUM(s.sales) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON p.product_key = s.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC;

-- Top 5 products using window function
SELECT *
FROM (
    SELECT
        p.product_name,
        SUM(s.sales) AS total_revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(s.sales) DESC) AS rank_products
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON p.product_key = s.product_key
    GROUP BY p.product_name
) t
WHERE rank_products <= 5;

-- Bottom 3 customers by orders
SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders ASC;
```

---

## Key Skills Demonstrated

* SQL joins and aggregations
* Window functions (ROW_NUMBER)
* Data exploration and profiling
* KPI design (average selling price, revenue, orders)
* Business-oriented querying

---
