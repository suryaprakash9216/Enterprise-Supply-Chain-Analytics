USE supply_chain_dw;

-- =========================================================
-- PHASE 10: ADVANCED SQL ANALYTICS
-- MODULE 1: EXECUTIVE BUSINESS ANALYTICS
-- =========================================================


-- 1. Revenue, Profit, Orders and Profit Margin by Year

SELECT
    d.order_year,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_date d
    ON f.order_date_dateorders = d.order_date_dateorders
GROUP BY d.order_year
ORDER BY d.order_year;


-- 2. Revenue and Profit by Quarter

SELECT
    d.order_year,
    d.order_quarter,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    COUNT(DISTINCT f.order_id) AS total_orders
FROM fact_orders f
JOIN dim_date d
    ON f.order_date_dateorders = d.order_date_dateorders
GROUP BY d.order_year, d.order_quarter
ORDER BY d.order_year, d.order_quarter;


-- 3. Monthly Revenue Trend

SELECT
    d.order_year,
    d.order_month,
    ROUND(SUM(f.sales), 2) AS monthly_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS monthly_profit,
    COUNT(DISTINCT f.order_id) AS monthly_orders
FROM fact_orders f
JOIN dim_date d
    ON f.order_date_dateorders = d.order_date_dateorders
GROUP BY d.order_year, d.order_month
ORDER BY d.order_year, d.order_month;


-- 4. Monthly Revenue Growth Percentage using LAG()

WITH monthly_sales AS (
    SELECT
        d.order_year,
        d.order_month,
        STR_TO_DATE(CONCAT(d.order_year, '-', d.order_month, '-01'), '%Y-%m-%d') AS month_start_date,
        SUM(f.sales) AS monthly_revenue
    FROM fact_orders f
    JOIN dim_date d
        ON f.order_date_dateorders = d.order_date_dateorders
    GROUP BY d.order_year, d.order_month
),
growth_calc AS (
    SELECT
        order_year,
        order_month,
        month_start_date,
        monthly_revenue,
        LAG(monthly_revenue) OVER (ORDER BY month_start_date) AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    order_year,
    order_month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        ((monthly_revenue - previous_month_revenue) / previous_month_revenue) * 100,
        2
    ) AS monthly_growth_pct
FROM growth_calc
ORDER BY month_start_date;


-- 5. Running Total Revenue by Month

