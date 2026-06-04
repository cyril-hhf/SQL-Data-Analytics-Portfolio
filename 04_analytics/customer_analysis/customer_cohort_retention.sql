-- Customer Cohort Retention Analysis

WITH customer_birthdays AS (
    -- Step 1: Find the absolute first purchase month for each customer
    SELECT 
        c.customer_unique_id,
        DATE_TRUNC('month', MIN(o.purchase_at)) AS cohort_month
    FROM core.fact_orders o
    JOIN core.dim_customers c ON o.customer_key = c.customer_key
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
cohort_sizes AS (
    -- Step 2: Calculate the denominator (total unique people born in that month)
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS total_cohort_size
    FROM customer_birthdays
    GROUP BY 1
),
retention_transactions AS (
    -- Step 3: Map all subsequent orders back to the customer's cohort birth month
    SELECT 
        c.customer_unique_id,
        b.cohort_month,
        -- Calculate how many months elapsed between birth month and this purchase month
        EXTRACT(YEAR FROM DATE_TRUNC('month', o.purchase_at)) * 12 + EXTRACT(MONTH FROM DATE_TRUNC('month', o.purchase_at)) - 
        (EXTRACT(YEAR FROM b.cohort_month) * 12 + EXTRACT(MONTH FROM b.cohort_month)) AS cohort_month_index
    FROM core.fact_orders o
    JOIN core.dim_customers c ON o.customer_key = c.customer_key
    JOIN customer_birthdays b ON c.customer_unique_id = b.customer_unique_id
    WHERE o.order_status = 'delivered'
)
-- Step 4: Aggregate to find returning volumes and mathematically sound percentages
SELECT 
    TO_CHAR(cs.cohort_month, 'YYYY-MM') AS cohort_start_month,
    cs.total_cohort_size,
    rt.cohort_month_index AS months_elapsed,
    COUNT(DISTINCT rt.customer_unique_id) AS active_returning_customers,
    
    -- Retention Formula using safe floating-point math
    ROUND(
        (COUNT(DISTINCT rt.customer_unique_id) * 100.0 / cs.total_cohort_size), 
        2
    ) AS retention_percentage
FROM cohort_sizes cs
LEFT JOIN retention_transactions rt ON cs.cohort_month = rt.cohort_month
WHERE rt.cohort_month_index >= 0
GROUP BY cs.cohort_month, cs.total_cohort_size, rt.cohort_month_index
ORDER BY cs.cohort_month ASC, rt.cohort_month_index ASC;