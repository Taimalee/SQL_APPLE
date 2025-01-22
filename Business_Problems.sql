-- EDA
SELECT * FROM categories; 
SELECT * FROM customers;
SELECT * FROM inventory;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM payments;
SELECT * FROM products;
SELECT * FROM sellers;
SELECT * FROM shipping;



SELECT * 
FROM shipping
WHERE order_id = 34


-- order_id = 22

SELECT *
FROM orders
WHERE order_id = 22 -- 2024-09-10

SELECT * 
FROM payments
WHERE order_id = 22

SELECT * 
FROM shipping
WHERE order_id = 22

-- EDA END


-- ----------------------------
-- Business Problems 
-- Advance Analysis 
-- ----------------------------


/*
Question 1: 
			Query the top 10 products by total sales value. 
Challenge: 	Include product name, total quantity sold, and total sales value.
*/

SElECT
	p.product_id,
	p.product_name, 
	TO_CHAR(SUM(oi.quantity), 'FM999,999,999,990.00') as Quantity, 
	TO_CHAR(SUM(oi.total_price), 'FM999,999,999,990.00') as Total_Sales_Value
FROM order_items as oi
JOIN products as p ON oi.product_id = p.product_id
JOIN orders as o ON oi.order_id = o.order_id
WHERE o.order_status = 'completed'
GROUP BY p.product_name, p.product_id
ORDER BY Total_Sales_Value DESC
LIMIT 10;









/*
Question 2: 
			Query the top 10 products by total sales value. 
Challenge: 	Include product name, total quantity sold, and total sales value.
*/


