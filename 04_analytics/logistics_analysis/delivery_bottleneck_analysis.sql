-- Logistics Bottleneck Analysis (Seller vs Carrier Duration)

SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_key) AS total_orders,
    
    -- stage 1: Average days seller takes to ship out the item
    ROUND(AVG(EXTRACT(DAY FROM (oi.shipping_limit_at - o.purchase_at)))::NUMERIC, 1) AS avg_seller_allowed_days,
    
    -- stage 2: Average days carrier takes to transport the item after deadline
    ROUND(AVG(EXTRACT(DAY FROM (o.delivered_customer_at - oi.shipping_limit_at)))::NUMERIC, 1) AS avg_carrier_transit_days,
    
    -- Total actual fulfillment days
    ROUND(AVG(EXTRACT(DAY FROM (o.delivered_customer_at - o.purchase_at)))::NUMERIC, 1) AS avg_total_delivery_days
FROM core.fact_orders o
JOIN core.fact_order_items oi ON o.order_key = oi.order_key
JOIN core.dim_customers c ON o.customer_key = c.customer_key
WHERE o.order_status = 'delivered'
  AND o.delivered_customer_at IS NOT NULL
  AND oi.shipping_limit_at IS NOT NULL
GROUP BY 1
ORDER BY total_orders DESC;