-- ================================================================================
-- Procedure: Load Silver layer from Bronze to Silver 
-- ================================================================================
-- Purpose:
-- This procedure loads the Silver Layer by transforming and cleansing data
-- from the Bronze Layer into a standardized and more reliable format.
-- It removes duplicate customer records, handles missing and invalid values,
-- standardizes names, genders, marital statuses, countries, and product lines,
-- validates dates and sales-related values, and derives useful fields such as
-- category IDs and product end dates. The cleaned data is then loaded into
-- the Silver tables, making it ready for integration, analysis, and reporting.

EXEC Silver.load_silver

CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN
    -- Track loading and total Silver Layer duration
    DECLARE @start_time datetime,
            @end_time datetime,
            @start_silver datetime,
            @end_silver datetime;

    BEGIN TRY

        SET @start_silver = GETDATE();

        PRINT('=====================================================================================')
        PRINT('LOADING SILVER LAYER')
        PRINT('=====================================================================================')

        PRINT('=====================================================================================')
        PRINT('LOADING CRM TABLE')
        PRINT('=====================================================================================')


        -- ============================================
        -- CRM Customer Information
        -- ============================================
        SET @start_time = GETDATE();

        PRINT('Truncating Table: silver.crm_cust_info')
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT('Inserting Data INTO: silver.crm_cust_info');

        INSERT INTO silver.crm_cust_info (
              [cst_id],
              [cst_key],
              [cst_firstname],
              [cst_lastname],
              [cst_marital_status],
              [cst_gndr],
              [cst_create_date]
        )
        SELECT 
               cst_id,
               cst_key,
               TRIM(cst_firstname) AS cst_firstname,
               TRIM(cst_lastname) AS cst_lastname,

               -- Standardize marital status
               CASE 
                   WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' 
                   WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married' 
                   ELSE 'n/a'
               END AS cst_marital_status,

               -- Standardize gender values
               CASE 
                   WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' 
                   WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male' 
                   ELSE 'n/a'
               END AS cst_gndr,

               cst_create_date
        FROM (
            -- Keep the latest record for each customer
            SELECT *,
                   ROW_NUMBER() OVER (
                       PARTITION BY cst_id 
                       ORDER BY cst_create_date DESC
                   ) AS flag_lest
            FROM Bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag_lest = 1;

        SET @end_time = GETDATE();

        PRINT('DURATION LOADING ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
              + ' Seconds');


        -- ============================================
        -- CRM Product Information
        -- ============================================
        SET @start_time = GETDATE();

        PRINT('Truncating Table: silver.crm_prd_info')
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT('Inserting Data INTO: silver.crm_prd_info');

        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT 
            prd_id,

            -- Extract category from product key
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,

            -- Extract product key
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,

            prd_nm,

            -- Replace missing costs with zero
            ISNULL(prd_cost, 0) AS prd_cost,

            -- Standardize product line names
            CASE UPPER(TRIM(prd_line))
                 WHEN 'M' THEN 'Mountain'
                 WHEN 'R' THEN 'Road'
                 WHEN 'S' THEN 'other Sales'
                 WHEN 'T' THEN 'Touring'
                 ELSE 'n/a'
            END AS prd_line,

            prd_start_dt,

            -- End date is one day before the next version starts
            CAST(
                DATEADD(
                    DAY,
                    -1,
                    LEAD(prd_start_dt) OVER (
                        PARTITION BY prd_key 
                        ORDER BY prd_start_dt
                    )
                ) AS DATE
            ) AS prd_end_dt

        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();

        PRINT('DURATION LOADING ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
              + ' Seconds');


        -- ============================================
        -- CRM Sales Details
        -- ============================================
        SET @start_time = GETDATE();

        PRINT('Truncating Table: silver.crm_sales_details')
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT('Inserting Data INTO: silver.crm_sales_details');

        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            -- Convert invalid dates to NULL
            CASE 
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS NVARCHAR) AS DATE)
            END AS sls_order_dt,

            CASE 
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS NVARCHAR) AS DATE)
            END AS sls_ship_dt,

            CASE 
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS NVARCHAR) AS DATE)
            END AS sls_due_dt,

            -- Recalculate incorrect sales values
            CASE 
                WHEN sls_sales <= 0 
                     OR sls_sales IS NULL 
                     OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,

            sls_quantity,

            -- Recalculate missing or invalid prices
            CASE 
                WHEN sls_price <= 0 OR sls_price IS NULL 
                THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price

        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();

        PRINT('DURATION LOADING ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
              + ' Seconds');


        -- ============================================
        -- ERP Customer Information
        -- ============================================
        SET @start_time = GETDATE();

        PRINT('Truncating Table: silver.erp_cust_az12')
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT('Inserting Data INTO: silver.erp_cust_az12');

        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT 

            -- Remove NAS prefix from customer IDs
            CASE 
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid 
            END AS cid,

            -- Remove future birth dates
            CASE 
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END AS bdate,

            -- Standardize gender values
            CASE 
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                ELSE 'n/a'
            END AS gen

        FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();

        PRINT('DURATION LOADING ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
              + ' Seconds');


        -- ============================================
        -- ERP Customer Location
        -- ============================================
        SET @start_time = GETDATE();

        PRINT('Truncating Table: silver.erp_loc_a101')
        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT('Inserting Data INTO: silver.erp_loc_a101');

        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT 

            -- Remove separators from customer IDs
            REPLACE(cid, '-', '') AS cid,

            -- Standardize country names
            CASE 
                WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
                ELSE TRIM(cntry)
            END AS cntry

        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();

        PRINT('DURATION LOADING ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
              + ' Seconds');


        -- ============================================
        -- ERP Product Category Information
        -- ============================================
        SET @start_time = GETDATE();

        PRINT('Truncating Table: silver.erp_px_cat_g1v2')
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT('Inserting Data INTO: silver.erp_px_cat_g1v2');

        INSERT INTO silver.erp_px_cat_g1v2 (
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
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();

        PRINT('DURATION LOADING ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
              + ' Seconds');


        -- ============================================
        -- Silver Layer Summary
        -- ============================================
        SET @end_silver = GETDATE();

        PRINT('=====================================================================================')
        PRINT('BUILDING SILVER LAYER DURATION ' 
              + CAST(DATEDIFF(SECOND, @start_silver, @end_silver) AS NVARCHAR) 
              + ' SECONDS')
        PRINT('=====================================================================================')

    END TRY

    BEGIN CATCH

        -- Report errors without stopping the procedure silently
        PRINT('=======================================================');
        PRINT('ERROR OCCURED DURING THE LOADING SILVER LAYER');
        PRINT('ERROR MESSAGE: ' + ERROR_MESSAGE());
        PRINT('ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR));
        PRINT('ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR));
        PRINT('=======================================================');

    END CATCH
END
```
