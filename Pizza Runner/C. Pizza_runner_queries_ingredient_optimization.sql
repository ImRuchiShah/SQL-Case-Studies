-- C. Ingredient Optimisation
use pizza_runner;

-- 1. What are the standard ingredients for each pizza?

WITH cte_split(topping_id, split_values, topping_name) AS
(
     SELECT
        topping_id,
        LEFT(topping_name, CHARINDEX(',', topping_name + ',') - 1) as 'split_values',
        STUFF(topping_name, 1, CHARINDEX(',', topping_name + ','), '')
    FROM pizza_toppings

   UNION ALL

    -- recursive member
    SELECT
        topping_id,
        LEFT(topping_name, CHARINDEX(',', topping_name + ',') - 1),
        STUFF(topping_name, 1, CHARINDEX(',', topping_name + ','), '')
    FROM cte_split
    -- termination condition
    WHERE topping_name > ''
)
-- use the CTE and generate the final result set
SELECT topping_id, split_values
FROM cte_split
ORDER BY id;




-- 2. What was the most commonly added extra?


-- 3. What was the most common exclusion?


-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
--  Meat Lovers
--  Meat Lovers - Exclude Beef
--  Meat Lovers - Extra Bacon
--  Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers


-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"



-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

