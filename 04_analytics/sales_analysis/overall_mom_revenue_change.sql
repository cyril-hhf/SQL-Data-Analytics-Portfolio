-- MoM revenue growth rate

WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', o.purchase_at) AS sales_month,
        SUM(oi.price) AS current_month_revenue
    FROM core.fact_order_items oi
    JOIN core.fact_orders o ON oi.order_key = o.order_key
    WHERE o.order_status = 'delivered'
    GROUP BY 1
)
SELECT 
    TO_CHAR(sales_month, 'YYYY-MM') AS month_label,
    ROUND(current_month_revenue::NUMERIC, 2) AS revenue,
    ROUND(
        LAG(current_month_revenue, 1) OVER (ORDER BY sales_month)::NUMERIC, 
        2
    ) AS previous_month_revenue,
    ROUND(
        ((current_month_revenue - LAG(current_month_revenue, 1) OVER (ORDER BY sales_month)) 
        / LAG(current_month_revenue, 1) OVER (ORDER BY sales_month) * 100)::NUMERIC,
        2
    ) AS mom_growth_percentage
FROM monthly_revenue
ORDER BY sales_month;