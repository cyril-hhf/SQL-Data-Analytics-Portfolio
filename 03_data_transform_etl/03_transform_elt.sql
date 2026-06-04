SELECT 'core.dim_customers' AS tbl, COUNT(*) FROM core.dim_customers
UNION ALL
SELECT 'core.dim_sellers', COUNT(*) FROM core.dim_sellers
UNION ALL
SELECT 'core.dim_products', COUNT(*) FROM core.dim_products
UNION ALL
SELECT 'core.fact_orders', COUNT(*) FROM core.fact_orders
UNION ALL
SELECT 'core.fact_order_items', COUNT(*) FROM core.fact_order_items;