WITH monthly_sales AS (
    SELECT
        d.order_year,
        d.order_month,
        STR_TO_DATE(CONCAT(d.order_year, '-', d.order_month, '-01'), '%Y-%m-%d') AS month_start_date,
        SUM(f.sales) AS monthly_revenue
    FROM fact_orders f
    JOIN dim_date d
        ON f.order_date_dateorders = d.order_date_dateorders
    GROUP BY d.order_year, d.order_month
)
SELECT
    order_year,
    order_month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(
        SUM(monthly_revenue) OVER (
            ORDER BY month_start_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS running_total_revenue
FROM monthly_sales
ORDER BY month_start_date;


-- 6. Moving Average Revenue - 3 Month Trend

WITH monthly_sales AS (
    SELECT
        d.order_year,
        d.order_month,
        STR_TO_DATE(CONCAT(d.order_year, '-', d.order_month, '-01'), '%Y-%m-%d') AS month_start_date,
        SUM(f.sales) AS monthly_revenue
    FROM fact_orders f
    JOIN dim_date d
        ON f.order_date_dateorders = d.order_date_dateorders
    GROUP BY d.order_year, d.order_month
)
SELECT
    order_year,
    order_month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(
        AVG(monthly_revenue) OVER (
            ORDER BY month_start_date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS three_month_moving_avg_revenue
FROM monthly_sales
ORDER BY month_start_date;


-- 7. Revenue Contribution Percentage by Year

WITH yearly_sales AS (
    SELECT
        d.order_year,
        SUM(f.sales) AS yearly_revenue
    FROM fact_orders f
    JOIN dim_date d
        ON f.order_date_dateorders = d.order_date_dateorders
    GROUP BY d.order_year
)
SELECT
    order_year,
    ROUND(yearly_revenue, 2) AS yearly_revenue,
    ROUND(
        yearly_revenue / SUM(yearly_revenue) OVER () * 100,
        2
    ) AS revenue_contribution_pct
FROM yearly_sales
ORDER BY yearly_revenue DESC;


-- 8. Profit Margin Trend by Month

SELECT
    d.order_year,
    d.order_month,
    ROUND(SUM(f.sales), 2) AS monthly_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS monthly_profit,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_date d
    ON f.order_date_dateorders = d.order_date_dateorders
GROUP BY d.order_year, d.order_month
ORDER BY d.order_year, d.order_month;


-- 9. Best and Worst Revenue Months

WITH monthly_sales AS (
    SELECT
        d.order_year,
        d.order_month,
        STR_TO_DATE(CONCAT(d.order_year, '-', d.order_month, '-01'), '%Y-%m-%d') AS month_start_date,
        SUM(f.sales) AS monthly_revenue
    FROM fact_orders f
    JOIN dim_date d
        ON f.order_date_dateorders = d.order_date_dateorders
    GROUP BY d.order_year, d.order_month
),
ranked_months AS (
    SELECT
        order_year,
        order_month,
        monthly_revenue,
        RANK() OVER (ORDER BY monthly_revenue DESC) AS revenue_rank_desc,
        RANK() OVER (ORDER BY monthly_revenue ASC) AS revenue_rank_asc
    FROM monthly_sales
)
SELECT
    order_year,
    order_month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    revenue_rank_desc,
    revenue_rank_asc
FROM ranked_months
WHERE revenue_rank_desc <= 5
   OR revenue_rank_asc <= 5
ORDER BY monthly_revenue DESC;


-- 10. Executive KPI Scorecard from Star Schema

SELECT
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(order_profit_per_order), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(order_item_id) AS total_order_items,
    ROUND(AVG(sales), 2) AS average_sales_per_order_item,
    ROUND((SUM(order_profit_per_order) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM fact_orders;


-- =========================================================
-- MODULE 2: SUPPLY CHAIN ANALYTICS
-- =========================================================

USE supply_chain_dw;


-- 1. Revenue and Profit by Region

SELECT
    l.order_region,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_location l
    ON f.location_key = l.location_key
GROUP BY l.order_region
ORDER BY total_revenue DESC;


-- 2. Revenue and Profit by Market

SELECT
    l.market,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_location l
    ON f.location_key = l.location_key
GROUP BY l.market
ORDER BY total_revenue DESC;


-- 3. Top 10 Countries by Revenue

SELECT
    l.order_country,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    COUNT(DISTINCT f.order_id) AS total_orders
FROM fact_orders f
JOIN dim_location l
    ON f.location_key = l.location_key
GROUP BY l.order_country
ORDER BY total_revenue DESC
LIMIT 10;


-- 4. Bottom 10 Countries by Revenue

SELECT
    l.order_country,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    COUNT(DISTINCT f.order_id) AS total_orders
FROM fact_orders f
JOIN dim_location l
    ON f.location_key = l.location_key
GROUP BY l.order_country
ORDER BY total_revenue ASC
LIMIT 10;


-- 5. Region Revenue Contribution %

WITH region_sales AS (
    SELECT
        l.order_region,
        SUM(f.sales) AS region_revenue
    FROM fact_orders f
    JOIN dim_location l
        ON f.location_key = l.location_key
    GROUP BY l.order_region
)
SELECT
    order_region,
    ROUND(region_revenue, 2) AS region_revenue,
    ROUND(
        region_revenue / SUM(region_revenue) OVER () * 100,
        2
    ) AS revenue_contribution_pct
FROM region_sales
ORDER BY region_revenue DESC;


-- 6. Rank Regions by Revenue and Profit

SELECT
    l.order_region,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    RANK() OVER (ORDER BY SUM(f.sales) DESC) AS revenue_rank,
    RANK() OVER (ORDER BY SUM(f.order_profit_per_order) DESC) AS profit_rank
FROM fact_orders f
JOIN dim_location l
    ON f.location_key = l.location_key
GROUP BY l.order_region
ORDER BY revenue_rank;


-- 7. High Revenue but Low Profit Margin Regions

WITH region_perf AS (
    SELECT
        l.order_region,
        SUM(f.sales) AS total_revenue,
        SUM(f.order_profit_per_order) AS total_profit,
        (SUM(f.order_profit_per_order) / SUM(f.sales)) * 100 AS profit_margin_pct
    FROM fact_orders f
    JOIN dim_location l
        ON f.location_key = l.location_key
    GROUP BY l.order_region
)
SELECT
    order_region,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_profit, 2) AS total_profit,
    ROUND(profit_margin_pct, 2) AS profit_margin_pct
FROM region_perf
WHERE total_revenue > (
    SELECT AVG(total_revenue) FROM region_perf
)
AND profit_margin_pct < (
    SELECT AVG(profit_margin_pct) FROM region_perf
)
ORDER BY total_revenue DESC;


-- 8. Delivery Performance by Region

SELECT
    l.order_region,
    f.delivery_performance,
    COUNT(*) AS total_order_items,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY l.order_region), 2) AS performance_pct
FROM fact_orders f
JOIN dim_location l
    ON f.location_key = l.location_key
GROUP BY l.order_region, f.delivery_performance
ORDER BY l.order_region, performance_pct DESC;


-- 9. Late Delivery Rate by Market

SELECT
    l.market,
    COUNT(*) AS total_order_items,
    SUM(CASE WHEN f.delivery_performance = 'Late' THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        SUM(CASE WHEN f.delivery_performance = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS late_delivery_pct
FROM fact_orders f
JOIN dim_location l
    ON f.location_key = l.location_key
GROUP BY l.market
ORDER BY late_delivery_pct DESC;


-- 10. Supply Chain Executive Summary by Market

SELECT
    l.market,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct,
    ROUND(
        SUM(CASE WHEN f.delivery_performance = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS late_delivery_pct
FROM fact_orders f
JOIN dim_location l
    ON f.location_key = l.location_key
GROUP BY l.market
ORDER BY total_revenue DESC;

-- =========================================================
-- MODULE 3: PRODUCT & CATEGORY ANALYTICS
-- =========================================================

USE supply_chain_dw;


-- 1. Revenue and Profit by Category

SELECT
    p.category_name,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.order_item_quantity) AS total_quantity,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_product p
    ON f.product_card_id = p.product_card_id
GROUP BY p.category_name
ORDER BY total_revenue DESC;


-- 2. Revenue and Profit by Department

SELECT
    p.department_name,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.order_item_quantity) AS total_quantity,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_product p
    ON f.product_card_id = p.product_card_id
GROUP BY p.department_name
ORDER BY total_revenue DESC;


-- 3. Top 10 Products by Revenue

SELECT
    p.product_name,
    p.category_name,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    SUM(f.order_item_quantity) AS total_quantity
FROM fact_orders f
JOIN dim_product p
    ON f.product_card_id = p.product_card_id
GROUP BY p.product_name, p.category_name
ORDER BY total_revenue DESC
LIMIT 10;


-- 4. Top 10 Products by Profit

SELECT
    p.product_name,
    p.category_name,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    SUM(f.order_item_quantity) AS total_quantity
FROM fact_orders f
JOIN dim_product p
    ON f.product_card_id = p.product_card_id
GROUP BY p.product_name, p.category_name
ORDER BY total_profit DESC
LIMIT 10;


-- 5. Bottom 10 Products by Profit

SELECT
    p.product_name,
    p.category_name,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    SUM(f.order_item_quantity) AS total_quantity
FROM fact_orders f
JOIN dim_product p
    ON f.product_card_id = p.product_card_id
GROUP BY p.product_name, p.category_name
ORDER BY total_profit ASC
LIMIT 10;


-- 6. Category Revenue Contribution %

WITH category_sales AS (
    SELECT
        p.category_name,
        SUM(f.sales) AS category_revenue
    FROM fact_orders f
    JOIN dim_product p
        ON f.product_card_id = p.product_card_id
    GROUP BY p.category_name
)
SELECT
    category_name,
    ROUND(category_revenue, 2) AS category_revenue,
    ROUND(
        category_revenue / SUM(category_revenue) OVER () * 100,
        2
    ) AS revenue_contribution_pct
FROM category_sales
ORDER BY category_revenue DESC;


-- 7. Rank Categories by Revenue and Profit

SELECT
    p.category_name,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    RANK() OVER (ORDER BY SUM(f.sales) DESC) AS revenue_rank,
    RANK() OVER (ORDER BY SUM(f.order_profit_per_order) DESC) AS profit_rank
FROM fact_orders f
JOIN dim_product p
    ON f.product_card_id = p.product_card_id
GROUP BY p.category_name
ORDER BY revenue_rank;


-- 8. High Revenue but Low Profit Margin Categories

WITH category_perf AS (
    SELECT
        p.category_name,
        SUM(f.sales) AS total_revenue,
        SUM(f.order_profit_per_order) AS total_profit,
        (SUM(f.order_profit_per_order) / SUM(f.sales)) * 100 AS profit_margin_pct
    FROM fact_orders f
    JOIN dim_product p
        ON f.product_card_id = p.product_card_id
    GROUP BY p.category_name
)
SELECT
    category_name,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_profit, 2) AS total_profit,
    ROUND(profit_margin_pct, 2) AS profit_margin_pct
FROM category_perf
WHERE total_revenue > (
    SELECT AVG(total_revenue) FROM category_perf
)
AND profit_margin_pct < (
    SELECT AVG(profit_margin_pct) FROM category_perf
)
ORDER BY total_revenue DESC;


-- 9. Discount Impact by Category

SELECT
    p.category_name,
    ROUND(AVG(f.order_item_discount), 2) AS avg_discount_amount,
    ROUND(AVG(f.order_item_discount_rate) * 100, 2) AS avg_discount_rate_pct,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_product p
    ON f.product_card_id = p.product_card_id
GROUP BY p.category_name
ORDER BY avg_discount_rate_pct DESC;


-- 10. Product Executive Summary

SELECT
    COUNT(DISTINCT p.product_card_id) AS total_products,
    COUNT(DISTINCT p.category_name) AS total_categories,
    COUNT(DISTINCT p.department_name) AS total_departments,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    SUM(f.order_item_quantity) AS total_quantity_sold,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_product p
    ON f.product_card_id = p.product_card_id;
    
    
-- =========================================================
-- MODULE 4: CUSTOMER ANALYTICS
-- =========================================================

USE supply_chain_dw;


-- 1. Revenue and Profit by Customer Segment

SELECT
    c.customer_segment,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    COUNT(DISTINCT f.order_id) AS total_orders,
    COUNT(DISTINCT f.customer_id) AS total_customers,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY c.customer_segment
ORDER BY total_revenue DESC;


-- 2. Top 10 Customers by Revenue

SELECT
    c.customer_id,
    CONCAT(c.customer_fname, ' ', c.customer_lname) AS customer_name,
    c.customer_segment,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    COUNT(DISTINCT f.order_id) AS total_orders
FROM fact_orders f
JOIN dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_fname,
    c.customer_lname,
    c.customer_segment
ORDER BY total_revenue DESC
LIMIT 10;


-- 3. Top 10 Customers by Profit

SELECT
    c.customer_id,
    CONCAT(c.customer_fname, ' ', c.customer_lname) AS customer_name,
    c.customer_segment,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    COUNT(DISTINCT f.order_id) AS total_orders
FROM fact_orders f
JOIN dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_fname,
    c.customer_lname,
    c.customer_segment
ORDER BY total_profit DESC
LIMIT 10;


-- 4. Average Order Value by Customer Segment

SELECT
    c.customer_segment,
    ROUND(SUM(f.sales) / COUNT(DISTINCT f.order_id), 2) AS average_order_value,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND(SUM(f.sales), 2) AS total_revenue
FROM fact_orders f
JOIN dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY c.customer_segment
ORDER BY average_order_value DESC;


-- 5. Customer Revenue Ranking

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        CONCAT(c.customer_fname, ' ', c.customer_lname) AS customer_name,
        c.customer_segment,
        SUM(f.sales) AS total_revenue,
        SUM(f.order_profit_per_order) AS total_profit
    FROM fact_orders f
    JOIN dim_customer c
        ON f.customer_id = c.customer_id
    GROUP BY
        c.customer_id,
        c.customer_fname,
        c.customer_lname,
        c.customer_segment
)
SELECT
    customer_id,
    customer_name,
    customer_segment,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_profit, 2) AS total_profit,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    RANK() OVER (ORDER BY total_profit DESC) AS profit_rank
FROM customer_revenue
ORDER BY revenue_rank
LIMIT 20;


-- 6. High Revenue but Low Profit Margin Customers

WITH customer_perf AS (
    SELECT
        c.customer_id,
        CONCAT(c.customer_fname, ' ', c.customer_lname) AS customer_name,
        c.customer_segment,
        SUM(f.sales) AS total_revenue,
        SUM(f.order_profit_per_order) AS total_profit,
        (SUM(f.order_profit_per_order) / SUM(f.sales)) * 100 AS profit_margin_pct
    FROM fact_orders f
    JOIN dim_customer c
        ON f.customer_id = c.customer_id
    GROUP BY
        c.customer_id,
        c.customer_fname,
        c.customer_lname,
        c.customer_segment
)
SELECT
    customer_id,
    customer_name,
    customer_segment,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_profit, 2) AS total_profit,
    ROUND(profit_margin_pct, 2) AS profit_margin_pct
FROM customer_perf
WHERE total_revenue > (
    SELECT AVG(total_revenue) FROM customer_perf
)
AND profit_margin_pct < (
    SELECT AVG(profit_margin_pct) FROM customer_perf
)
ORDER BY total_revenue DESC
LIMIT 20;


-- 7. Customer Executive Summary

SELECT
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT c.customer_segment) AS total_segments,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    ROUND(SUM(f.sales) / COUNT(DISTINCT c.customer_id), 2) AS revenue_per_customer,
    ROUND(SUM(f.order_profit_per_order) / COUNT(DISTINCT c.customer_id), 2) AS profit_per_customer,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_customer c
    ON f.customer_id = c.customer_id;
    
