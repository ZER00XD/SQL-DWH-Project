/*===========================================================
  Quality Checks
  ===========================================================
*/
-- Purpose:
-- Validate the quality, consistency, and integrity of the
-- Silver layer data before using it for analysis or reporting.
-- The checks cover duplicates, NULLs, spaces, invalid values,
-- date issues, referential integrity, and data consistency.
-- ===========================================================


-- ===========================================================
--  crm_cust_info
-- ===========================================================

-- Check for NULLs or duplicate customer IDs
-- Expectation: No results
select * from Bronze.crm_cust_info;


select 
    cst_id,
    count(*)
from silver.crm_cust_info 
group by cst_id
having count(*) > 1 OR cst_id is null;


-- Verify the latest record is kept for duplicate customer IDs
select *
from
    (
        select *,
            ROW_NUMBER() over(
                partition by cst_id 
                order by cst_create_date desc
            ) as rn
        from Bronze.crm_cust_info
    ) t
where rn = 1 
  and cst_id = 29466;


-- Check for unwanted spaces in customer names
-- Expectation: No results
select cst_firstname
from silver.crm_cust_info
where cst_firstname != trim(cst_firstname);


select cst_gndr
from silver.crm_cust_info
where cst_gndr != trim(cst_gndr);


-- Check gender values for standardization
select distinct cst_gndr
from silver.crm_cust_info;



-- ===========================================================
--  crm_prd_info
-- ===========================================================

-- Check for NULLs or duplicate product IDs
-- Expectation: No results
select * 
from silver.crm_prd_info;


select 
    prd_id,
    count(*) as flag_lest
from silver.crm_prd_info
group by prd_id 
having count(*) > 1 
    or prd_id is null;


-- Check for unwanted spaces in product names
-- Expectation: No results
select prd_nm 
from silver.crm_prd_info
where prd_nm != trim(prd_nm);


-- Check for NULL or negative product costs
-- Expectation: No results
select prd_cost
from silver.crm_prd_info
where prd_cost < 0 
   or prd_cost is null;


-- Check product categories for consistent values
select distinct prd_line 
from silver.crm_prd_info;


-- Check for invalid date ranges
select * 
from silver.crm_prd_info
where prd_end_dt < prd_start_dt;



-- ===========================================================
--  crm_sales_details
-- ===========================================================

-- Check that every sale references an existing customer
select 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price       
from silver.crm_sales_details
where sls_cust_id not in (
    select cst_id 
    from silver.crm_cust_info
);


-- Check for invalid shipping dates
select 
    NULLIF(sls_ship_dt, 0) as sls_ship_dt
from silver.crm_sales_details
where sls_ship_dt <= 0 
   OR LEN(sls_ship_dt) != 8
   OR sls_ship_dt > 20500101
   OR sls_ship_dt < 19000101;


-- Check that sales dates follow the correct order
select *
from silver.crm_sales_details
where sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;


-- Check consistency between sales, quantity, and price
-- Sales = Quantity * Price
-- Values must not be NULL, negative, or zero
select distinct
    sls_sales,
    sls_quantity, 
    sls_price
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
   OR sls_sales is null 
   OR sls_quantity is null 
   OR sls_price is null
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;



-- ===========================================================
--  erp_cust_az12
-- ===========================================================

-- Check a specific customer record
select 
    cid, 
    bdate, 
    gen
from silver.erp_cust_az12
where cid like '%AW00011014%';


-- Check for unrealistic birth dates
select bdate
from silver.erp_cust_az12
where bdate < '1924-01-01' 
   OR bdate > GETDATE();


-- Check gender values for standardization
select distinct gen
from silver.erp_cust_az12;



-- ===========================================================
--  erp_loc_a101
-- ===========================================================

-- Check that location records reference existing customers
select 
    cid,
    cntry
from silver.erp_loc_a101
where cid not in (
    select cst_key 
    from silver.crm_cust_info
);


-- Check country values for consistency
select distinct
    cntry
from silver.erp_loc_a101
ORDER BY cntry;



-- ===========================================================
--  Reload the layers after validation or data changes
-- ===========================================================

EXEC Bronze.load_bronze;
EXEC Silver.load_silver;
```

### Purpose of the script

This script performs **data quality checks on the Silver layer** to make sure the cleaned data is reliable before it is used in the Gold layer.

It mainly checks:

* **Uniqueness:** Detects duplicate or NULL primary/business keys.
* **Data cleanliness:** Finds unwanted spaces in text fields.
* **Standardization:** Reviews distinct values such as gender, product lines, and countries.
* **Validity:** Detects negative costs, invalid dates, and unrealistic birth dates.
* **Referential integrity:** Ensures sales and ERP records reference existing customers.
* **Date consistency:** Verifies that order, shipping, due, start, and end dates follow the expected order.
* **Business rules:** Confirms that `Sales = Quantity × Price` and that these values are positive.
* **Final verification:** Helps ensure the Silver layer contains consistent and trustworthy data for further transformations and reporting.

The `EXEC` statements at the end reload the Bronze and Silver layers so the validation can be performed against the latest loaded data.
