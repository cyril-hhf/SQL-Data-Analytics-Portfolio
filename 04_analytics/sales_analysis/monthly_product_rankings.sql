-- Top 3 Best-Selling Product Categories per Month

WITH monthly_category_revenue AS (
    SELECT 
        DATE_TRUNC('month', o.purchase_at) AS sales_month,
        p.product_category_name_en AS product_category,
        SUM(oi.price) AS category_revenue,
        
        -- Window Function 1: Total company-wide revenue for this specific month
        SUM(SUM(oi.price)) OVER (
            PARTITION BY DATE_TRUNC('month', o.purchase_at)
        ) AS total_monthly_revenue,
        
        -- Window Function 2: Rank categories 1 through N within this specific month
        DENSE_RANK() OVER (
            PARTITION BY DATE_TRUNC('month', o.purchase_at) 
            ORDER BY SUM(oi.price) DESC
        ) AS monthly_category_rank
    FROM core.fact_order_items oi
    JOIN core.fact_orders o ON oi.order_key = o.order_key
    JOIN core.dim_products p ON oi.product_key = p.product_key
    WHERE o.order_status = 'delivered'
      AND p.product_category_name_en IS NOT NULL
    GROUP BY 1, 2
)
SELECT 
    TO_CHAR(sales_month, 'YYYY-MM') AS month_label,
    monthly_category_rank AS product_rank,
    product_category,
    ROUND(category_revenue::NUMERIC, 2) AS category_revenue,
    
    -- Contribution Formula: (Category Revenue / Total Monthly Revenue) * 100
    ROUND(
        (category_revenue / total_monthly_revenue * 100)::NUMERIC,
        2
    ) AS revenue_contribution_percentage
FROM monthly_category_revenue
WHERE monthly_category_rank <= 3
ORDER BY sales_month ASC, monthly_category_rank ASC;