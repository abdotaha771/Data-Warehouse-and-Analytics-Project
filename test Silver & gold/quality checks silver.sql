-- =============================================================================
-- Checking 'silver.crm_cust_info'
-- =============================================================================

-- Check NULLs or duplicates in Primary Key
-- Expected: No results
SELECT 
    cst_id,
    COUNT(*) AS count_num
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check unwanted spaces for string columns (cst_firstname, cst_lastname, cst_marital_status, cst_gndr)
-- Expected: No results
SELECT 
    cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Data standardization & consistency check for (cst_marital_status, cst_gndr)
SELECT DISTINCT 
    cst_marital_status
FROM silver.crm_cust_info;


-- =============================================================================
-- Checking 'silver.crm_prd_info'
-- =============================================================================

-- Check NULLs or duplicates in Primary Key
-- Expected: No results
SELECT 
    prd_id,
    COUNT(*) AS count_num
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check NULLs or unwanted spaces in prd_nm
-- Expected: No results
SELECT 
    prd_id,
    prd_nm
FROM silver.crm_prd_info 
WHERE prd_nm != TRIM(prd_nm) OR prd_nm IS NULL;

-- Check for NULLs or negative numbers in prd_cost
-- Expected: No results
SELECT 
    prd_id,
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data standardization & consistency check for prd_line
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Check invalid date relationships (Start Date > End Date)
-- Expected: No results
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;


-- =============================================================================
-- Checking 'silver.crm_sales_details'
-- =============================================================================

-- Check for invalid dates
-- Expected: No results
SELECT 
    sls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt IS NULL 
   OR sls_due_dt > '2050-01-01' 
   OR sls_due_dt < '1900-01-01';

-- Check for invalid date order (Order Date > Shipping / Due Dates)
-- Expected: No results
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Check data consistency: Sales = Quantity * Price
-- Expected: No results
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY 
    sls_sales, 
    sls_quantity, 
    sls_price;


-- =============================================================================
-- Checking 'silver.erp_cust_az12'
-- =============================================================================

-- Data standardization & consistency check for gender
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;


-- =============================================================================
-- Checking 'silver.erp_loc_a101'
-- =============================================================================

-- Data standardization & consistency check for country
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;


-- =============================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- =============================================================================

-- Check NULLs or duplicates in Primary Key
-- Expected: No results
SELECT 
    id,
    COUNT(*) AS count_num
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1 OR id IS NULL;

-- Check for unwanted spaces
-- Expected: No results
SELECT 
    * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Data standardization & consistency check for maintenance
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;
