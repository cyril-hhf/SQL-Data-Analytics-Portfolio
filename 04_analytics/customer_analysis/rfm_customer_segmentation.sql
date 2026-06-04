-- RFM Customer Segmentation
-- Grouping human identities into strategic marketing segments

WITH customer_raw_rfm AS (
    -- Step 1: Calculate raw Recency days, Frequency counts, and Monetary value
    SELECT 
        c.customer_unique_id,
        -- Recency: Days between the maximum global order date in dataset and the customer's last order
        EXTRACT(DAY FROM (SELECT MAX(purchase_at) FROM core.fact_orders) - MAX(o.purchase_at)) AS raw_recency_days,
        -- Frequency: Number of unique orders placed
        COUNT(DISTINCT o.order_key) AS raw_frequency,
        -- Monetary: Sum of product purchase values
        SUM(oi.price) AS raw_monetary
    FROM core.fact_orders o
    JOIN core.fact_order_items oi ON o.order_key = oi.order_key
    JOIN core.dim_customers c ON o.customer_key = c.customer_key
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scores AS (
    -- Step 2: Use NTILE to score each metric from 1 to 5
    SELECT 
        customer_unique_id,
        raw_recency_days,
        raw_frequency,
        raw_monetary,
        -- Recency: Closest date gets 5, oldest gets 1
        NTILE(5) OVER (ORDER BY raw_recency_days DESC) AS r_score,
        -- Frequency: Highest count gets 5 (Note: Due to Olist low retention, 1-timers will dominate scores 1-4)
        NTILE(5) OVER (ORDER BY raw_frequency ASC) AS f_score,
        -- Monetary: Highest spender gets 5
        NTILE(5) OVER (ORDER BY raw_monetary ASC) AS m_score
    FROM customer_raw_rfm
),
rfm_concatenated AS (
    -- Step 3: Combine scores into a text code string for easy classification logic
    SELECT 
        *,
        (r_score::TEXT || f_score::TEXT || m_score::TEXT) AS rfm_cell_code
    FROM rfm_scores
)
-- Step 4: Map mathematical cells to practical human business segments
SELECT 
    customer_unique_id,
    raw_recency_days,
    raw_frequency,
    raw_monetary,
    rfm_cell_code,
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score = 1 THEN 'Promising Newbies'
        WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 4 THEN 'Can''t Lose Them (At Risk)'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost / Hibernating'
        ELSE 'About to Sleep / General'
    END AS marketing_segment
FROM rfm_concatenated
ORDER BY raw_monetary DESC;