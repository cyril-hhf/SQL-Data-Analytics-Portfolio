-- Top 3 Best-Selling Product Categories per State
-- used DENSE_RANK() PARTITION BY c.customer_state to calculate top 3 categories by states
-- CTE for heavy SUM(price) aggregation + complex joins to enhance performance

WITH category_state_revenue AS (
    SELECT 
        c.customer_state,
        p.product_category_name_en AS product_category,
        SUM(oi.price) AS total_sales,
        DENSE_RANK() OVER (
            PARTITION BY c.customer_state 
            ORDER BY SUM(oi.price) DESC
        ) AS category_rank
    FROM core.fact_order_items oi
    JOIN core.fact_orders o ON oi.order_key = o.order_key
    JOIN core.dim_customers c ON o.customer_key = c.customer_key
    JOIN core.dim_products p ON oi.product_key = p.product_key
    WHERE o.order_status = 'delivered'
      AND p.product_category_name_en IS NOT NULL
    GROUP BY 1, 2
)
SELECT 
    customer_state,
    product_category,
    ROUND(total_sales::NUMERIC, 2) AS total_sales,
    category_rank
FROM category_state_revenue
WHERE category_rank <= 3
ORDER BY customer_state ASC, category_rank ASC;