-- =========================================================
-- MODULE 5: INVENTORY ANALYTICS
-- =========================================================

USE supply_chain_dw;

-- 1. Fast Moving Products by Quantity Sold
SELECT
    p.product_name,
    p.category_name,
    SUM(f.order_item_quantity) AS total_quantity_sold,
    ROUND(SUM(f.sales), 2) AS total_revenue
FROM fact_orders f
JOIN dim_product p ON f.product_card_id = p.product_card_id
GROUP BY p.product_name, p.category_name
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- 2. Slow Moving Products by Quantity Sold
SELECT
    p.product_name,
    p.category_name,
    SUM(f.order_item_quantity) AS total_quantity_sold,
    ROUND(SUM(f.sales), 2) AS total_revenue
FROM fact_orders f
JOIN dim_product p ON f.product_card_id = p.product_card_id
GROUP BY p.product_name, p.category_name
ORDER BY total_quantity_sold ASC
LIMIT 10;

-- 3. Demand by Category
SELECT
    p.category_name,
    SUM(f.order_item_quantity) AS total_quantity_sold,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit
FROM fact_orders f
JOIN dim_product p ON f.product_card_id = p.product_card_id
GROUP BY p.category_name
ORDER BY total_quantity_sold DESC;

-- 4. ABC Analysis by Product Revenue
WITH product_sales AS (
    SELECT
        p.product_name,
        p.category_name,
        SUM(f.sales) AS product_revenue
    FROM fact_orders f
    JOIN dim_product p ON f.product_card_id = p.product_card_id
    GROUP BY p.product_name, p.category_name
),
abc_calc AS (
    SELECT
        product_name,
        category_name,
        product_revenue,
        SUM(product_revenue) OVER (ORDER BY product_revenue DESC) /
        SUM(product_revenue) OVER () * 100 AS cumulative_revenue_pct
    FROM product_sales
)
SELECT
    product_name,
    category_name,
    ROUND(product_revenue, 2) AS product_revenue,
    ROUND(cumulative_revenue_pct, 2) AS cumulative_revenue_pct,
    CASE
        WHEN cumulative_revenue_pct <= 80 THEN 'A'
        WHEN cumulative_revenue_pct <= 95 THEN 'B'
        ELSE 'C'
    END AS abc_class
