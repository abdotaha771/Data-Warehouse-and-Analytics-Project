-- =============================================================================
-- Change Over Time Analysis
-- =============================================================================

-- Analyze sales performance over time (Quick Date Functions)
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales_amount,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
    YEAR(order_date), 
    MONTH(order_date)
ORDER BY 
    YEAR(order_date), 
    MONTH(order_date);

-- Analyze sales performance using DATETRUNC()
SELECT
    DATETRUNC(MONTH, order_date) AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date);


-- =============================================================================
-- Cumulative Analysis
-- =============================================================================

-- Calculate the total sales per year and the running total / moving average over time
SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
    AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM (
    SELECT 
        DATETRUNC(YEAR, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(YEAR, order_date)
) AS t;


-- =============================================================================
-- Performance Analysis (Year-over-Year, Month-over-Month)
-- =============================================================================

/* 
Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales 
*/

WITH yearly_performance AS (
    SELECT 
        DATETRUNC(YEAR, f.order_date) AS order_date,
        d.product_name AS product_name,
        SUM(f.sales_amount) AS sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products d
        ON f.product_key = d.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        DATETRUNC(YEAR, f.order_date),
        d.product_name
)
SELECT
    order_date,
    product_name,
    sales,
    AVG(sales) OVER (PARTITION BY product_name) AS avg_sales,
    sales - AVG(sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE 
        WHEN sales - AVG(sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN sales - AVG(sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    LAG(sales) OVER (PARTITION BY product_name ORDER BY order_date) AS sales_previous_year,
    sales - LAG(sales) OVER (PARTITION BY product_name ORDER BY order_date) AS diff_last_year,
    -- Year-over-Year Analysis
    CASE 
        WHEN sales - LAG(sales) OVER (PARTITION BY product_name ORDER BY order_date) > 0 THEN 'Increase'
        WHEN sales - LAG(sales) OVER (PARTITION BY product_name ORDER BY order_date) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
FROM yearly_performance
ORDER BY 
    product_name, 
    order_date;


-- =============================================================================
-- Data Segmentation Analysis
-- =============================================================================

/* 
Segment products into cost ranges and count how many products fall into each segment 
*/
WITH product_cost_segment AS (
    SELECT 
        product_name,
        CASE 
            WHEN cost < 500 THEN 'Below 500'
            WHEN cost > 1000 THEN 'Above 1000'
            ELSE '500-1000'
        END AS cost_category
    FROM gold.dim_products
)
SELECT
    cost_category,
    COUNT(product_name) AS category_count
FROM product_cost_segment
GROUP BY cost_category
ORDER BY category_count DESC;

/* 
Group customers into three segments based on their spending behavior:
  - VIP: Customers with at least 12 months of history and spending more than €5,000.
  - Regular: Customers with at least 12 months of history but spending €5,000 or less.
  - New: Customers with a lifespan less than 12 months.
And find the total number of customers in each group.
*/
WITH customer_lifespan AS (
    SELECT
        d.customer_key,
        SUM(f.sales_amount) AS total_spending,
        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan_months
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers d
        ON d.customer_key = f.customer_key
    GROUP BY 
        d.customer_key
),
customer_segments AS (
    SELECT
        customer_key,
        CASE
            WHEN lifespan_months >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan_months >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_group
    FROM customer_lifespan
)
SELECT 
    customer_group,
    COUNT(customer_key) AS total_customers
FROM customer_segments
GROUP BY customer_group
ORDER BY total_customers DESC;

-- Which categories contribute the most to overall sales? (Part-to-Whole Analysis)
SELECT
    category,
    sales,
    SUM(sales) OVER () AS total_sales,
    ROUND((CAST(sales AS FLOAT) / CAST(SUM(sales) OVER () AS FLOAT)) * 100, 2) AS categories_contribute
FROM (
    SELECT
        d.category,
        SUM(f.sales_amount) AS sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products d
        ON d.product_key = f.product_key
    GROUP BY d.category
) AS t
ORDER BY sales DESC;