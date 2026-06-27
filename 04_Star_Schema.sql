USE supply_chain_analytics;

--- Create the Customer Dimension:

DROP TABLE IF EXISTS dim_customer;

CREATE TABLE dim_customer AS
SELECT DISTINCT
    customer_id,
    customer_fname,
    customer_lname,
    customer_segment,
    customer_city,
    customer_state,
    customer_country,
    customer_zipcode
FROM supplychain_cleaned;

SELECT COUNT(*) FROM dim_customer;

-- Create Product Dimension 

CREATE TABLE dim_product AS
SELECT DISTINCT
    product_card_id,
    product_name,
    category_id,
    category_name,
    department_id,
    department_name
FROM supplychain_cleaned;

SELECT COUNT(*) FROM dim_product;

-- Create Date Dimension

CREATE TABLE dim_date AS
SELECT DISTINCT
    order_date_dateorders,
    order_year,
    order_month,
    order_quarter
FROM supplychain_cleaned;

SELECT COUNT(*) FROM dim_date;

-- =========================================
-- Create Shipping Dimension
-- =========================================
 

CREATE TABLE dim_shipping AS
SELECT DISTINCT
    shipping_mode,
    shipping_date_dateorders,
    days_for_shipping_real,
    days_for_shipment_scheduled,
    shipping_delay,
    delivery_status,
    delivery_performance,
    on_time_delivery
FROM supplychain_cleaned;

SELECT COUNT(*) FROM dim_shipping;

-- =========================================
-- Create Location Dimension
-- =========================================


CREATE TABLE dim_location AS
SELECT DISTINCT
    order_city,
    order_state,
    order_country,
    order_region,
    market,
    latitude,
    longitude
FROM supplychain_cleaned;

SELECT COUNT(*) FROM dim_location;


 

DROP TABLE IF EXISTS fact_orders;

CREATE TABLE fact_orders AS
SELECT
    order_item_id,
    order_id,
    customer_id,
    product_card_id,
    order_date_dateorders,
    shipping_date_dateorders,
    sales,
    order_profit_per_order,
    order_item_quantity,
    order_item_discount,
    order_item_discount_rate,
    shipping_delay,
    delivery_performance
FROM supplychain_cleaned;

SELECT COUNT(*) FROM fact_orders;

--- Step 1: Add Primary Key to Customer

ALTER TABLE dim_customer
ADD PRIMARY KEY (customer_id);

--- Step 2: Product Dimension Primary Key

ALTER TABLE dim_product
ADD PRIMARY KEY (product_card_id);

--- Step 3: Date Dimension Primary Key

ALTER TABLE dim_date
ADD PRIMARY KEY (order_date_dateorders);

--- Step 4: Shipping Dimension Primary Key

ALTER TABLE dim_shipping
ADD COLUMN shipping_key INT AUTO_INCREMENT PRIMARY KEY FIRST;

--- Step 5: Location Dimension Primary Key

ALTER TABLE dim_location
ADD COLUMN location_key INT AUTO_INCREMENT PRIMARY KEY FIRST;

--- Next: Fact Table Primary Key

ALTER TABLE fact_orders
ADD PRIMARY KEY (order_item_id);

ALTER TABLE fact_orders
ADD COLUMN shipping_key INT,
ADD COLUMN location_key INT;

UPDATE fact_orders f
JOIN dim_shipping s
ON f.shipping_date_dateorders = s.shipping_date_dateorders
AND f.shipping_delay = s.shipping_delay
SET f.shipping_key = s.shipping_key;


---- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -------


USE supply_chain_analytics;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS fact_orders;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_shipping;
DROP TABLE IF EXISTS dim_location;

--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ---- 

CREATE DATABASE supply_chain_dw;
USE supply_chain_dw;
CREATE TABLE supplychain_cleaned AS
SELECT *
FROM supply_chain_analytics.supplychain_cleaned;



USE supply_chain_dw;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS fact_orders;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_shipping;
DROP TABLE IF EXISTS dim_location;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================
-- Customer Dimension
-- =========================

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_fname VARCHAR(100),
    customer_lname VARCHAR(100),
    customer_segment VARCHAR(50),
    customer_city VARCHAR(100),
    customer_state VARCHAR(50),
    customer_country VARCHAR(100),
    customer_zipcode DECIMAL(12,2)
);

INSERT INTO dim_customer
SELECT DISTINCT
    customer_id,
    customer_fname,
    customer_lname,
    customer_segment,
    customer_city,
    customer_state,
    customer_country,
    customer_zipcode
FROM supplychain_cleaned;


-- =========================
-- Product Dimension
-- =========================

CREATE TABLE dim_product (
    product_card_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category_id INT,
    category_name VARCHAR(100),
    department_id INT,
    department_name VARCHAR(100)
);

INSERT INTO dim_product
SELECT DISTINCT
    product_card_id,
    product_name,
    category_id,
    category_name,
    department_id,
    department_name
FROM supplychain_cleaned;


-- =========================
-- Date Dimension
-- =========================

CREATE TABLE dim_date (
    order_date_dateorders DATETIME PRIMARY KEY,
    order_year INT,
    order_month INT,
    order_quarter INT
);

INSERT INTO dim_date
SELECT DISTINCT
    order_date_dateorders,
    order_year,
    order_month,
    order_quarter
