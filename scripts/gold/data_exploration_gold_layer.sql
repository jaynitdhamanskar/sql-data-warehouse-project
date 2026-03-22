/*
===============================================================================
DATA EXPLORATION - GOLD LAYER
===============================================================================
Purpose:
    - Perform exploratory analysis on gold layer tables
    - Understand data structure, distribution, and key business metrics
    - Generate insights across customers, products, and sales

Tables Used:
    - gold.fact_sales
    - gold.dim_customers
    - gold.dim_products

===============================================================================
*/


/*
===============================================================================
DATABASE METADATA EXPLORATION
===============================================================================
Purpose:
    - Explore available tables and columns in the database
===============================================================================
*/

SELECT *
FROM INFORMATION_SCHEMA.TABLES;

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

USE DataWarehouse;


/*
===============================================================================
DIMENSION EXPLORATION
===============================================================================
Purpose:
    - Understand unique values and distributions in dimensions
===============================================================================
*/

-- Countries of customers
SELECT DISTINCT country
FROM gold.dim_customers;

-- Product hierarchy (category, subcategory, product)
SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM gold.dim_products
ORDER BY category, subcategory, product_name;


/*
===============================================================================
DATE RANGE ANALYSIS
===============================================================================
Purpose:
    - Identify temporal boundaries of sales data
===============================================================================
*/

SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS total_years_of_sales
FROM gold.fact_sales;


/*
===============================================================================
CUSTOMER AGE ANALYSIS
===============================================================================
Purpose:
    - Identify youngest and oldest customers
===============================================================================
*/

SELECT 
    MIN(birthdate) AS oldest_customer_birthdate,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS age_of_oldest_customer,
    MAX(birthdate) AS youngest_customer_birthdate,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS age_of_youngest_customer
FROM gold.dim_customers;


/*
===============================================================================
KEY BUSINESS METRICS
===============================================================================
Purpose:
    - Calculate core KPIs for the business
===============================================================================
*/

-- Total Sales
SELECT SUM(sales) AS total_sales
FROM gold.fact_sales;

-- Total Quantity Sold
SELECT SUM(quantity) AS total_quantity
FROM gold.fact_sales;

-- Average Selling Price
SELECT SUM(sales) / NULLIF(SUM(quantity), 0) AS avg_selling_price
FROM gold.fact_sales;

-- Total Orders
SELECT COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;

-- Total Products
SELECT COUNT(DISTINCT product_id) AS total_products
FROM gold.dim_products;

-- Total Customers (who placed orders)
SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales;

-- Total Customers (dimension table)
SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM gold.dim_customers;


/*
===============================================================================
UNIFIED KPI REPORT
===============================================================================
Purpose:
    - Consolidated business metrics into a single result set
===============================================================================
*/

SELECT 'Total Sales' AS measure_name, SUM(sales) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Avg Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_id) FROM gold.dim_products
UNION ALL
SELECT 'Number of Customers', COUNT(DISTINCT customer_key) FROM gold.fact_sales;


/*
===============================================================================
MAGNITUDE ANALYSIS
===============================================================================
Purpose:
    - Analyze distributions across different dimensions
===============================================================================
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


/*
===============================================================================
CUSTOMER REVENUE ANALYSIS
===============================================================================
Purpose:
    - Calculate total revenue generated per customer
===============================================================================
*/

SELECT
    cu.customer_id,
    cu.first_name,
    COALESCE(SUM(sa.sales), 0) AS total_revenue
FROM gold.dim_customers AS cu
LEFT JOIN gold.fact_sales AS sa
    ON cu.customer_key = sa.customer_key
GROUP BY
    cu.customer_id,
    cu.first_name
ORDER BY total_revenue DESC;


/*
===============================================================================
GEOGRAPHICAL SALES DISTRIBUTION
===============================================================================
Purpose:
    - Analyze items sold across countries
===============================================================================
*/

SELECT 
    cu.country,
    COUNT(sa.quantity) AS items_sold
FROM gold.fact_sales AS sa
LEFT JOIN gold.dim_customers AS cu
    ON sa.customer_key = cu.customer_key
GROUP BY cu.country
ORDER BY items_sold DESC;


/*
===============================================================================
TOP / BOTTOM PRODUCT ANALYSIS
===============================================================================
Purpose:
    - Identify best and worst performing products
===============================================================================
*/

-- Top 5 products by revenue
SELECT TOP 5
    p.product_name,
    SUM(s.sales) AS total_revenue
FROM gold.dim_products AS p
LEFT JOIN gold.fact_sales AS s
    ON p.product_key = s.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Bottom 5 products by revenue
SELECT TOP 5
    p.product_name,
    SUM(s.sales) AS total_revenue
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
    ON p.product_key = s.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC;

-- Ranking using window function
SELECT *
FROM (
    SELECT 
        p.product_name,
        SUM(s.sales) AS total_revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(s.sales) DESC) AS product_rank
    FROM gold.fact_sales AS s
    LEFT JOIN gold.dim_products AS p
        ON p.product_key = s.product_key
    GROUP BY p.product_name
) ranked_products
WHERE product_rank <= 5;


/*
===============================================================================
LOW ENGAGEMENT CUSTOMERS
===============================================================================
Purpose:
    - Identify customers with the fewest orders
===============================================================================
*/

SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
    ON s.customer_key = c.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders ASC;
