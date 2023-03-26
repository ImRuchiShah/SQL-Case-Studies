use pizza_runner;

SELECT * FROM customer_orders;

# Steps to clean data:
-- Create a temporary table with all the columns
-- Remove null values in "exlusions" and "extras" columns and replace with blank space ' '.
DROP TABLE customer_orders_temp;
CREATE temporary TABLE customer_orders_temp AS
SELECT 
  order_id, 
  customer_id, 
  pizza_id, 
  CASE
	  WHEN exclusions IS null OR exclusions LIKE 'null' or exclusions LIKE "" THEN NULL
	  ELSE exclusions
	  END AS exclusions,
  CASE
	  WHEN extras IS NULL or extras LIKE 'null' OR extras LIKE "" THEN NULL
	  ELSE extras
	  END AS extras,
	order_time
FROM customer_orders;

SELECT * from customer_orders_temp;

# Pizza_names
SELECT * FROM pizza_names;

# pizza_recipes
SELECT * FROM pizza_recipes;

# pizza_toppings
SELECT * FROM pizza_toppings;

# runner_orders ,
SELECT * FROM runner_orders;

-- In pickup_time column, remove nulls and replace with blank space ' '.
-- In distance column, remove "km" and nulls and replace with blank space ' '.
-- In duration column, remove "minutes", "minute" and nulls and replace with blank space ' '.
-- In cancellation column, remove NULL and null and and replace with blank space ' '.

DROP TABLE runner_orders_temp;
CREATE TEMPORARY TABLE runner_orders_temp AS
SELECT 
  order_id, 
  runner_id,  
  CASE
	  WHEN pickup_time LIKE 'null' THEN NULL
	  ELSE pickup_time
	  END AS pickup_time,
  CASE
	  WHEN distance LIKE 'null' THEN NULL
	  WHEN distance LIKE '%km' THEN TRIM('km' from distance)
	  ELSE distance 
    END AS distance,
  CASE
	  WHEN duration LIKE 'null' THEN NULL
	  WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	  WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	  WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	  ELSE duration
	  END AS duration,
  CASE
	  WHEN cancellation IS NULL or cancellation LIKE 'null' or cancellation LIKE '' THEN NULL
	  ELSE cancellation
	  END AS cancellation
FROM runner_orders;

SELECT * from runner_orders_temp;
# Then, we alter the pickup_time, distance and duration columns to the correct data type.

ALTER TABLE runner_orders_temp
MODIFY COLUMN pickup_time DATETIME,
MODIFY COLUMN distance DECIMAL(5,1),
MODIFY COLUMN duration INT;
