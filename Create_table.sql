create table food(
      food_id varchar(15) primary key,
	  item varchar(210),
	  veg_or_no_veg varchar(15)
	  
)
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

create table users(
      user_id int primary key,
	  name varchar(40),
	  age int,
	  gender varchar(10),
	  marital_status varchar(30),
	  occupation varchar(20)
)

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
create table menu(
     menu_id  varchar(30),
	 restaurant_id int,
	 food_id varchar(15),
	 cuisine varchar(100),
	 price int
)

CREATE TABLE order_type(
     order_id varchar(50) primary key,
	 type varchar(20)
)



ALTER TABLE menu
ADD CONSTRAINT fk_menu_food
FOREIGN KEY (food_id) REFERENCES food(food_id);

