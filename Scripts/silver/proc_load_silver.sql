/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		-- Loading silver.crm_cust_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting Data Into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cust_id, 
			cust_key, 
			cust_firstname, 
			cust_lastname, 
			cust_marital_status, 
			cust_gndr,
			cust_create_date
		)
		SELECT
			cust_id,
			cust_key,
			TRIM(cust_firstname) AS cust_firstname,
			TRIM(cust_lastname) AS cust_lastname,
			CASE 
				WHEN UPPER(TRIM(cust_marital_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cust_marital_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
			END AS cust_marital_status, -- Normalize marital status values to readable format
			CASE 
				WHEN UPPER(TRIM(cust_gndr)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cust_gndr)) = 'M' THEN 'Male'
				ELSE 'n/a'
			END AS cust_gndr, -- Normalize gender values to readable format
			cust_create_date
		FROM (
			SELECT
				*,
				ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BY cust_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cust_id IS NOT NULL
		) t
		WHERE flag_last = 1; -- Select the most recent record per customer
		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.crm_prd_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prod_info;
		PRINT '>> Inserting Data Into: silver.crm_prd_info';
		INSERT INTO silver.crm_prod_info (
			prod_id,
			cat_id,
			prod_key,
			prod_nm,
			prod_cost,
			prod_line,
			prod_start_dt,
			prod_end_dt
		)
		SELECT
			prod_id,
			REPLACE(SUBSTRING(prod_key, 1, 5), '-', '_') AS cat_id, -- Extract category ID
			SUBSTRING(prod_key, 7, LEN(prod_key)) AS prod_key,        -- Extract product key
			prod_nm,
			ISNULL(prod_cost, 0) AS prod_cost,
			CASE 
				WHEN UPPER(TRIM(prod_line)) = 'M' THEN 'Mountain'
				WHEN UPPER(TRIM(prod_line)) = 'R' THEN 'Road'
				WHEN UPPER(TRIM(prod_line)) = 'S' THEN 'Other Sales'
				WHEN UPPER(TRIM(prod_line)) = 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prod_line, -- Map product line codes to descriptive values
			CAST(prod_start_dt AS DATE) AS prod_start_dt,
			CAST(
				LEAD(prod_start_dt) OVER (PARTITION BY prod_key ORDER BY prod_start_dt) - 1 
				AS DATE
			) AS prod_end_dt -- Calculate end date as one day before the next start date
		FROM bronze.crm_prod_info;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading crm_sales_details
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting Data Into: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
			sales_ord_num,
			sales_prod_key,
			sales_cust_id,
			sales_order_dt,
			sales_ship_dt,
			sales_due_dt,
			sales_sls,
			sales_quantity,
			sales_price
		)
		SELECT 
			sales_ord_num,
			sales_prod_key,
			sales_cust_id,
			CASE 
				WHEN sales_order_dt = 0 OR LEN(sales_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sales_order_dt AS VARCHAR) AS DATE)
			END AS sales_order_dt,
			CASE 
				WHEN sales_ship_dt = 0 OR LEN(sales_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sales_ship_dt AS VARCHAR) AS DATE)
			END AS sales_ship_dt,
			CASE 
				WHEN sales_due_dt = 0 OR LEN(sales_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sales_due_dt AS VARCHAR) AS DATE)
			END AS sales_due_dt,
			CASE 
				WHEN sales_sls IS NULL OR sales_sls <= 0 OR sales_sls != sales_quantity * ABS(sales_price) 
					THEN sales_quantity * ABS(sales_price)
				ELSE sales_sls
			END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
			sales_quantity,
			CASE 
				WHEN sales_price IS NULL OR sales_price <= 0 
					THEN sales_sls / NULLIF(sales_quantity, 0)
				ELSE sales_price  -- Derive price if original value is invalid
			END AS sales_price
		FROM bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading erp_cust_az12
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> Inserting Data Into: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) -- Remove 'NAS' prefix if present
				ELSE cid
			END AS cid, 
			CASE
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate, -- Set future birthdates to NULL
			CASE
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'n/a'
			END AS gen -- Normalize gender values and handle unknown cases
		FROM bronze.erp_cust_az12;
	    SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';

        -- Loading erp_loc_a101
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Inserting Data Into: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101 (
			cid,
			cntry
		)
		SELECT
			REPLACE(cid, '-', '') AS cid, 
			CASE
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END AS cntry -- Normalize and Handle missing or blank country codes
		FROM bronze.erp_loc_a101;
	    SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
		
		-- Loading erp_px_cat_g1v2
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_glv2;
		PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_glv2 (
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_glv2;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