FROM abc_calc
ORDER BY product_revenue DESC;

-- 5. ABC Summary
WITH product_sales AS (
    SELECT
        p.product_name,
        SUM(f.sales) AS product_revenue
    FROM fact_orders f
    JOIN dim_product p ON f.product_card_id = p.product_card_id
    GROUP BY p.product_name
),
abc_calc AS (
    SELECT
        product_name,
        product_revenue,
        SUM(product_revenue) OVER (ORDER BY product_revenue DESC) /
        SUM(product_revenue) OVER () * 100 AS cumulative_revenue_pct
    FROM product_sales
),
abc_classified AS (
    SELECT
        product_name,
        product_revenue,
        CASE
            WHEN cumulative_revenue_pct <= 80 THEN 'A'
            WHEN cumulative_revenue_pct <= 95 THEN 'B'
            ELSE 'C'
        END AS abc_class
    FROM abc_calc
)
SELECT
    abc_class,
    COUNT(*) AS total_products,
    ROUND(SUM(product_revenue), 2) AS total_revenue
FROM abc_classified
GROUP BY abc_class
ORDER BY abc_class;

-- 6. Inventory Category Contribution %
WITH category_qty AS (
    SELECT
        p.category_name,
        SUM(f.order_item_quantity) AS total_quantity
    FROM fact_orders f
    JOIN dim_product p ON f.product_card_id = p.product_card_id
    GROUP BY p.category_name
)
SELECT
    category_name,
    total_quantity,
    ROUND(total_quantity / SUM(total_quantity) OVER () * 100, 2) AS quantity_contribution_pct
