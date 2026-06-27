USE supply_chain_analytics;

-- KPI 1: Total Revenue

SELECT
    ROUND(SUM(sales),2) AS total_revenue
FROM supplychain_cleaned;

-- KPI 2: Total Profit

SELECT
    ROUND(SUM(order_profit_per_order),2) AS total_profit
FROM supplychain_cleaned;

-- KPI 3: Profit Margin %

SELECT
    ROUND(
        (SUM(order_profit_per_order) / SUM(sales)) * 100,
        2
    ) AS profit_margin_pct
FROM supplychain_cleaned;

-- KPI 4: On-Time Delivery %

 SELECT
SUM(CASE WHEN delivery_performance = 'On Time' THEN 1 ELSE 0 END) AS on_time_orders,
COUNT(*) AS total_orders
FROM supplychain_cleaned;
 
 SELECT
    CONCAT('[', delivery_performance, ']') AS delivery_value,
    LENGTH(delivery_performance) AS text_length,
    COUNT(*) AS total_orders
FROM supplychain_cleaned
GROUP BY delivery_performance, LENGTH(delivery_performance);

UPDATE supplychain_cleaned
SET delivery_performance = TRIM(REPLACE(delivery_performance, '\r', ''));

SELECT
    CONCAT('[', delivery_performance, ']') AS delivery_value,
    LENGTH(delivery_performance) AS text_length,
    COUNT(*) AS total_orders
FROM supplychain_cleaned
GROUP BY delivery_performance, LENGTH(delivery_performance);

SELECT
ROUND(
100.0 *
SUM(CASE WHEN delivery_performance = 'On Time' THEN 1 ELSE 0 END)
/
COUNT(*)
,2
) AS on_time_delivery_pct
FROM supplychain_cleaned;


-- KPI 5: Late Delivery %

SELECT
ROUND(
100.0 *
SUM(CASE WHEN delivery_performance = 'Late' THEN 1 ELSE 0 END)
/
COUNT(*)
,2
) AS late_delivery_pct
FROM supplychain_cleaned;