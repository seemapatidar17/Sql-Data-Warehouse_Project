/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-------------------------CUTOMER DIMENSION VIEW--------------------------------

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
     ROW_NUMBER() OVER (ORDER BY cust_id) AS customer_key,
    ci.cust_id AS customer_id,
    ci.cust_key AS customer_number,
    ci.cust_firstname AS first_name,
    ci.cust_lastname  as last_name,
    la.cntry AS country,
    ci.cust_marital_status AS marital_status,
    CASE WHEN ci.cust_gndr != 'n/a' THEN ci.cust_gndr --CRM is the master for gender info
    ELSE COALESCE(ca.gen, 'n/a') --Fallback to ERP data
    END AS gender,
     ca.bdate AS birthdate,
    ci.cust_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cust_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON  ci.cust_key = la.cid

---------------------------------------PRODUCT DIMENSION VIEW-------------------------------------
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO
  
CREATE VIEW gold.dim_products AS 
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prod_start_dt, pn.prod_key) AS product_key,
    pn.prod_id AS product_id,
    pn.prod_key AS product_number,
    pn.prod_nm AS product_name,
    pn.cat_id AS categor_id,
    pc.cat AS category,
     pc.subcat AS subcategory,
     pc.maintenance,
    pn.prod_cost AS cost,
    pn.prod_line AS product_line,
    pn.prod_start_dt AS start_date
 FROM silver.crm_prod_info pn
  LEFT JOIN  
  silver.erp_px_cat_glv2 pc
  ON pn.cat_id  = pc.id
 WHERE prod_end_dt IS NULL --Filter out all historical data

-------------------------------------------ORDER FACT VIEW-------------------------------------------------
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

  
CREATE VIEW gold.fact_sales AS
SELECT
sd.sales_ord_num  AS order_number,
pr.product_key,
cu.customer_key,
sd.sales_order_dt AS order_date,
sd.sales_ship_dt AS shipping_date,
sd.sales_due_dt AS due_date,
sd.sales_sls AS sales_amount,
sd.sales_quantity AS quantity,
sd.sales_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sales_prod_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sales_cust_id = cu.customer_id

GO
