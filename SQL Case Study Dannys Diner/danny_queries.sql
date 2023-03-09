# 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id,
		sum(price) as total_amount_spent
FROM sales
join menu ON
	sales.product_id = menu.product_id
GROUP BY customer_id;

-- Output:
-- 	customer_id	total_amount_spent
-- 	A			76
-- 	B			74
-- 	C			36

# 2. How many days has each customer visited the restaurant?
SELECT customer_id,
		count(distinct order_date) as days
FROM sales
GROUP BY customer_id;

-- Output:
-- A	4
-- B	6
-- C	2

# 3. What was the first item from the menu purchased by each customer?
WITH first_item_cte AS
(
SELECT customer_id,
	order_date,
    product_name,
    DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rank1
FROM sales 
JOIN menu ON
	sales.product_id = menu.product_id
)

SELECT customer_id, product_name
FROM first_item_cte
WHERE rank1 = 1
GROUP BY customer_id, product_name;

-- Output:
-- A	sushi
-- A	curry
-- B	curry
-- C	ramen

# 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

CREATE temporary TABLE most_purchased_item
SELECT sales.product_id,
		product_name,
		COUNT(product_name) as total_purchases
FROM sales
JOIN menu ON
	sales.product_id = menu.product_id
GROUP BY sales.product_id
ORDER BY total_purchases DESC;

SELECT product_name, max(total_purchases) from most_purchased_item;

-- Output:
-- ramen	8

# 5. Which item was the most popular for each customer?
WITH most_popular_item AS
(
SELECT customer_id,
		product_name,
        count(product_name) as total_purchases,
          DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(customer_id) DESC) AS rank1
FROM sales
JOIN menu ON
	sales.product_id = menu.product_id
GROUP BY customer_id, product_name
)

SELECT customer_id,
	product_name,
	total_purchases
FROM most_popular_item
where rank1=1;

-- Output:
-- A	ramen	3
-- B	curry	2
-- B	sushi	2
-- B	ramen	2
-- C	ramen	3

# 6. Which item was purchased first by the customer after they became a member?
SELECT members.customer_id,
	join_date,
	product_id 
FROM members
JOIN sales ON
	members.customer_id = sales.customer_id
GROUP BY customer_id;


# 7. Which item was purchased just before the customer became a member?
WITH join_order AS
(
SELECT members.customer_id,
	join_date,
    order_date,
    product_id,
    DENSE_RANK() OVER(partition by customer_id ORDER BY order_date) as rank1
FROM members
JOIN sales
	ON members.customer_id = sales.customer_id
WHERE order_date<join_date
)

SELECT 
	customer_id,
	join_date,
    order_date,
    product_name
FROM join_order
JOIN menu 
	ON join_order.product_id = menu.product_id
where rank1=1;

-- Output:
-- A	2021-01-07	2021-01-01	sushi
-- A	2021-01-07	2021-01-01	curry
-- B	2021-01-09	2021-01-01	curry

# 8. What is the total items and amount spent for each member before they became a member?
WITH before_join_items AS
(
SELECT members.customer_id,
	join_date,
    order_date,
    product_id
FROM members
JOIN sales
	ON members.customer_id = sales.customer_id
WHERE order_date<join_date
)
SELECT customer_id,
	COUNT(before_join_items.product_id) AS total_items,
    SUM(price) AS total_amount
FROM before_join_items
JOIN menu
	ON before_join_items.product_id = menu.product_id
GROUP BY customer_id;

-- Output:
-- A	2	25
-- B	3	40

# 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH total_points AS
(
SELECT 
	customer_id, 
    sales.product_id,
    menu.price,
     CASE
			WHEN sales.product_id = 1 THEN price * 20
			ELSE price * 10
	END AS points
FROM sales
JOIN menu
	ON sales.product_id = menu.product_id
)

SELECT customer_id, 
		SUM(points)
FROM total_points
GROUP BY customer_id;
    
-- Output:
-- A	860
-- B	940
-- C	360

# 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH dates AS 
(
   SELECT *, 
      DATE_ADD(join_date, INTERVAL 6 DAY) AS valid_date, 
      LAST_DAY('2021-01-31') AS last_date
   FROM members 
)
SELECT S.Customer_id, 
	SUM( CASE 
	  WHEN m.product_ID = 1 THEN m.price*20
	  WHEN S.order_date BETWEEN D.join_date AND D.valid_date THEN m.price*20
	  ELSE m.price*10
	  END 
	  ) AS Points
FROM Dates D
JOIN Sales S
ON D.customer_id = S.customer_id
JOIN Menu M
ON M.product_id = S.product_id
WHERE S.order_date < d.last_date
GROUP BY S.customer_id;

-- Output:
-- A	1370
-- B	820

-- Join All The Things
-- Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)

SELECT 
  sales.customer_id, 
  sales.order_date, 
  menu.product_name, 
  menu.price,
  CASE WHEN members.join_date > sales.order_date THEN 'N'
	  WHEN members.join_date <= sales.order_date THEN 'Y'
	  ELSE 'N' 
  END AS member
FROM sales
LEFT JOIN menu
	ON sales.product_id = menu.product_id
LEFT JOIN members 
	ON sales.customer_id = members.customer_id
ORDER BY sales.customer_id, sales.order_date;

-- Rank All The Things
-- Recreate the table with: customer_id, order_date, product_name, price, member (Y/N), ranking(null/123)
WITH summary_cte as
(
SELECT 
  sales.customer_id, 
  sales.order_date, 
  menu.product_name, 
  menu.price,
  CASE WHEN members.join_date > sales.order_date THEN 'N'
	  WHEN members.join_date <= sales.order_date THEN 'Y'
	  ELSE 'N' 
  END AS member
FROM sales
LEFT JOIN menu
	ON sales.product_id = menu.product_id
LEFT JOIN members 
	ON sales.customer_id = members.customer_id
ORDER BY sales.customer_id, sales.order_date
)
SELECT 
  *,
	CASE WHEN member = 'N' then NULL
    ELSE
			RANK () OVER(PARTITION BY customer_id, member ORDER BY order_date) 
		END AS ranking
FROM summary_cte;


-- Output:
-- A	2021-01-01	sushi	10	N	
-- A	2021-01-01	curry	15	N	
-- A	2021-01-07	curry	15	Y	1
-- A	2021-01-10	ramen	12	Y	2
-- A	2021-01-11	ramen	12	Y	3
-- A	2021-01-11	ramen	12	Y	3
-- B	2021-01-01	curry	15	N	
-- B	2021-01-02	curry	15	N	
-- B	2021-01-04	sushi	10	N	
-- B	2021-01-11	sushi	10	Y	1
-- B	2021-01-16	ramen	12	Y	2
-- B	2021-02-01	ramen	12	Y	3
-- C	2021-01-01	ramen	12	N	
-- C	2021-01-01	ramen	12	N	
-- C	2021-01-07	ramen	12	N	