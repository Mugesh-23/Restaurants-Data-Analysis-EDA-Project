-- select * from food;
-- select * from menu;
-- select * from order_type;
-- select * from orders;
-- select * from restaurant;
-- select * from users;

-- EDA SQL Questions
-- 1, Show all restaurants with their name, city, and cuisine.

select 
     name,
	 city,
	 cuisine 
from restaurant;

-- 2, List all Veg food items
select 
     food_id,
	 item 
from food 
where veg_or_no_veg = 'Veg';

-- Find all orders where type = 'non-veg'

select * from order_type
where type = 'non-veg';

-- Display sales records where sales_amount < 0 (anomalies).

select * from orders
where sales_amount < 0;

-- Show the top 5 restaurants by rating (ignoring null values).

SELECT 
    name,
    country,
    state,
    city,
    rating
FROM restaurant
WHERE rating IS NOT NULL
ORDER BY rating desc
LIMIT 5;

-- Find the total sales amount for each restaurant.
select r.name, sum(sales_amount) as total_sales,r.state from orders as o
join restaurant as r
on o.restaurant_id = r.id
group by r.name,r.state
order by total_sales desc;

-- List all food items served by each restaurant (join menu and food).

SELECT r.name,f.item from food as f
join menu as m 
on f.food_id = m.food_id
join orders as o
on o.restaurant_id = m.restaurant_id 
join restaurant as r
on r.id = o.restaurant_id
ORDER BY r.name, f.item;

-- Show the average sales quantity per restaurant.
select * from orders;
select * from menu;

SELECT r.name as restaurant_name,ROUND(avg(sales_qty),1) as sales_amount from food as f
join menu as m 
on f.food_id = m.food_id
join orders as o
on o.restaurant_id = m.restaurant_id 
join restaurant as r
on r.id = o.restaurant_id
group by restaurant_name
ORDER BY sales_amount desc;

-- Find which restaurant(s) sell “Aloo Tikki Burger”.

SELECT DISTINCT r.id,r.name
FROM food f
JOIN menu m 
ON f.food_id = m.food_id
JOIN restaurant r 
ON m.restaurant_id = r.id
WHERE f.item = 'Aloo Tikki Burger';

-- Count the number of unique customers (user_id) per restaurant.
select r.name,COUNT(DISTINCT(u.user_id)) as user_id from users as u
join orders as o
on o.user_id = u.user_id
join restaurant as r
on r.id = o.restaurant_id
group by r.name;

-- Rank restaurants by total sales amount in descending order.

SELECT r.name, SUM(o.sales_amount) AS total_sales,
RANK() OVER (ORDER BY SUM(o.sales_amount) DESC) AS sales_rank
FROM orders AS o
JOIN restaurant AS r
ON r.id = o.restaurant_id
GROUP BY r.name
ORDER BY total_sales DESC;

-- Find the most popular food item by sales quantity.

SELECT f.item,sum(o.sales_qty) as total_qty from orders as o
JOIN menu as m
on o.restaurant_id = m.restaurant_id
JOIN food as f
on m.food_id = f.food_id
group by f.item
order by total_qty desc
limit 1;

-- Show monthly sales trends (year, month, total sales).

SELECT 
TO_CHAR(order_date, 'YYYY') AS year,
TO_CHAR(order_date, 'Month') AS month_name,
SUM(sales_amount) AS total_sales
FROM orders
GROUP BY year, month_name, EXTRACT(MONTH FROM order_date)
ORDER BY year, EXTRACT(MONTH FROM order_date);

-- Identify restaurants where the rating = 4  but rating_count = 50.

select name from restaurant
where rating = '4' and rating_count = '50+ ratings'

-- Find the Top 3 restaurants per city by sales amount using ROW_NUMBER() or RANK().

WITH city_sales AS (
SELECT r.city,r.name AS restaurant_name,
SUM(o.sales_amount) AS total_sales FROM orders o
JOIN restaurant r 
ON o.restaurant_id = r.id
GROUP BY r.city, r.name
),
ranked_sales AS (
SELECT 
city,restaurant_name,total_sales,
RANK() OVER (PARTITION BY city ORDER BY total_sales DESC) AS sales_rank
FROM city_sales
)
SELECT *
FROM ranked_sales
WHERE sales_rank <= 3
ORDER BY city, sales_rank;

## ERD diagram

![Restaurant ERD](images/diagram.png)





