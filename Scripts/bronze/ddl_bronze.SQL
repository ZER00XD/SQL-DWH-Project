/*=================================
        Bronze Layer Loading
 ==================================

Purpose:
- Create the Bronze layer tables for CRM and ERP source data.
- Truncate existing tables before each load.
- Load raw data from CSV files using BULK INSERT.
- Track loading duration for each table and the entire Bronze layer.
- Handle and report errors during the loading process.
*/

 -- Create CRM Tables
if object_id('bronze.crm_cust_info' ,'U') is not null
	drop table bronze.crm_cust_info;

GO

create table bronze.crm_cust_info (
	cst_id int ,
	cst_key nvarchar(50) ,
	cst_firstname nvarchar(50) ,
	cst_lastname nvarchar(50) ,
	cst_marital_status nvarchar(50) ,
	cst_gndr nvarchar(50) ,
	cst_create_date date 
);

GO

if object_id('bronze.crm_prd_info' ,'U') is not null
	drop table bronze.crm_prd_info;

GO

create table bronze.crm_prd_info (
	prd_id int ,
	prd_key nvarchar(50) ,
	prd_nm nvarchar(50) ,
	prd_cost int ,
	prd_line nvarchar(50) ,
	prd_start_dt date ,
	prd_end_dt date
);

GO

if object_id('bronze.crm_sales_details' ,'U') is not null
	drop table bronze.crm_sales_details;

GO

create table bronze.crm_sales_details (
	sls_ord_num nvarchar(50) ,
	sls_prd_key nvarchar(50) ,
	sls_cust_id int ,
	sls_order_dt int ,
	sls_ship_dt int ,
	sls_due_dt int ,
	sls_sales int ,
	sls_quantity int ,
	sls_price int

);

GO

if object_id('bronze.erp_cust_az12' ,'U') is not null
	drop table bronze.erp_cust_az12;

GO

create table bronze.erp_cust_az12 (
	cid nvarchar(50) ,
	bdate date ,
	gen nvarchar(50)
);

GO

if object_id('bronze.erp_loc_a101' ,'U') is not null
	drop table bronze.erp_loc_a101;

GO

create table bronze.erp_loc_a101 (
	cid nvarchar(50) , 
	cntry nvarchar(50)
);

GO

if object_id('bronze.erp_px_cat_g1v2' ,'U') is not null
	drop table bronze.erp_px_cat_g1v2;

GO

create table bronze.erp_px_cat_g1v2 (
	id nvarchar(50) ,
	cat nvarchar(50) ,
	subcat nvarchar(50) ,
	maintenance nvarchar(50)
);

GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME , @end_time DATETIME ,@start_bronze DATETIME , @end_bronze DATETIME;
	BEGIN TRY
		SET @start_bronze = getdate();
		-- Insert rows from CSV files into Tables 

			-- Create ERB Tables 
		Print '=================================';
		Print 'Loading Bronze Layer';
		Print '=================================';

		print '---------------------------------';
		print 'Loading CRM Table';
		print '---------------------------------';

		SET @start_time = getdate();
		Print '>> Truncating Table : bronze.crm_cust_info'
		truncate table bronze.crm_cust_info;

		Print '>> Inserting Data into : bronze.crm_cust_info'
		Bulk insert bronze.crm_cust_info
		from 'D:\SQL material\Project_1_with_Baraa\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
			firstrow = 2 ,
			fieldterminator = ',' ,
			tablock
		);
		SET @end_time = getdate();
		PRINT '>> Load duration : '+CAST(datediff(second , @start_time , @end_time) AS NVARCHAR)+ ' seconds';
		PRINT '---------------';

		SET @start_time = getdate();
		Print '>> Truncating Table : bronze.crm_prd_info'
		truncate table bronze.crm_prd_info;

		Print '>> Inserting Data into : bronze.crm_prd_info'
		Bulk insert bronze.crm_prd_info
		from 'D:\SQL material\Project_1_with_Baraa\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
			firstrow = 2 ,
			fieldterminator = ',' ,
			tablock
		);
		SET @end_time = getdate();
		PRINT '>> Load duration : '+CAST(datediff(second , @start_time , @end_time) AS NVARCHAR)+ ' seconds';
		PRINT '---------------';

		SET @start_time = getdate();
		Print '>> Truncating Table : bronze.crm_sales_details'
		truncate table bronze.crm_sales_details;

		Print '>> Inserting Data into : bronze.crm_sales_details'
		bulk insert bronze.crm_sales_details
		from 'D:\SQL material\Project_1_with_Baraa\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
			firstrow = 2 ,
			fieldterminator = ',' ,
			tablock
		);
		SET @end_time = getdate();
		PRINT '>> Load duration : '+CAST(datediff(second , @start_time , @end_time) AS NVARCHAR)+ ' seconds';
		PRINT '---------------';

		Print '---------------------------';
		Print 'Loading ERB Table';
		Print '---------------------------';

		SET @start_time = getdate();
		Print '>> Truncating Table : bronze.erp_cust_az12'
		truncate table bronze.erp_cust_az12;

		Print '>> Inserting Data into : bronze.erp_cust_az12'
		bulk insert bronze.erp_cust_az12
		from 'D:\SQL material\Project_1_with_Baraa\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		with (
			firstrow = 2 ,
			fieldterminator = ',' ,
			tablock
		);
		SET @end_time = getdate();
		PRINT '>> Load duration : '+CAST(datediff(second , @start_time , @end_time) AS NVARCHAR)+ ' seconds';
		PRINT '---------------';

		SET @start_time = getdate();
		Print '>> Truncating Table : bronze.erp_loc_a101'
		truncate table bronze.erp_loc_a101;

		Print '>> Inserting Data into : bronze.erp_loc_a101'
		bulk insert bronze.erp_loc_a101
		from 'D:\SQL material\Project_1_with_Baraa\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		with (
			firstrow = 2 ,
			fieldterminator = ',' ,
			tablock
		);
		SET @end_time = getdate();
		PRINT '>> Load duration : '+CAST(datediff(second , @start_time , @end_time) AS NVARCHAR)+ ' seconds';
		PRINT '---------------';

		SET @start_time = getdate();
		Print '>> Truncating Table : bronze.erp_px_cat_g1v2'
		truncate table bronze.erp_px_cat_g1v2;

		Print '>> Inserting Data into : bronze.erp_px_cat_g1v2'
		bulk insert bronze.erp_px_cat_g1v2
		from 'D:\SQL material\Project_1_with_Baraa\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		with (
			firstrow = 2 ,
			fieldterminator = ',' ,
			tablock
		);
		SET @end_time = getdate();
		PRINT '>> Load duration : '+CAST(datediff(second , @start_time , @end_time) AS NVARCHAR)+ ' seconds';
		PRINT '---------------';

		SET @end_bronze = getdate();
		PRINT '=================================================================================================================';
		PRINT '>> Building Bronze Layer duration : '+CAST(datediff(second , @start_bronze , @end_bronze) AS NVARCHAR)+ ' seconds';
		PRINT '=================================================================================================================';

	END TRY
	BEGIN CATCH
		PRINT '================================================';
		PRINT 'Error occured during the loading bronze layer';
		PRINT 'Error Message'+ ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Errore Message' +ERROR_STATE();
		PRINT '================================================'; 

	END CATCH
	
END










