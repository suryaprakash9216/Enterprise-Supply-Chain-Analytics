CREATE DATABASE supply_chain_analytics;

USE supply_chain_analytics;

SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE 'local_infile';


CREATE TABLE supplychain_cleaned (
    type VARCHAR(50),
    days_for_shipping_real INT,
    days_for_shipment_scheduled INT,
    benefit_per_order DECIMAL(12,4),
    sales_per_customer DECIMAL(12,4),
    delivery_status VARCHAR(100),
    late_delivery_risk INT,
    category_id INT,
    category_name VARCHAR(100),
    customer_city VARCHAR(100),
    customer_country VARCHAR(100),
    customer_email VARCHAR(255),
    customer_fname VARCHAR(100),
    customer_id INT,
    customer_lname VARCHAR(100),
    customer_password VARCHAR(255),
    customer_segment VARCHAR(50),
    customer_state VARCHAR(50),
    customer_street VARCHAR(255),
    customer_zipcode DECIMAL(12,2),
    department_id INT,
    department_name VARCHAR(100),
    latitude DECIMAL(12,8),
    longitude DECIMAL(12,8),
    market VARCHAR(100),
    order_city VARCHAR(100),
    order_country VARCHAR(100),
    order_customer_id INT,
    order_date_dateorders DATETIME,
    order_id INT,
    order_item_cardprod_id INT,
    order_item_discount DECIMAL(12,4),
    order_item_discount_rate DECIMAL(12,4),
    order_item_id INT,
    order_item_product_price DECIMAL(12,4),
    order_item_profit_ratio DECIMAL(12,4),
    order_item_quantity INT,
    sales DECIMAL(12,4),
    order_item_total DECIMAL(12,4),
    order_profit_per_order DECIMAL(12,4),
    order_region VARCHAR(100),
    order_state VARCHAR(100),
    order_status VARCHAR(100),
    product_card_id INT,
    product_category_id INT,
    product_image TEXT,
    product_name VARCHAR(255),
    product_price DECIMAL(12,4),
    product_status INT,
    shipping_date_dateorders DATETIME,
    shipping_mode VARCHAR(100),
    order_year INT,
    order_month INT,
    order_quarter INT,
    shipping_delay INT,
    on_time_delivery VARCHAR(10),
    profit_margin_percent DECIMAL(12,4),
    delivery_performance VARCHAR(20)
);

LOAD DATA LOCAL INFILE 'C:/Projects/Supply Chain Analytics Platform/Supply Chain Analytics Platform File/SupplyChain_Cleaned.csv'
INTO TABLE supplychain_cleaned
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*)
from supplychain_cleaned;

--- Query 1: Top 10 Regions by Sales

SELECT 
    order_region,
    ROUND(SUM(sales), 2) AS total_sales
FROM supplychain_cleaned
GROUP BY order_region
ORDER BY total_sales DESC
LIMIT 10;

--- Which regions generate the highest sales?

SELECT 
    order_region,
    ROUND(SUM(sales),2) AS total_sales
FROM supplychain_cleaned
GROUP BY order_region
ORDER BY total_sales DESC;

--- Which customer segment generates the most revenue?

SELECT
    customer_segment,
    ROUND(SUM(sales),2) AS total_sales
FROM supplychain_cleaned
GROUP BY customer_segment
ORDER BY total_sales DESC;