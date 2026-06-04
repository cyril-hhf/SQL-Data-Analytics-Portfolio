SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM staging.raw_customers
UNION ALL
SELECT 'geolocation', COUNT(*) FROM staging.raw_geolocation
UNION ALL
SELECT 'order_items', COUNT(*) FROM staging.raw_order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM staging.raw_order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM staging.raw_order_reviews
UNION ALL
SELECT 'orders', COUNT(*) FROM staging.raw_orders
UNION ALL
SELECT 'products', COUNT(*) FROM staging.raw_products
UNION ALL
SELECT 'sellers', COUNT(*) FROM staging.raw_sellers
UNION ALL
SELECT 'category_translation', COUNT(*) FROM staging.raw_category_translation;
