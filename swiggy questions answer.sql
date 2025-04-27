Use swiggy_data;

#  Q1. Find customers who never ordered ?
SELECT name
FROM users 
WHERE user_id not in(select user_id from orders);

# Q2. Find Average Price or dish ?
SELECT food.f_name, AVG(menu.price) AS Avg_Price
FROM menu 
JOIN food 
ON menu.f_id = food.f_id
GROUP BY food.f_name
ORDER BY Avg_Price desc;

# Q3. Find top restaurant in terms of number of orders for a given month?(assume month is june)
SELECT restaurants.r_name,COUNT(*) AS Month_order 
FROM orders
JOIN restaurants
ON orders.r_id = restaurants.r_id
WHERE MONTHNAME(date) like 'June'
GROUP BY restaurants.r_name
ORDER BY Month_order desc limit 1;

# Q4. Find restaurants with monthly sales is greater than x ?(Assume x be 500, Assume month be June)
SELECT orders.r_id,restaurants.r_name,SUM(amount) as revenue
FROM orders
JOIN restaurants
ON orders.r_id = restaurants.r_id
WHERE MONTHNAME(date) like 'June'
GROUP BY orders.r_id,restaurants.r_name
HAVING revenue >500;

# Q5. Show all orders with orders details for a particular customer in a particular data range?(Assume data range 10th June to 10th July)
SELECT orders.order_id, restaurants.r_name ,food.f_name 
FROM orders
JOIN restaurants
ON restaurants.r_id = orders.r_id 
JOIN order_details
ON orders.order_id = order_details.order_id
JOIN food
ON food.f_id= order_details.f_id
WHERE user_id =(select user_id from users where name like 'Ankit')
AND date between '2022-06-10' and '2022-07-10';

# Q6. Find restaurants with maxmium repeated customers ?
SELECT restaurants.r_name,COUNT(*) as loyal_customers 
FROM (
SELECT r_id,user_id,COUNT(*) AS reg_customers FROM orders
GROUP BY r_id,user_id
HAVING reg_customers>1
) t
JOIN restaurants
ON restaurants.r_id = t.r_id
GROUP BY restaurants.r_name 
ORDER BY loyal_customers desc limit 1;

# Q7. Find Month over month revenue growth of swiggy ? 
SELECT month_name,((revenue-prev_rev)/prev_rev)*100
FROM (
WITH Sales AS 
(
SELECT MONTHNAME(date) as month_name, MONTH(date) as month_num ,SUM(amount) as revenue 
FROM orders
GROUP BY month_name, month_num
ORDER BY month_num
)

SELECT month_name,revenue ,LAG(revenue,1) over(order by revenue) as prev_rev 
FROM Sales) t;

# Q8. Find each customer favourite food ?
WITH temp 
as (
SELECT orders.user_id,order_details.f_id,COUNT(*) as frequency 
FROM orders
JOIN order_details
ON orders.order_id= order_details.order_id
GROUP BY orders.user_id,order_details.f_id
)

SELECT users.name,food.f_name,t1.frequency from temp t1 
JOIN users 
ON users.user_id= t1.user_id
JOIN food
ON food.f_id = t1.f_id
WHERE t1.frequency = (SELECT Max(frequency) from temp t2 WHERE t2.user_id= t1.user_id
);