FROM supplychain_cleaned;


-- =========================
-- Shipping Dimension
-- Surrogate key used
-- =========================

DROP TABLE IF EXISTS dim_shipping;

CREATE TABLE dim_shipping (
    shipping_key INT AUTO_INCREMENT PRIMARY KEY,
    shipping_mode VARCHAR(100),
    shipping_date_dateorders DATETIME,
    days_for_shipping_real INT,
    days_for_shipment_scheduled INT,
    shipping_delay INT,
    delivery_status VARCHAR(100),
    delivery_performance VARCHAR(20),
    on_time_delivery VARCHAR(10),
    UNIQUE KEY uq_shipping (
        shipping_date_dateorders,
        shipping_mode,
        days_for_shipping_real,
        days_for_shipment_scheduled,
        shipping_delay,
        delivery_status,
        delivery_performance,
        on_time_delivery
    )
);

INSERT INTO dim_shipping (
    shipping_mode,
    shipping_date_dateorders,
    days_for_shipping_real,
    days_for_shipment_scheduled,
    shipping_delay,
    delivery_status,
    delivery_performance,
    on_time_delivery
)
SELECT DISTINCT
    shipping_mode,
    shipping_date_dateorders,
    days_for_shipping_real,
    days_for_shipment_scheduled,
    shipping_delay,
    delivery_status,
    delivery_performance,
    on_time_delivery
FROM supplychain_cleaned;


-- =========================
-- Location Dimension
-- Surrogate key used
-- =========================

CREATE TABLE dim_location (
    location_key INT AUTO_INCREMENT PRIMARY KEY,
    order_city VARCHAR(100),
    order_state VARCHAR(100),
    order_country VARCHAR(100),
    order_region VARCHAR(100),
    market VARCHAR(100),
    latitude DECIMAL(12,8),
    longitude DECIMAL(12,8),
    UNIQUE KEY uq_location (
        order_city,
        order_state,
        order_country,
        order_region,
        market,
        latitude,
        longitude
    )
);

INSERT INTO dim_location (
    order_city,
    order_state,
    order_country,
    order_region,
    market,
    latitude,
    longitude
)
SELECT DISTINCT
    order_city,
    order_state,
    order_country,
    order_region,
    market,
    latitude,
    longitude
FROM supplychain_cleaned;


-- =========================
-- Fact Table
-- =========================

DROP TABLE IF EXISTS fact_orders;

CREATE TABLE fact_orders (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    customer_id INT,
    product_card_id INT,
    order_date_dateorders DATETIME,
    shipping_key INT,
    location_key INT,

    sales DECIMAL(12,4),
    order_profit_per_order DECIMAL(12,4),
    order_item_quantity INT,
    order_item_discount DECIMAL(12,4),
    order_item_discount_rate DECIMAL(12,4),
    shipping_delay INT,
    delivery_performance VARCHAR(20),

    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (product_card_id) REFERENCES dim_product(product_card_id),
    FOREIGN KEY (order_date_dateorders) REFERENCES dim_date(order_date_dateorders),
    FOREIGN KEY (shipping_key) REFERENCES dim_shipping(shipping_key),
    FOREIGN KEY (location_key) REFERENCES dim_location(location_key)
);

INSERT INTO fact_orders (
    order_item_id,
    order_id,
    customer_id,
    product_card_id,
    order_date_dateorders,
    shipping_key,
    location_key,
    sales,
    order_profit_per_order,
    order_item_quantity,
    order_item_discount,
    order_item_discount_rate,
    shipping_delay,
    delivery_performance
)
SELECT
    s.order_item_id,
    s.order_id,
    s.customer_id,
    s.product_card_id,
    s.order_date_dateorders,
    sh.shipping_key,
    l.location_key,
    s.sales,
    s.order_profit_per_order,
    s.order_item_quantity,
    s.order_item_discount,
    s.order_item_discount_rate,
    s.shipping_delay,
    s.delivery_performance
FROM supplychain_cleaned s
JOIN dim_shipping sh
    ON s.shipping_date_dateorders = sh.shipping_date_dateorders
    AND s.shipping_mode = sh.shipping_mode
    AND s.days_for_shipping_real = sh.days_for_shipping_real
    AND s.days_for_shipment_scheduled = sh.days_for_shipment_scheduled
    AND s.shipping_delay = sh.shipping_delay
    AND s.delivery_status = sh.delivery_status
    AND s.delivery_performance = sh.delivery_performance
    AND s.on_time_delivery = sh.on_time_delivery
JOIN dim_location l
    ON s.order_city = l.order_city
    AND s.order_state = l.order_state
    AND s.order_country = l.order_country
    AND s.order_region = l.order_region
    AND s.market = l.market
    AND s.latitude = l.latitude
    AND s.longitude = l.longitude;
    
    SELECT COUNT(*) FROM fact_orders;


-- =========================
-- Validation
-- =========================

SELECT 'dim_customer' AS table_name, COUNT(*) AS total_rows FROM dim_customer
UNION ALL
SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL
SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL
SELECT 'dim_shipping', COUNT(*) FROM dim_shipping
UNION ALL
SELECT 'dim_location', COUNT(*) FROM dim_location
UNION ALL
SELECT 'fact_orders', COUNT(*) FROM fact_orders;

 