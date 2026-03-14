/*
==============================================================
Quality Checks
==============================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schemas. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in the strings.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
==============================================================
*/

-- ===========================================================
-- Checking 'silver.crm_cust_info'
-- ===========================================================
-- Check for Nulls Or Duplicates in Primary Key
-- Expectation: No Results

SELECT
cst_id,
COUNT(*) AS count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- Check for unwanted spaces
-- Expection: No Results
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT * FROM bronze.crm_cust_info

-- Check for unwanted spaces
-- Expection: No Results
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)


-- Data Standardization & Consistency

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT * FROM silver.crm_cust_info

-- ===========================================================
-- Checking 'crm_prd_info'
-- ===========================================================

-- Check for Nulls Or Duplicates in Primary Key
-- Expectation: No Results

USE DataWarehouse

SELECT prd_id,
COUNT(*) AS Count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1

-- Check for Unwanted Spaces
-- Expectation: No Results

SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for Negative or Null Numbers
-- Expectation: No Results

SELECT prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0


-- Data Standardization and Consistency

SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for Invalid Order Date

SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt


SELECT * FROM silver.crm_prd_info


-- ===========================================================
-- Checking 'crm_sales_details'
-- ===========================================================

  
-- Check for extra spaces
-- Expectation: No Results

SELECT 
sls_ord_num
FROM
silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Check for extra spaces
-- Expectation: No Results

SELECT 
sls_prd_key
FROM
silver.crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key)


-- Check for data mapping
-- Expectation: No Results

SELECT 
sls_prd_key
FROM
silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)


SELECT 
sls_cust_id
FROM
silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)



-- Check for invalid dates

SELECT 
NULLIF(sls_order_dt,0) AS sls_order_dt
FROM
silver.crm_sales_details
WHERE sls_order_dt <= 0
OR LEN(sls_order_dt) != 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

SELECT
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
OR sls_order_dt > sls_due_dt

-- Check data consistency: Between Sales, Quatity, and Price
-- >> Sales = Quantity * Price
-- >> Values must not be null, zero or negative

-- RULES:
-- if sales is negative, zero or null, derive it using Quantity & Price
-- if price is zero or null, calculate it using Sales & Quantity
-- if price is negative, convert it to positive value


SELECT DISTINCT 
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,
CASE WHEN sls_sales IS NULL OR sls_sales < 0 OR sls_sales != sls_quantity * ABS(sls_price)
		 THEN sls_quantity * ABS(sls_price)
	 ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_price <=0
		 THEN sls_sales/sls_quantity
	 ELSE sls_price
END AS sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_price * sls_quantity
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

SELECT * FROM
silver.crm_sales_details


-- Checking Out of Range Date

SELECT DISTINCT
bdate 
FROM silver.erp_cust_az12
WHERE bdate > GETDATE()

-- Data Standardization & Consistency

SELECT DISTINCT gen
FROM silver.erp_cust_az12

-- ===========================================================
-- Checking ' erp_loc_a101'
-- ===========================================================

-- Data cleaning

SELECT cid
FROM silver.erp_loc_a101


-- Data Standardization & Consistency

SELECT DISTINCT cntry
FROM silver.erp_loc_a101
SELECT * FROM silver.erp_px_cat_g1v2
