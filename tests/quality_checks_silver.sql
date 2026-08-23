/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    cust_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cust_id
HAVING COUNT(*) > 1 OR cust_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    cust_key 
FROM silver.crm_cust_info
WHERE cust_key != TRIM(cust_key);

-- Data Standardization & Consistency
SELECT DISTINCT 
    cust_marital_status 
FROM silver.crm_cust_info;

-- ====================================================================
-- Checking 'silver.crm_prod_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    prod_id,
    COUNT(*) 
FROM silver.crm_prod_info
GROUP BY prod_id
HAVING COUNT(*) > 1 OR prod_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    prod_nm 
FROM silver.crm_prd_info
WHERE prod_nm != TRIM(prod_nm);

-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
SELECT 
    prod_cost 
FROM silver.crm_prod_info
WHERE prod_cost < 0 OR prod_cost IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT 
    prod_line 
FROM silver.crm_prod_info;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT 
    * 
FROM silver.crm_prod_info
WHERE prod_end_dt < prod_start_dt;

-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================
-- Check for Invalid Dates
-- Expectation: No Invalid Dates
SELECT 
    NULLIF(sales_due_dt, 0) AS sales_due_dt 
FROM bronze.crm_sales_details
WHERE sales_due_dt <= 0 
    OR LEN(sales_due_dt) != 8 
    OR sales_due_dt > 20500101 
    OR sales_due_dt < 19000101;

-- Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expectation: No Results
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sales_order_dt > sales_ship_dt 
   OR sales_order_dt > sales_due_dt;

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT DISTINCT 
    sales_sls,
    sales_quantity,
    sales_price 
FROM silver.crm_sales_details
WHERE sales_sls != sls_quantity * sls_price
   OR sales_sls IS NULL 
   OR sales_quantity IS NULL 
   OR sales_price IS NULL
   OR sales_sls <= 0 
   OR sales_quantity <= 0 
   OR sales_price <= 0
ORDER BY sales_sls, sales_quantity, sales_price;

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================
-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today
SELECT DISTINCT 
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();

-- Data Standardization & Consistency
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;

-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================
-- Data Standardization & Consistency
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1=lv2'
-- ====================================================================
-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    * 
FROM silver.erp_px_cat_glv2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Data Standardization & Consistency
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_glv2;
