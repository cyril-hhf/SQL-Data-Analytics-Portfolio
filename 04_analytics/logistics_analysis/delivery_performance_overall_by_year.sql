-- Delivery Speed & Performance Variance

SELECT 
    EXTRACT(YEAR FROM o.purchase_at) AS order_year,
    ROUND(AVG(EXTRACT(DAY FROM (o.delivered_customer_at - o.purchase_at)))::NUMERIC, 1) AS avg_actual_delivery_days,
    -- Variance: Negative numbers show delivery earlier than estimated (actual days - estimated days)
    ROUND(AVG(EXTRACT(DAY FROM (o.delivered_customer_at - o.estimated_delivery_at)))::NUMERIC, 1) AS avg_days_variance_from_estimate
FROM core.fact_orders o
WHERE o.order_status = 'delivered'
  AND o.delivered_customer_at IS NOT NULL
GROUP BY 1
ORDER BY 1;