/*
===============================================================================
ADVANCED ANALYTICS - GOLD LAYER
===============================================================================
Purpose:
    - Perform advanced analytical queries on gold layer tables
    - Analyze trends, performance, segmentation, and business KPIs
    - Build reusable reporting views for customers and products

Tables Used:
    - gold.fact_sales
    - gold.dim_customers
    - gold.dim_products

SQL Concepts Used:
    - Window Functions (LAG, AVG OVER, SUM OVER)
    - CTEs (Common Table Expressions)
    - Aggregations (SUM, COUNT, AVG)
    - Date Functions (YEAR, MONTH, DATEDIFF, DATETRUNC)
    - Conditional Logic (CASE WHEN)
===============================================================================
*/

USE DataWarehouse;


/*
===============================================================================
TIME-BASED SALES ANALYSIS
===============================================================================
Purpose:
    - Analyze how sales performance evolves over time
    - Identify trends and seasonality
===============================================================================
*/

SELECT 
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
    YEAR(order_date),
    MONTH(order_date)
ORDER BY 
    order_year,
    order_month;

-- Monthly aggregation across all years
SELECT 
    MONTH(order_date) AS order_month,
    SUM(sales) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY order_month;


/*
===============================================================================
CUMULATIVE ANALYSIS
===============================================================================
Purpose:
    - Calculate running totals and moving averages over time
===============================================================================
*/

-- Running total of monthly sales
WITH monthly_sales AS (
    SELECT 
        MONTH(order_date) AS order_month,
        SUM(sales) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY MONTH(order_date)
)
SELECT 
    order_month,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_month) AS running_total_sales
FROM monthly_sales
ORDER BY order_month;


-- Yearly running total & moving average
WITH yearly_sales AS (
    SELECT 
        DATETRUNC(YEAR, order_date) AS order_year,
        SUM(sales) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(YEAR, order_date)
)
SELECT 
    order_year,
    total_sales,
    avg_price,
    SUM(total_sales) OVER (ORDER BY order_year) AS running_total_sales,
    AVG(avg_price) OVER (ORDER BY order_year) AS moving_avg_price
FROM yearly_sales;


/*
===============================================================================
PRODUCT PERFORMANCE ANALYSIS
===============================================================================
Purpose:
    - Compare product sales vs average performance and previous year
===============================================================================
*/

WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales) AS current_sales
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)
SELECT 
    order_year,
    product_name,
    current_sales,

    -- Average comparison
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_from_avg,
    CASE 
        WHEN current_sales > AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Above Avg'
        WHEN current_sales < AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_performance,

    -- Previous year comparison
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS previous_year_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_from_previous_year,
    CASE 
        WHEN current_sales > LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Increase'
        WHEN current_sales < LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Decrease'
        ELSE 'No Change'
    END AS yearly_trend

FROM yearly_product_sales
ORDER BY product_name, order_year;


/*
===============================================================================
CATEGORY CONTRIBUTION ANALYSIS
===============================================================================
Purpose:
    - Determine contribution of each category to total sales
===============================================================================
*/

WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales) AS total_sales
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    GROUP BY p.category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    CONCAT(
        ROUND((CAST(total_sales AS FLOAT) / NULLIF(SUM(total_sales) OVER (), 0)) * 100, 2),
        '%'
    ) AS percentage_contribution
FROM category_sales
ORDER BY total_sales DESC;


/*
===============================================================================
PRODUCT COST SEGMENTATION
===============================================================================
Purpose:
    - Segment products into cost ranges
===============================================================================
*/

WITH product_segments AS (
    SELECT 
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500 - 1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;


/*
===============================================================================
CUSTOMER SEGMENTATION (SPENDING BEHAVIOR)
===============================================================================
Purpose:
    - Segment customers into VIP, Regular, and New
===============================================================================
*/

WITH customer_lifespan AS (
    SELECT 
        c.customer_key,
        SUM(f.sales) AS total_spending,
        MIN(f.order_date) AS first_order_date,
        MAX(f.order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan_months
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
),
customer_segments AS (
    SELECT
        customer_key,
        total_spending,
        lifespan_months,
        CASE 
            WHEN total_spending > 5000 AND lifespan_months >= 12 THEN 'VIP'
            WHEN total_spending <= 5000 AND lifespan_months >= 12 THEN 'Regular'
            ELSE 'New'
        END AS segment
    FROM customer_lifespan
)
SELECT
    segment,
    COUNT(*) AS total_customers
FROM customer_segments
GROUP BY segment
ORDER BY total_customers DESC;


/*
===============================================================================
CUSTOMER REPORT (VIEW)
===============================================================================
Purpose:
    - Consolidated customer-level KPIs and segmentation
===============================================================================
*/

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

WITH base_query AS (
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_customers AS c
        ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
),

customer_aggregation AS (
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
)

SELECT
    customer_key,
    customer_number,
    customer_name,
    age,

    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
    END AS age_group,

    CASE 
        WHEN total_sales > 5000 AND lifespan >= 12 THEN 'VIP'
        WHEN total_sales <= 5000 AND lifespan >= 12 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    last_order_date,
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency_months,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,

    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,

    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend
FROM customer_aggregation;
GO


/*
===============================================================================
PRODUCT REPORT (VIEW)
===============================================================================
Purpose:
    - Consolidated product-level KPIs and performance segmentation
===============================================================================
*/

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH product_base AS (
    SELECT 
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost,
        f.quantity,
        f.sales,
        f.order_number,
        f.customer_key,
        f.order_date
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),

product_aggregation AS (
    SELECT 
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS unique_customers,
        SUM(sales) AS total_sales,
        SUM(quantity) AS total_quantity,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        ROUND(AVG(CAST(sales AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
    FROM product_base
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_order_date,
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency_months,

    CASE 
        WHEN total_sales > 100000 THEN 'High Performer'
        WHEN total_sales BETWEEN 30000 AND 100000 THEN 'Mid Performer'
        ELSE 'Low Performer'
    END AS performance_segment,

    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    unique_customers,

    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE CAST(total_sales AS FLOAT) / total_orders
    END AS avg_order_revenue,

    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue

FROM product_aggregation;
GO


-- Final Checks
SELECT * FROM gold.report_customers;
SELECT * FROM gold.report_products;
