/*
-------------------------------------------------------------------------------------------------------------
Stored Procedure: Load Bronze Layer(Source -> Bronze)
-------------------------------------------------------------------------------------------------------------
Script Purpose:
this stored procedure loads data into the 'bronze' schema from external CSV files.
It performs the following actions:
   -Truncate the bronze tables before loading data.
   -Uses the 'BULK INSERT' command to load data from CSV files to bronze tables.

Parameters:
    None.
    This stored the procedure does not accept any parameters or return any values.

Usage Example:
   EXEC bronze.load_bronze;

 ------------------------------------------------------------------------------------------------------------  

*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
  
  BEGIN TRY
      PRINT '--------------------------------------------------------------------------------------------------------------'
      PRINT 'LOADING BRONZE LAYER'
      PRINT '--------------------------------------------------------------------------------------------------------------'

      PRINT '--------------------------------------------------------------------------------------------------------------'
      PRINT 'LOADING CRM TABLES'
      PRINT '--------------------------------------------------------------------------------------------------------------'
---------------------CUSTOMER TABLE-------------------------------------------------------------------

PRINT '>> TRUNCATING TABLE: bronze.crm_cust_info'
TRUNCATE TABLE bronze.crm_cust_info;

PRINT '>> INSERTING TABLE: bronze.crm_cust_info'
BULK INSERT bronze.crm_cust_info
FROM 'C:\Users\Seema Patidar\OneDrive\Desktop\finalproj\datasets\source_crm\cust_info.csv'
WITH (
   FIRSTROW = 2,
   FIELDTERMINATOR = ',',
   TABLOCK
);



------------------------------PRODUCT TABLE---------------------------------------------------------------

PRINT '>> TRUNCATING TABLE: bronze.crm_prod_info'
TRUNCATE TABLE bronze.crm_prod_info;

PRINT '>> INSERTING TABLE: bronze.crm_prod_info'
BULK INSERT bronze.crm_prod_info
FROM 'C:\Users\Seema Patidar\OneDrive\Desktop\finalproj\datasets\source_crm\prod_info.csv'
WITH (
   FIRSTROW = 2,
   FIELDTERMINATOR = ',',
   TABLOCK
);

-------------------------------SALES TABLE----------------------------------------------------------------

PRINT '>> TRUNCATING TABLE: bronze.crm_sales_detail'
TRUNCATE TABLE bronze.crm_sales_details;

PRINT '>> INSERING TABLE: bronze.crm_cust_info'
BULK INSERT bronze.crm_sales_details
FROM 'C:\Users\Seema Patidar\OneDrive\Desktop\finalproj\datasets\source_crm\sales_details.csv'
WITH (
   FIRSTROW = 2,
   FIELDTERMINATOR = ',',
   TABLOCK
);


-----------------------------------------------------------------------------------------------------------

 PRINT '--------------------------------------------------------------------------------------------------------------'
 PRINT 'LOADING ERP TABLES'
 PRINT '--------------------------------------------------------------------------------------------------------------'

-----------------------------------------CUSTOMER-----------------------------------------------------------

PRINT '>> TRUNCATING TABLE: bronze.erp_cust_az12'
TRUNCATE TABLE bronze.erp_cust_az12;

PRINT '>> INSERTING TABLE: bronze.erp_cust_az12'
BULK INSERT bronze.erp_cust_az12
FROM 'C:\Users\Seema Patidar\OneDrive\Desktop\finalproj\datasets\source_erp\CUST_AZ12.csv'
WITH (
   FIRSTROW = 2,
   FIELDTERMINATOR = ',',
   TABLOCK
);

--------------------------------------LOCATION TABLE--------------------------------------------------------
PRINT '>> TRUNCATING TABLE: bronze.erp_loc_a101'
TRUNCATE TABLE bronze.erp_loc_a101;

PRINT '>> INSERTING TABLE: bronze.erp_loc_a101'
BULK INSERT bronze.erp_loc_a101
FROM 'C:\Users\Seema Patidar\OneDrive\Desktop\finalproj\datasets\source_erp\LOC_A101.csv'
WITH (
   FIRSTROW = 2,
   FIELDTERMINATOR = ',',
   TABLOCK
);

-------------------------------------PRODUCT CATEGORY--------------------------------------------------------

PRINT '>> TRUNCATING TABLE: erp_px_cat_glv2'
TRUNCATE TABLE bronze.erp_px_cat_glv2;

PRINT '>> INSERTING TABLE: erp_px_cat_glv2'
BULK INSERT bronze.erp_px_cat_glv2
FROM 'C:\Users\Seema Patidar\OneDrive\Desktop\finalproj\datasets\source_erp\PX_CAT_GLV2.csv'
WITH (
   FIRSTROW = 2,
   FIELDTERMINATOR = ',',
   TABLOCK
);

END TRY

BEGIN CATCH
    PRINT '-----------------------------------------------------------'
    PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
    PRINT 'ERROR MESSAGE' + ERROR_MESSAGE()
    PRINT 'ERROR MESSAGE' + CAST (ERROR_NUMBER() AS VARCHAR)
    PRINT 'ERROR MESSAGE' + CAST (ERROR_STATE() AS VARCHAR)
    PRINT '____________________________________________________________'
END CATCH
END




----------------------------------------------------------------------------------------------------
SELECT * FROM bronze.crm_cust_info
SELECT COUNT(*) FROM bronze.crm_cust_info

SELECT * FROM bronze.crm_prod_info
SELECT COUNT(*) FROM bronze.crm_prod_info

SELECT * FROM bronze.crm_sales_details
SELECT COUNT(*) FROM bronze.crm_sales_details

SELECT * FROM bronze.erp_cust_az12
SELECT COUNT(*) FROM bronze.erp_cust_az12

SELECT * FROM bronze.erp_loc_a101
SELECT COUNT(*) FROM bronze.erp_loc_a101

SELECT * FROM bronze.erp_px_cat_glv2
SELECT COUNT(*) FROM bronze.erp_px_cat_glv2



EXECUTE bronze.load_bronze
