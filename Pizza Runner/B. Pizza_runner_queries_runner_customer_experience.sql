# B. Runner and Customer Experience

USE pizza_runner;

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
	runner_id,
	registration_date,
    FLOOR(((datediff(registration_date, '2021-01-01') /7)+1)) as start_of_week,
	COUNT(runner_id) as Total_runners
FROM runners
GROUP BY start_of_week;

-- Output:
-- 1	2021-01-01	1	2
-- 3	2021-01-08	2	1
-- 4	2021-01-15	3	1

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT
	runner_id,
	round(avg(timestampdiff(minute,order_time, pickup_time)),1) as Average_time
FROM 
	runner_orders
    JOIN customer_orders
		ON runner_orders.order_id = customer_orders.order_id
GROUP by runner_id;

-- Output:
-- 1	15.3
-- 2	23.4
-- 3	10.0

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT
	 customer_orders_temp.order_id,
    COUNT(pizza_id) as pizzas,
    AVG(timestampdiff(minute, order_time, pickup_time)) as time
FROM 
	customer_orders_temp
    JOIN runner_orders_temp
		ON customer_orders_temp.order_id = runner_orders_temp.order_id
GROUP BY customer_orders_temp.order_id
ORDER BY pizzas DESC;

-- output:
-- 4	3	29.0000
-- 3	2	21.0000
-- 10	2	15.0000
-- 1	1	10.0000
-- 2	1	10.0000
-- 5	1	10.0000
-- 6	1	
-- 7	1	10.0000
-- 8	1	20.0000
-- 9	1	

-- 4. What was the average distance travelled for each customer?
SELECT customer_id,
	ROUND(AVG(distance),1) as distance_travelled
FROM runner_orders_temp
	JOIN customer_orders_temp
    ON runner_orders_temp.order_id = customer_orders_temp.order_id
WHERE distance != 0
GROUP BY customer_id;

-- Output:
-- 101	20.0
-- 102	16.7
-- 103	23.4
-- 104	10.0
-- 105	25.0

-- 5. What was the difference between the longest and shortest delivery times for all orders?
WITH diff_time as
(
SELECT
	customer_orders_temp.order_id,
    timestampdiff(minute, order_time, pickup_time) as delivery_time
FROM runner_orders_temp
	JOIN customer_orders_temp
    ON runner_orders_temp.order_id = customer_orders_temp.order_id
WHERE distance != 0
)
SELECT 
    MAX(delivery_time) - MIN(delivery_time) as max_time
FROM 
	diff_time;

-- Output
-- 19 

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
	runner_id,
    order_id,
    distance,
    duration,
    Round(AVG(distance/duration*60),1) as speed
FROM runner_orders_temp
WHERE distance <> 'null'
GROUP BY runner_id, order_id, distance, duration;

-- Output
-- 1	1	20	32 	37.5
-- 1	2	20	27 	44.4
-- 1	3	13.4	20 	40.2
-- 2	4	23.4	40	35.1
-- 3	5	10	15	40.0
-- 2	7	25	25	60.0
-- 2	8	23.4 	15 	93.6
-- 1	10	10	10	60.0


-- 7. What is the successful delivery percentage for each runner?
SELECT 
  runner_id, 
  ROUND(100 * SUM(
					CASE WHEN distance = 0 THEN 0 ELSE 1 END) / COUNT(*), 0) AS success_perc
FROM runner_orders
GROUP BY runner_id;

-- OUTPUT
-- 1	100
-- 2	75
-- 3	50