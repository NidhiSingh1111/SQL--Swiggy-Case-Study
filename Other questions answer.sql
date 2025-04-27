Use swiggy_data;

# Q9. Find most loyal coustomers for all restaurant ?
SELECT restaurants.r_name, u.name, t.reg_customers
FROM (
    SELECT r_id, user_id, COUNT(*) AS reg_customers
    FROM orders
    GROUP BY r_id, user_id
) t
JOIN restaurants ON restaurants.r_id = t.r_id
JOIN users u ON u.user_id = t.user_id
WHERE (t.r_id, t.reg_customers) IN (
    SELECT r_id, MAX(reg_customers)
    FROM (
        SELECT r_id, user_id, COUNT(*) AS reg_customers
        FROM orders
        GROUP BY r_id, user_id
    ) sub
    GROUP BY r_id
)
ORDER BY restaurants.r_name;


# Q10. Month over month revenue growth of a restaurant ?
WITH Sales AS (
  SELECT 
    r_id,
    MONTHNAME(date) AS month_name, 
    MONTH(date) AS month_num, 
    SUM(amount) AS revenue
  FROM orders
  GROUP BY r_id, month_name, month_num
)

SELECT 
  restaurants.r_name,
  t.month_name,
  ROUND(((revenue - prev_rev) / prev_rev) * 100, 2) AS revenue_growth_percentage
FROM (
  SELECT 
    r_id,
    month_name,
    revenue,
    LAG(revenue, 1) OVER (PARTITION BY r_id ORDER BY month_num) AS prev_rev
  FROM Sales
) t
JOIN restaurants ON restaurants.r_id = t.r_id
WHERE prev_rev IS NOT NULL
ORDER BY restaurants.r_name, t.month_name;

#Q10. Most Paired Products
SELECT 
    restaurants.r_name AS restaurant_name,
    f1.f_name AS food_item_1,
    f2.f_name AS food_item_2,
    COUNT(*) AS times_ordered_together
FROM order_details od1
JOIN order_details od2 
  ON od1.order_id = od2.order_id 
 AND od1.f_id < od2.f_id
JOIN orders o ON o.order_id = od1.order_id
JOIN restaurants ON restaurants.r_id = o.r_id
JOIN food f1 ON f1.f_id = od1.f_id
JOIN food f2 ON f2.f_id = od2.f_id
GROUP BY restaurants.r_name, f1.f_name, f2.f_name
ORDER BY restaurant_name, times_ordered_together DESC;
