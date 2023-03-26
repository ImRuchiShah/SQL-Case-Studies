use pizza_runner;
-- A. Pizza Metrics
-- 1. How many pizzas were ordered?

SELECT 
	COUNT((pizza_id)) AS no_of_pizzas_ordered
FROM customer_orders;

-- Output:
-- 14

-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT(order_id))
	FROM customer_orders;

-- Output:
-- 10

-- 3. How many successful orders were delivered by each runner?

SELECT * FROM runner_orders_temp;
SELECT runner_id, 
	COUNT(order_id) 
	FROM runner_orders_temp
		WHERE cancellation IS NULL
    GROUP BY runner_id;

-- Output:
-- 1	4
-- 2	3
-- 3	1

-- 4. How many of each type of pizza was delivered?
SELECT pizza_name, 
	COUNT(customer_orders_temp.pizza_id) as total_pizzas
 from pizza_names
	JOIN customer_orders_temp
		ON pizza_names.pizza_id = customer_orders_temp.pizza_id
	JOIN runner_orders_temp
		ON runner_orders_temp.order_id = customer_orders_temp.order_id
WHERE cancellation IS NULL
	 GROUP BY pizza_name;
	
-- Output:
-- Meatlovers	9
-- Vegetarian	3

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id,
	COUNT( CASE 
		WHEN pizza_name ='Meatlovers' THEN pizza_name 
	END) AS Total_Meatlovers,
	COUNT( CASE
		WHEN pizza_name ='Vegetarian' THEN pizza_name
	END) AS Total_Vegetarian
FROM customer_orders_temp
	JOIN pizza_names
		ON customer_orders_temp.pizza_id = pizza_names.pizza_id
GROUP BY customer_id;

-- Output
-- 101	2	1
-- 102	2	1
-- 103	3	1
-- 104	3	0
-- 105	0	1

-- 6. What was the maximum number of pizzas delivered in a single order?

WITH max_pizza as
(
SELECT 
	customer_orders_temp.order_id,
    COUNT(pizza_id) as total_pizzas
FROM customer_orders_temp
JOIN runner_orders
	ON runner_orders.order_id = customer_orders_temp.order_id
WHERE cancellation IS NULL
GROUP BY order_id
ORDER BY total_pizzas DESC
) 
SELECT order_id ,
	MAX(total_pizzas) as total_pizza_order
	FROM max_pizza;

-- OUTPUT:
-- 4	3

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
	customer_id,
	COUNT(CASE WHEN exclusions IS NOT NULL or extras IS NOT NULL THEN customer_orders_temp.order_id END) AS changes,
    COUNT(CASE WHEN exclusions IS NULL AND extras IS NULL THEN customer_orders_temp.order_id END) AS no_changes
FROM customer_orders_temp
JOIN runner_orders_temp
	ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE cancellation IS NULL
GROUP BY customer_id;

-- OUTPUT:
-- 101	0	2
-- 102	0	3
-- 103	3	0
-- 104	2	1
-- 105	1	0

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT 
	COUNT(pizza_id)
FROM customer_orders_temp
JOIN runner_orders_temp
	ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE cancellation IS NULL AND 
		exclusions IS NOT NULL AND extras IS NOT NULL;
-- Output
-- 1

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT
	HOUR(order_time) as hour_of_the_day,
    COUNT(pizza_id)
FROM 
	customer_orders_temp
GROUP BY hour_of_the_day
ORDER BY hour_of_the_day;

-- output
-- 11	1
-- 13	3
-- 18	3
-- 19	1
-- 21	3
-- 23	3

-- 10. What was the volume of orders for each day of the week?
SELECT
	DAYOFWEEK(order_time) as day_of_Week,
    DAYNAME(order_time) as Week_name,
    COUNT(order_id)
FROM 
	customer_orders_temp
GROUP BY day_of_Week
ORDER BY day_of_Week;