FROM category_qty
ORDER BY total_quantity DESC;

-- 7. Inventory Executive Summary
SELECT
    COUNT(DISTINCT p.product_card_id) AS total_products,
    COUNT(DISTINCT p.category_name) AS total_categories,
    SUM(f.order_item_quantity) AS total_quantity_sold,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit
FROM fact_orders f
JOIN dim_product p ON f.product_card_id = p.product_card_id;


-- =========================================================
-- MODULE 6: LOGISTICS ANALYTICS
-- =========================================================

-- 1. Delivery Performance Distribution
SELECT
    delivery_performance,
    COUNT(*) AS total_order_items,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS performance_pct
FROM fact_orders
GROUP BY delivery_performance
ORDER BY total_order_items DESC;

-- 2. Shipping Mode Performance
SELECT
    s.shipping_mode,
    COUNT(*) AS total_order_items,
    ROUND(AVG(f.shipping_delay), 2) AS avg_shipping_delay,
    ROUND(SUM(CASE WHEN f.delivery_performance = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_pct
FROM fact_orders f
JOIN dim_shipping s ON f.shipping_key = s.shipping_key
GROUP BY s.shipping_mode
ORDER BY late_delivery_pct DESC;

-- 3. Average Shipping Delay by Region
SELECT
    l.order_region,
    ROUND(AVG(f.shipping_delay), 2) AS avg_shipping_delay,
    COUNT(*) AS total_order_items
FROM fact_orders f
JOIN dim_location l ON f.location_key = l.location_key
GROUP BY l.order_region
ORDER BY avg_shipping_delay DESC;

-- 4. Late Delivery by Region
SELECT
    l.order_region,
    COUNT(*) AS total_order_items,
    SUM(CASE WHEN f.delivery_performance = 'Late' THEN 1 ELSE 0 END) AS late_orders,
    ROUND(SUM(CASE WHEN f.delivery_performance = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_pct
FROM fact_orders f
JOIN dim_location l ON f.location_key = l.location_key
GROUP BY l.order_region
ORDER BY late_delivery_pct DESC;

-- 5. Delivery Status Analysis
SELECT
    s.delivery_status,
    COUNT(*) AS total_order_items,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS status_pct
FROM fact_orders f
JOIN dim_shipping s ON f.shipping_key = s.shipping_key
GROUP BY s.delivery_status
ORDER BY total_order_items DESC;

-- 6. Shipping Delay Trend by Month
SELECT
    d.order_year,
    d.order_month,
    ROUND(AVG(f.shipping_delay), 2) AS avg_shipping_delay,
    ROUND(SUM(CASE WHEN f.delivery_performance = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_pct
FROM fact_orders f
JOIN dim_date d ON f.order_date_dateorders = d.order_date_dateorders
GROUP BY d.order_year, d.order_month
ORDER BY d.order_year, d.order_month;

-- 7. Logistics Executive Summary
SELECT
    COUNT(*) AS total_order_items,
    ROUND(AVG(shipping_delay), 2) AS avg_shipping_delay,
    ROUND(SUM(CASE WHEN delivery_performance = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_pct,
    ROUND(SUM(CASE WHEN delivery_performance = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS on_time_delivery_pct
FROM fact_orders;


-- =========================================================
-- MODULE 7: OPERATIONAL ANALYTICS
-- =========================================================

-- 1. Order Volume by Year
SELECT
    d.order_year,
    COUNT(DISTINCT f.order_id) AS total_orders,
    COUNT(f.order_item_id) AS total_order_items
FROM fact_orders f
JOIN dim_date d ON f.order_date_dateorders = d.order_date_dateorders
GROUP BY d.order_year
ORDER BY d.order_year;

-- 2. Revenue, Profit, and Quantity by Department
SELECT
    p.department_name,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    SUM(f.order_item_quantity) AS total_quantity,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_product p ON f.product_card_id = p.product_card_id
GROUP BY p.department_name
ORDER BY total_revenue DESC;

-- 3. Discount vs Profit by Department
SELECT
    p.department_name,
    ROUND(AVG(f.order_item_discount_rate) * 100, 2) AS avg_discount_rate_pct,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_product p ON f.product_card_id = p.product_card_id
GROUP BY p.department_name
ORDER BY avg_discount_rate_pct DESC;

-- 4. High Discount Low Profit Categories
SELECT
    p.category_name,
    ROUND(AVG(f.order_item_discount_rate) * 100, 2) AS avg_discount_rate_pct,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_product p ON f.product_card_id = p.product_card_id
GROUP BY p.category_name
HAVING avg_discount_rate_pct > 10
   AND profit_margin_pct < 10
ORDER BY avg_discount_rate_pct DESC;

-- 5. Profit Leakage Products
SELECT
    p.product_name,
    p.category_name,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_product p ON f.product_card_id = p.product_card_id
GROUP BY p.product_name, p.category_name
HAVING total_profit < 0
ORDER BY total_profit ASC;

-- 6. Operational Efficiency by Market
SELECT
    l.market,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    ROUND(AVG(f.shipping_delay), 2) AS avg_shipping_delay,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_location l ON f.location_key = l.location_key
GROUP BY l.market
ORDER BY total_revenue DESC;

-- 7. Operations Executive Summary
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(order_item_id) AS total_order_items,
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(order_profit_per_order), 2) AS total_profit,
    ROUND(AVG(order_item_discount_rate) * 100, 2) AS avg_discount_rate_pct,
    ROUND(AVG(shipping_delay), 2) AS avg_shipping_delay
FROM fact_orders;


-- =========================================================
-- MODULE 8: ADVANCED SQL
-- =========================================================

-- 1. Top 5 Products Within Each Category by Revenue
WITH product_rank AS (
    SELECT
        p.category_name,
        p.product_name,
        ROUND(SUM(f.sales), 2) AS total_revenue,
        RANK() OVER (
            PARTITION BY p.category_name
            ORDER BY SUM(f.sales) DESC
        ) AS product_rank
    FROM fact_orders f
    JOIN dim_product p ON f.product_card_id = p.product_card_id
    GROUP BY p.category_name, p.product_name
)
SELECT *
FROM product_rank
WHERE product_rank <= 5
ORDER BY category_name, product_rank;

-- 2. Region Monthly Revenue Running Total
WITH monthly_region_sales AS (
    SELECT
        l.order_region,
        d.order_year,
        d.order_month,
        STR_TO_DATE(CONCAT(d.order_year, '-', d.order_month, '-01'), '%Y-%m-%d') AS month_start_date,
        SUM(f.sales) AS monthly_revenue
    FROM fact_orders f
    JOIN dim_location l ON f.location_key = l.location_key
    JOIN dim_date d ON f.order_date_dateorders = d.order_date_dateorders
    GROUP BY l.order_region, d.order_year, d.order_month
)
SELECT
    order_region,
    order_year,
    order_month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER (
        PARTITION BY order_region
        ORDER BY month_start_date
    ), 2) AS running_revenue
FROM monthly_region_sales
ORDER BY order_region, month_start_date;

-- 3. Month-over-Month Profit Growth
WITH monthly_profit AS (
    SELECT
        d.order_year,
        d.order_month,
        STR_TO_DATE(CONCAT(d.order_year, '-', d.order_month, '-01'), '%Y-%m-%d') AS month_start_date,
        SUM(f.order_profit_per_order) AS monthly_profit
    FROM fact_orders f
    JOIN dim_date d ON f.order_date_dateorders = d.order_date_dateorders
    GROUP BY d.order_year, d.order_month
),
profit_growth AS (
    SELECT
        order_year,
        order_month,
        month_start_date,
        monthly_profit,
        LAG(monthly_profit) OVER (ORDER BY month_start_date) AS previous_month_profit
    FROM monthly_profit
)
SELECT
    order_year,
    order_month,
    ROUND(monthly_profit, 2) AS monthly_profit,
    ROUND(previous_month_profit, 2) AS previous_month_profit,
    ROUND((monthly_profit - previous_month_profit) / previous_month_profit * 100, 2) AS profit_growth_pct
FROM profit_growth
ORDER BY month_start_date;

-- 4. Customer Segmentation Using NTILE
WITH customer_sales AS (
    SELECT
        c.customer_id,
        CONCAT(c.customer_fname, ' ', c.customer_lname) AS customer_name,
        SUM(f.sales) AS total_revenue
    FROM fact_orders f
    JOIN dim_customer c ON f.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_fname, c.customer_lname
)
SELECT
    customer_id,
    customer_name,
    ROUND(total_revenue, 2) AS total_revenue,
    NTILE(4) OVER (ORDER BY total_revenue DESC) AS customer_quartile
FROM customer_sales
ORDER BY total_revenue DESC;

-- 5. Category Revenue Share Inside Department
WITH category_dept_sales AS (
    SELECT
        p.department_name,
        p.category_name,
        SUM(f.sales) AS category_revenue
    FROM fact_orders f
    JOIN dim_product p ON f.product_card_id = p.product_card_id
    GROUP BY p.department_name, p.category_name
)
SELECT
    department_name,
    category_name,
    ROUND(category_revenue, 2) AS category_revenue,
    ROUND(category_revenue / SUM(category_revenue) OVER (PARTITION BY department_name) * 100, 2) AS dept_revenue_share_pct
FROM category_dept_sales
ORDER BY department_name, dept_revenue_share_pct DESC;

-- 6. Late Delivery Rank by Region
SELECT
    l.order_region,
    COUNT(*) AS total_order_items,
    SUM(CASE WHEN f.delivery_performance = 'Late' THEN 1 ELSE 0 END) AS late_orders,
    ROUND(SUM(CASE WHEN f.delivery_performance = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_pct,
    RANK() OVER (
        ORDER BY SUM(CASE WHEN f.delivery_performance = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) DESC
    ) AS late_delivery_rank
FROM fact_orders f
JOIN dim_location l ON f.location_key = l.location_key
GROUP BY l.order_region
ORDER BY late_delivery_rank;

-- 7. Final Advanced SQL Executive Summary
SELECT
    COUNT(DISTINCT f.order_id) AS total_orders,
    COUNT(f.order_item_id) AS total_order_items,
    COUNT(DISTINCT f.customer_id) AS total_customers,
    COUNT(DISTINCT f.product_card_id) AS total_products,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.order_profit_per_order), 2) AS total_profit,
    ROUND((SUM(f.order_profit_per_order) / SUM(f.sales)) * 100, 2) AS profit_margin_pct,
    ROUND(SUM(CASE WHEN f.delivery_performance = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_pct
FROM fact_orders f;







SELECT * FROM fact_orders
limit 200000 ;


SELECT * FROM dim_customer
limit 200000 ;

SELECT * FROM dim_product
limit 200000 ;

SELECT * FROM dim_location
limit 200000 ;

SELECT * FROM dim_shipping
limit 200000 ;

SELECT * FROM dim_date
limit 200000 ;