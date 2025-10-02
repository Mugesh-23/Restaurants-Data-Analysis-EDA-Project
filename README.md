## Restaurants Data Analysis & EDA Project


## 1. Project Introduction

- Dataset: Restaurants, Menu, Orders, Food Items

- Goal: Clean, explore, and analyze restaurant performance trends by sales, cuisine, food type, location, and customer patterns.

- Tools: PostgreSQL, Microsoft Excel, Power BI

## 2. Data Cleaning Steps

- Remove duplicate restaurant, order, and menu records

- Handle missing values in rating, sales_amount, and cuisine columns

- Replace invalid sales values (e.g., negative sales amounts) with NULL

- Standardize categorical fields like cuisine, veg_or_non_veg, and order type

- Trim and clean text fields (name, city, address) for consistency

## 3.  Database Setup

- **Database Creation**: Created a Restaurant
- **Table Creation**: Created tables for food
```sql
create table food(
      food_id varchar(15) primary key,
	  item varchar(210),
	  veg_or_no_veg varchar(15)
	  
)
```
- menu 
```sql
create table menu(
     menu_id  varchar(30),
	 restaurant_id int,
	 food_id varchar(15),
	 cuisine varchar(100),
	 price int
)
```
- orders_type
```sql
CREATE TABLE order_type(
     order_id varchar(50) primary key,
	 type varchar(20)
)
```
- orders
```sql
create table orders(
      order_date DATE,
	  sales_qty int,
	  sales_amount	int,
	  currency	varchar(10),
	  user_id int,	
	  restaurant_id int,
      FOREIGN KEY (user_id) REFERENCES users(user_id),
	  FOREIGN KEY (restaurant_id) REFERENCES restaurant(id)
)
```
- restaurant
```sql
create table restaurant(
      id int primary key,
	  name varchar(80),
	  country varchar(10),
	  city varchar(50),
	  state varchar(80),
	  rating varchar(10),
	  rating_count varchar(20),
	  cuisine varchar(70),
	  pincode int,
	  link varchar(250),
	  address varchar(260)
)

copy restaurant(id, name, country, city,state, rating, rating_count, cuisine,pincode, link, address)
FROM 'D:/Retail-Sales-Analysis-SQL-Project--P1-main/Restaurant_Data_Analysis_Project/Restaurant_DAP/restaurant.csv'
DELIMITER ','
CSV HEADER QUOTE '"'
NULL '';
```
- users
```sql
create table users(
      user_id int primary key,
	  name varchar(40),
	  age int,
	  gender varchar(10),
	  marital_status varchar(30),
	  occupation varchar(20)
)
```

- Alter table  menu
```sql 
ALTER TABLE menu
ADD CONSTRAINT fk_menu_food
FOREIGN KEY (food_id) REFERENCES food(food_id);
```

## 4. Exploratory Data Analysis (EDA)

1, Show all restaurants with their name, city, and cuisine.
```sql
select 
     name,
	 city,
	 cuisine 
from restaurant;
```
2,List all Veg food items
```sql
select 
     food_id,
	 item 
from food 
where veg_or_no_veg = 'Veg';
```
3,Find all orders where type = 'non-veg'
```sql
select * from order_type
where type = 'non-veg';
```
4,Display sales records where sales_amount < 0 (anomalies).
```sql
select * from orders
where sales_amount < 0;
```
5,Show the top 5 restaurants by rating (ignoring null values).
```sql
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
```
6,Find the total sales amount for each restaurant.
```sql
select r.name, sum(sales_amount) as total_sales,r.state from orders as o
join restaurant as r
on o.restaurant_id = r.id
group by r.name,r.state
order by total_sales desc;
```
7,List all food items served by each restaurant (join menu and food).
```sql
SELECT r.name,f.item from food as f
join menu as m 
on f.food_id = m.food_id
join orders as o
on o.restaurant_id = m.restaurant_id 
join restaurant as r
on r.id = o.restaurant_id
ORDER BY r.name, f.item;
```
8,Show the average sales quantity per restaurant.
```sql
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
```
9,Find which restaurant(s) sell “Aloo Tikki Burger”.
```sql
SELECT DISTINCT r.id,r.name
FROM food f
JOIN menu m 
ON f.food_id = m.food_id
JOIN restaurant r 
ON m.restaurant_id = r.id
WHERE f.item = 'Aloo Tikki Burger';
```
10,-- Count the number of unique customers (user_id) per restaurant.
```sql
select r.name,COUNT(DISTINCT(u.user_id)) as user_id from users as u
join orders as o
on o.user_id = u.user_id
join restaurant as r
on r.id = o.restaurant_id
group by r.name;
```
11,Rank restaurants by total sales amount in descending order.
```sql
SELECT r.name, SUM(o.sales_amount) AS total_sales,
RANK() OVER (ORDER BY SUM(o.sales_amount) DESC) AS sales_rank
FROM orders AS o
JOIN restaurant AS r
ON r.id = o.restaurant_id
GROUP BY r.name
ORDER BY total_sales DESC;
```
12,Find the most popular food item by sales quantity.
```sql
SELECT f.item,sum(o.sales_qty) as total_qty from orders as o
JOIN menu as m
on o.restaurant_id = m.restaurant_id
JOIN food as f
on m.food_id = f.food_id
group by f.item
order by total_qty desc
limit 1;
```
13,Show monthly sales trends (year, month, total sales).
```sql
SELECT 
TO_CHAR(order_date, 'YYYY') AS year,
TO_CHAR(order_date, 'Month') AS month_name,
SUM(sales_amount) AS total_sales
FROM orders
GROUP BY year, month_name, EXTRACT(MONTH FROM order_date)
ORDER BY year, EXTRACT(MONTH FROM order_date);
```
14,Find the Top 3 restaurants per city by sales amount using ROW_NUMBER() or RANK().

```sql
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
```


## 5, ERD diagram
![Restaurant ERD](/Entity%20Diagram.png)

## 6, Power BI Dashboard
![Restaurant Dashboard](/DashBoard.png)


## 7, Insights / Findings

- Some restaurants bring in much higher sales revenue than others.

- Veg items are common on the menu, but non-veg orders are in strong demand.

- Certain cuisines, like Beverages and Fast Food, consistently generate sales across multiple restaurants.

- A few restaurants have negative or invalid sales entries, which may indicate data entry mistakes.

- Customer loyalty is higher at select restaurants, showing repeat behavior.

- Restaurants with better ratings do not always have the highest sales, highlighting a gap between popularity and revenue.

## 8,Conclusion

- Restaurants with strong sales are not always the ones with the highest ratings. 

- Certain cuisines, like Beverages and Fast Food, dominate customer demand in the city. 

- Non-veg orders make up a significant share, even though they have fewer items than veg options. 

- Sales data shows anomalies, including negative values, which point to the need for better data validation. 

- Customer behavior indicates that people make repeat visits to a few key restaurants, suggesting strong loyalty patterns.



