-- Intra-State vs. Inter-State Delivery Performance

SELECT 
    CASE 
        WHEN c.customer_state = s.seller_state THEN 'Same State (Intra-State)'
        ELSE 'Different State (Inter-State)'
    END AS shipping_type,
    COUNT(DISTINCT o.order_key) AS order_count,
    ROUND(AVG(oi.freight_value)::NUMERIC, 2) AS avg_freight_value,
    ROUND(AVG(EXTRACT(DAY FROM (o.delivered_customer_at - o.purchase_at)))::NUMERIC, 1) AS avg_actual_delivery_days,
    ROUND(AVG(EXTRACT(DAY FROM (o.delivered_customer_at - o.estimated_delivery_at)))::NUMERIC, 1) AS avg_days_variance
FROM core.fact_order_items oi
JOIN core.fact_orders o ON oi.order_key = o.order_key
JOIN core.dim_customers c ON o.customer_key = c.customer_key
JOIN core.dim_sellers s ON oi.seller_key = s.seller_key
WHERE o.order_status = 'delivered'
  AND o.delivered_customer_at IS NOT NULL
GROUP BY 1;