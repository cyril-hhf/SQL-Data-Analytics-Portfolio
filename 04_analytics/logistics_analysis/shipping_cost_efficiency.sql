-- Shipping Cost vs. Delivery Speed Efficiency (Cost per day)

SELECT 
    c.customer_state,
    ROUND(AVG(oi.freight_value)::NUMERIC, 2) AS avg_freight_cost,
    ROUND(AVG(EXTRACT(DAY FROM (o.delivered_customer_at - o.purchase_at)))::NUMERIC, 1) AS avg_delivery_days,
    ROUND(
        (AVG(oi.freight_value) / NULLIF(AVG(EXTRACT(DAY FROM (o.delivered_customer_at - o.purchase_at))), 0))::NUMERIC, 
        2
    ) AS freight_cost_per_day_indexed
FROM core.fact_order_items oi
JOIN core.fact_orders o ON oi.order_key = o.order_key
JOIN core.dim_customers c ON o.customer_key = c.customer_key
WHERE o.order_status = 'delivered'
  AND o.delivered_customer_at IS NOT NULL
GROUP BY 1
ORDER BY avg_freight_cost DESC;