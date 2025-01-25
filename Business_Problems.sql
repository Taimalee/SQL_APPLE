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
Question 1: Top Selling Products
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
Question 2: Revenue by Category
			Calculate the total revenue generated by each product category. 
Challenge: 	Include the percentage contribution of each category to total revenue.
*/



SELECT 
	c.category_id,
	c.category_name,
	TO_CHAR(SUM(oi.total_price), 'FM999,999,999,999.00') as Total_Revenue,
	TO_CHAR(SUM(oi.total_price) / 
			(SELECT SUM(total_price) FROM order_items) * 100, 'FM999,990.00%')
			as Percentage

FROM products as p
JOIN order_items as oi ON p.product_id = oi.product_id
JOIN categories as c ON p.category_id = c.category_id
GROUP BY c.category_name, c.category_id
ORDER BY Total_Revenue DESC;



/*
Question 3: Average Order Value (AOV)
			Calculate the average order value for each customer. 
Challenge: 	Include only customers with more than 100 orders.
*/



SELECT 
	cs.customer_id as Customer_id,
	CONCAT(cs.first_name, ' ',cs.last_name) as Customer,
	COUNT (DISTINCT(o.order_id)) as num_orders,
	TO_CHAR(SUM(oi.total_price)/
	COUNT(DISTINCT(o.order_id)), 'FM999,999,999,999.00') as AOV
	
FROM orders as o
JOIN customers as cs ON o.customer_id =cs.customer_id
JOIN order_items as oi ON o.order_id = oi.order_id
GROUP BY 1,2
HAVING COUNT (DISTINCT(o.order_id))  > 35
ORDER BY AOV DESC;



/*
Question 4: Monthly Sales Trend
			Query monthly total sales over the past year. 
Challenge: 	Display the sales trend, grouping by month, 
			return current month sales, last month sales.
*/



SELECT 	
	year,
	month,
	total_sale as current_month_sale,
	LAG(total_sale, 1) OVER(ORDER BY year, month) as last_month_sale
	
FROM
(
	SELECT 
	EXTRACT(MONTH FROM o.order_date) as month, 
	EXTRACT(YEAR FROM o.order_date) as year,
	TO_CHAR(SUM(oi.total_price), 'FM999,999,999.00') as total_sale

	FROM orders as o
	JOIN order_items as oi ON o.order_id = oi.order_id
	WHERE o.order_date >= CURRENT_DATE - INTERVAL '1 year'
	GROUP BY 1,2
	ORDER BY year, month 
) as MST_



/*
Question 5: Customers with No Purchases
			Find cusotmers in our database who have never placed an order.
Challenge: 	Include customer details.
*/



SELECT * 
FROM customers
WHERE customer_id NOT IN 
	(
	SELECT DISTINCT(customer_id) 
	FROM orders
	);

	

/*
Question 6: Top-Selling Province for Each Category
			Identify the top-selling province for each product category. 
Challenge: 	Include the total sales for that category within the province.
*/



WITH rank_table
AS
	(
	SELECT 
		cs.province, 
		c.category_name,
		TO_CHAR(SUM(oi.total_price), 'FM999,999,999,999.00') as Total_sales,
		RANK() OVER(PARTITION BY c.category_name ORDER BY 
		TO_CHAR(SUM(oi.total_price), 'FM999,999,999,999.00') DESC) as rank
	FROM orders as o
	JOIN customers as cs ON o.customer_id = cs.customer_id
	JOIN order_items as oi ON o.order_id = oi.order_id
	JOIN products as p ON p.product_id = oi.product_id
	JOIN categories c ON p.category_id = c.category_id
	WHERE o.order_status = 'completed'
	GROUP BY 1,2
	)
	
SELECT * 
FROM rank_table
WHERE rank = 1;



/*
Question 7: Customer Lifetime Value (CLTV)
			Calculate the total value of orders placed by each customer over their lifetime.
Challenge: 	Rank customers based on their CLTV and displat the top 10
*/



SELECT 
	cs.customer_id as Customer_id,
	CONCAT(cs.first_name, ' ',cs.last_name) as Customer,
	cs.province,
	TO_CHAR(SUM(oi.total_price), 'FM999,999,999,999.00') as CLTV,
	DENSE_RANK() OVER(ORDER BY 
	TO_CHAR(SUM(oi.total_price), 'FM999,999,999,999.00') DESC) as cs_rank
	
FROM orders as o
JOIN customers as cs ON o.customer_id =cs.customer_id
JOIN order_items as oi ON o.order_id = oi.order_id
GROUP BY 1,2
LIMIT 10;



/*
Question 8: Inventory Stock Alerts
			Query products with stock levels below a certain threshold 
			(e.g., less than 50 units).
Challenge: 	Include the restock date and warehouse information
*/



SELECT 
	i.inventory_id, 
	i.stock_remaining, 
	i.restock_date,
	i.warehouse_id,
	p.product_name

FROM inventory as i
JOIN products as p ON i.product_id = p.product_id
WHERE i.stock_remaining < 50;



/*
Question 9: Shipping Information
			Identify in-progress orders where the shipping date is later than 3 days
			after the order date.
Challenge: 	Include customer, order details, and delivery provider.
*/



SELECT 
	cs.customer_id as Customer_id,
	CONCAT(cs.first_name, ' ',cs.last_name) as Customer,
	cs.province,
	o.order_status,
	o.order_date,
	s.shipping_date,
	s.shipping_provider

FROM customers cs 
JOIN orders o ON cs.customer_id = o.customer_id
JOIN shipping s ON o.order_id = s.order_id
WHERE s.shipping_date - order_date > 3 
	AND o.order_status = 'inprogress';



/*
Question 10: Payment Success Rate
			Calculate the percentage of successful payments across all orders.
Challenge: 	Include breakdowns by payment status.
*/



SELECT 
	py.payment_status, 
	COUNT(*) as total_num,
	TO_CHAR(COUNT(*)/
		(SELECT COUNT(*)FROM payments)::"numeric" * 100, 'FM999,999,999.00%')
		as percentage
	
FROM orders o
JOIN payments py ON o.order_id = py.order_id
GROUP BY py.payment_status



/*
Question 11: Stored Procedure (Identify the Top Sellers by Sales Volume)
			Identify the top N sellers (based on total sales volume) for a specified date range.
Challenge: 	Create a stored procedure that accepts the start date, end date, 
           	and number of top sellers (N) as input parameters. 
           	Return the top N sellers along with their total sales volume 
           	within the specified date range.
*/



CREATE OR REPLACE FUNCTION get_top_sellers_by_sales
	(
    start_date DATE,
    end_date DATE,
    top_n INT
	)
RETURNS TABLE 
	(
    seller_id INT,
    seller_name TEXT,
    origin TEXT,
   	total_sales TEXT
	) AS $$
	
BEGIN
    RETURN QUERY
    SELECT 
        s.seller_id,
        s.seller_name::"text",
        s.origin::"text",
        TO_CHAR(SUM(oi.total_price)::NUMERIC, 'FM999,999,999.00') AS total_sales  
    FROM sellers s
    JOIN orders o ON s.seller_id = o.seller_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_date BETWEEN start_date AND end_date
    GROUP BY s.seller_id, s.seller_name, s.origin
    ORDER BY SUM(oi.total_price) DESC
    LIMIT top_n;
END;
$$ LANGUAGE plpgsql;

-- Call the Function

SELECT * 
FROM get_top_sellers_by_sales('2024-05-01', '2025-1-10', 10);

