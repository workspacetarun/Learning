-- -------------------Section A: Pizza Metrics -------------------------------------------

select * from customer_orders;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;
select * from runner_ocrders;
select * from runners;

-- Cleaning Different Tables
SET SQL_SAFE_UPDATES = 0; -- Removing Safe Update Mode in MySQL
-- Using Update statement to Clean Different Tables
UPDATE runner_orders
set duration = NULL
WHERE  duration = 'null';
-- ------------------------------ Start ------------------------------------------------

-- Q 1: How many pizzas were ordered?
select count(*) as total_orders from customer_orders;

-- Q 2:How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS total_unique_orders FROM customer_orders;

-- Q 3:How many successful orders were delivered by each runner?
SELECT  runner_id, count(order_id) AS successful_delivery 
FROM runner_orders 
WHERE distance NOT LIKE 'null'  
GROUP BY runner_id;

-- Q 4: How many of each type of pizza was delivered?
SELECT pn.pizza_name, COUNT(ro.order_id) as delivery_count
FROM runner_orders AS ro
INNER JOIN customer_orders AS co
ON ro.order_id = co.order_id
LEFT JOIN pizza_names pn 
ON co.pizza_id=pn.pizza_id
WHERE distance NOT LIKE 'null'
GROUP BY pn.pizza_name;

-- Q 5: How many Vegetarian and Meatlovers were ordered by each customer?
SELECT  pn.pizza_name, customer_id, count(co.pizza_id) AS pizza_ordered
FROM customer_orders AS co
JOIN pizza_names as pn
ON co.pizza_id = pn.pizza_id
GROUP BY 1,2
ORDER BY 1,2;

-- Q 6: What was the maximum number of pizzas delivered in a single order?
SELECT ro.order_id, count(pizza_id) AS biggest_order
FROM runner_orders ro
INNER JOIN customer_orders co
ON ro.order_id=co.order_id
WHERE ro.distance NOT LIKE 'null'
GROUP BY ro.order_id
ORDER BY biggest_order desc LIMIT 1;

-- Q 7: For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT customer_id, 
CASE WHEN co.exclusions IS NULL AND co.extras IS NULL THEN 'No Change'
ELSE 'Change'
END AS 'change_tracker', count(*) as count_tracker 
FROM  customer_orders co
JOIN runner_orders ro
ON co.order_id=ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY 1,2
ORDER BY count_tracker desc;

-- Q 8: How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(*) pizza_with_both_changes
FROM  customer_orders co
JOIN runner_orders ro
ON co.order_id=ro.order_id
WHERE ro.cancellation IS NULL
AND exclusions IS NOT NULL
AND extras IS NOT NULL;

-- Q 9: What was the total volume of pizzas ordered for each hour of the day?
SELECT
HOUR(order_time) AS hour_of_day, 
count(*) AS pizza_ordered
FROM customer_orders
GROUP BY 1
ORDER BY 1;

-- Q 10: What was the volume of orders for each day of the week?
SELECT dayname(order_time) AS day_of_week,
COUNT(*) AS pizza_ordered
FROM customer_orders
GROUP BY 1
ORDER BY 2 desc;

-- ----------------------------------- END ------------------------------------------

-- ---------------------- Code to Create Tables in MySQL ----------------------------

CREATE SCHEMA pizza_runner;
USE pizza_runner;

CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  (1, 101, 1, '', '', '2020-01-01 18:05:02'),
  (2, 101, 1, '', '', '2020-01-01 19:00:52'),
  (3, 102, 1, '', '', '2020-01-02 23:51:23'),
  (3, 102, 2, '', NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 2, '4', '', '2020-01-04 13:23:46'),
  (5, 104, 1, 'null', '1', '2020-01-08 21:00:29'),
  (6, 101, 2, 'null', 'null', '2020-01-08 21:03:13'),
  (7, 105, 2, 'null', '1', '2020-01-08 21:20:29'),
  (8, 102, 1, 'null', 'null', '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2020-01-10 11:22:59'),
  (10, 104, 1, 'null', 'null', '2020-01-11 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, 'null', 'null', 'null', 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  (9, 2, 'null', 'null', 'null', 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

