/*
-----------------------------------------------------------------------------------------------------
DDL Scripts: Create Bronze tables
-----------------------------------------------------------------------------------------------------
Script Purpose:
This scripts creates tables in the 'bronze' schema, droppping existing tables if they alredy exists.
Run this script to re-define the DDL structure of 'bronze' Tables
-----------------------------------------------------------------------------------------------------
*/

SELECT DB_NAME() AS CurrentDatabase;

USE DataWarehouse;
GO

SELECT SCHEMA_NAME(schema_id) AS SchemaName
FROM sys.schemas
WHERE name IN ('bronze', 'silver', 'gold');

IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
   DROP TABLE bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info(
    cust_id             INT,
    cust_key            NVARCHAR(50),
    cust_firstname      NVARCHAR(50),
    cust_lastname       NVARCHAR(50),
    cust_marital_status NVARCHAR(50),
    cust_gndr           NVARCHAR(50),
    cust_create_date    DATE
    );

IF OBJECT_ID('bronze.crm_prod_info', 'U') IS NOT NULL
   DROP TABLE bronze.crm_prod_info;

CREATE TABLE bronze.crm_prod_info (
    prod_id       INT,
    prod_key      NVARCHAR(50),
    prod_nm       NVARCHAR(50),
    prod_cost     INT,
    prod_line     NVARCHAR(50),
    prod_start_dt DATETIME,
    prod_end_dt   DATETIME
    );


IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
   DROP TABLE bronze.crm_sales_details ;


CREATE TABLE bronze.crm_sales_details (
    sales_ord_num      NVARCHAR(50),
    sales_prod_key     NVARCHAR(50),
    sales_cust_id      INT,
    sales_order_dt     INT,
    sales_ship_dt      INT,
    sales_due_dt       INT,
    sales_sls          INT,
    sales_quantity     INT,
    sales_price        INT
    );


IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
   DROP TABLE bronze.erp_loc_a101 ;

CREATE TABLE bronze.erp_loc_a101 (
    cid     NVARCHAR(50),
    cntry   NVARCHAR(50)
    );

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
   DROP TABLE bronze.erp_cust_az12 ;

CREATE TABLE bronze.erp_cust_az12 (
    cid     NVARCHAR(50),
    bdate   DATE,
    gen     NVARCHAR(50)
    );

IF OBJECT_ID('bronze.erp_px_cat_glv2', 'U') IS NOT NULL
   DROP TABLE bronze.erp_px_cat_glv2 ;

CREATE TABLE bronze.erp_px_cat_glv2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50)
    );

