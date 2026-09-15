/*===================================================
 GOLD LAYER
===================================================*/

/*
Purpose:
This script builds the Gold Layer of the data warehouse by creating
business-ready views for customers, products, and sales.

The Gold Layer follows a Star Schema design, where dimension views
provide descriptive information about customers and products, while
the fact view contains sales transactions.

The views combine and enrich data from the Silver Layer to make it
easier for business users and analysts to perform reporting,
analytics, and generate insights without dealing with raw or
transformed source data directly.
*/


/*===================================================
 Customer Dimension
 - Provides descriptive information about customers
 - Combines CRM customer data with ERP demographic and location data
 - Uses CRM as the master source for customer gender
===================================================*/

IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
	DROP VIEW gold.dim_customers ;

GO

CREATE VIEW gold.dim_customers AS
	SELECT 
		ROW_NUMBER() OVER(order by cst_id) AS customer_key ,
		ci.cst_id AS customer_id ,
		ci.cst_key AS customer_number,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		la.cntry AS country,
		ci.cst_marital_status AS marital_status,
		CASE 
			WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr 
			-- CRM is the master source for gender information
			ELSE COALESCE(ca.gen , 'n/a')
		END AS gender ,
		ca.bdate AS birthdate,
		ci.cst_create_date AS create_date
	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca
		ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
		ON ci.cst_key = la.cid;

GO


/*===================================================
 Product Dimension
 - Provides current product information
 - Enriches products with category details
 - Excludes historical product versions
===================================================*/

IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
	DROP VIEW gold.dim_products ;

GO

CREATE VIEW gold.dim_products AS
	SELECT
		ROW_NUMBER() OVER(
			ORDER BY pi.prd_start_dt , pi.prd_key
		) AS product_key ,
		pi.prd_id AS product_id ,
		pi.prd_key AS product_number,
		pi.prd_nm AS product_name,
		pi.cat_id AS category_id,
		cg.cat AS category,
		cg.subcat AS subcategory,
		cg.maintenance ,
		pi.prd_cost AS cost,
		pi.prd_line AS product_line,
		pi.prd_start_dt AS start_date 
	FROM silver.crm_prd_info pi
	LEFT JOIN silver.erp_px_cat_g1v2 cg
		ON pi.cat_id = cg.id
	WHERE prd_end_dt IS NULL; -- Keep only the current product version

GO


/*===================================================
 Sales Fact
 - Provides sales transaction details
 - Links sales transactions to customer and product dimensions
 - Serves as the main table for sales analysis
===================================================*/

IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
	DROP VIEW gold.fact_sales ;

GO 

CREATE VIEW gold.fact_sales AS
	SELECT 
		sd.sls_ord_num AS order_number,
		dp.product_key ,
		dc.customer_key ,
		sd.sls_order_dt AS order_date ,
		sd.sls_ship_dt AS shipping_date,
		sd.sls_due_dt AS due_date,
		sd.sls_sales AS sales_amount,
		sd.sls_quantity AS quantity,
		sd.sls_price AS price
	FROM silver.crm_sales_details sd
	LEFT JOIN gold.dim_products dp
		ON sd.sls_prd_key = dp.product_number
	LEFT JOIN gold.dim_customers dc 
		ON sd.sls_cust_id = dc.customer_id;
```
