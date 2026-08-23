/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

SELECT DB_NAME() AS CurrentDatabase;

USE DataWarehouse;
GO

SELECT SCHEMA_NAME(schema_id) AS SchemaName
FROM sys.schemas
WHERE name IN ('bronze', 'silver', 'gold');

IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
   DROP TABLE silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info(
    cust_id             INT,
    cust_key            NVARCHAR(50),
    cust_firstname      NVARCHAR(50),
    cust_lastname       NVARCHAR(50),
    cust_marital_status NVARCHAR(50),
    cust_gndr           NVARCHAR(50),
    cust_create_date    DATE
    );

IF OBJECT_ID('silver.crm_prod_info', 'U') IS NOT NULL
   DROP TABLE silver.crm_prod_info;

CREATE TABLE silver.crm_prod_info (
    prod_id       INT,
    cat_id        NVARCHAR(50),
    prod_key      NVARCHAR(50),
    prod_nm       NVARCHAR(50),
    prod_cost     INT,
    prod_line     NVARCHAR(50),
    prod_start_dt DATETIME,
    prod_end_dt   DATETIME
    );


IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
   DROP TABLE silver.crm_sales_details ;


CREATE TABLE silver.crm_sales_details (
    sales_ord_num      NVARCHAR(50),
    sales_prod_key     NVARCHAR(50),
    sales_cust_id      INT,
    sales_order_dt     DATE,
    sales_ship_dt      DATE,
    sales_due_dt       DATE,
    sales_sls          INT,
    sales_quantity     INT,
    sales_price        INT
    );


IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
   DROP TABLE silver.erp_loc_a101 ;

CREATE TABLE silver.erp_loc_a101 (
    cid     NVARCHAR(50),
    cntry   NVARCHAR(50)
    );

IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
   DROP TABLE silver.erp_cust_az12 ;

CREATE TABLE silver.erp_cust_az12 (
    cid     NVARCHAR(50),
    bdate   DATE,
    gen     NVARCHAR(50)
    );

IF OBJECT_ID('silver.erp_px_cat_glv2', 'U') IS NOT NULL
   DROP TABLE silver.erp_px_cat_glv2 ;

CREATE TABLE silver.erp_px_cat_glv2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50)
    );
