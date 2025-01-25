# Apple Sales Analysis Project


---
## *Project Overview*

The Apple Sales Analysis project comprehensively explores sales data designed to uncover customer behavior patterns and product performance insights using PostgreSQL. 
The dataset consists of thousands of meticulously generated sales records, created using Python and libraries like `pandas` and `faker` to simulate a realistic sales environment. 
Advanced querying techniques are employed to analyze the data, extracting meaningful insights into purchasing trends, product performance, and customer demographics. 
An **Entity-Relationship Diagram (ERD)** is included to visually represent the database schema, highlighting the relationships between key tables such as customers, products, and sales. 
This diagram is a blueprint for understanding the data structure and its interconnectedness. 
By leveraging Python for data generation and PostgreSQL for querying, this project demonstrates a seamless integration of tools to analyze large datasets and derive actionable insights for strategic decision-making.

---

## *Database Setup & Design*

The database setup for the Apple Sales Analysis project was designed with a well-structured schema to capture essential aspects of the sales process, as illustrated in the accompanying Entity-Relationship Diagram (ERD). 
The database consists of multiple interconnected tables, each representing a critical component of the sales ecosystem. Key entities include `customers,` `products,` `orders,` `order_items,` `sellers,` `inventory,` `shipping,` `categories,` and `payments.` 
These tables are connected through carefully defined relationships, ensuring the integrity and efficiency of the data structure.

#### Dataset Generation Process in Jupyter Notebook:
- **Library Setup:** Imported libraries such as `pandas` for data manipulation and `faker` for generating realistic customer and seller details.
- **Data Creation:** Used faker to generate synthetic data for customers, sellers, and orders, ensuring diversity in the dataset (e.g., `customer demographics`, `seller names`).
- **Relational Mapping:** Ensured consistency by linking generated IDs between tables, such as assigning customer IDs to orders and product IDs to inventory records.
- **Export:** Saved the generated datasets as CSV files to import into the PostgreSQL database easily.

#### Database Creation:
- **Database Setup:** Created a PostgreSQL database with all tables and relationships as defined in the ERD diagram.
- **Schema Script:** Wrote SQL scripts to define the database schema, including table structures, primary and foreign keys, and constraints.
- **Data Import:** The generated datasets are imported into the database to populate the tables for analysis.

  *For reference, the schema creation script can be found [here](https://github.com/Taimalee/SQL_APPLE/blob/main/DB_Schemas.sql)*

#### ERD diagram

![ERD](https://github.com/Taimalee/SQL_APPLE/blob/main/ERD.png)

---

## *Identifying Business Problems*

#### Key Business Problems Identified & Solutions Implemented:

- ***Top-Selling Province for Each Category:** Identify the top-selling province for each product category. (Challenge: 	Include the total sales for that category within the province).*

  ```sql

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

  ```



- ***Customers with No Purchases** Find customers in our database who have never placed an order. (Challenge: Include customer details).*

  ```sql

  SELECT * 
  FROM customers
  WHERE customer_id NOT IN 
	  (
	  SELECT DISTINCT(customer_id) 
	  FROM orders
	  );

  ```

  
- ***Average Order Value (AOV):** Calculate the average order value for each customer. (Challenge: Include only customers with more than 35 orders).*

  ```sql

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

  ```

  
- ***Top Selling Products:** Query the top 10 products by total sales value. (Challenge: Include product name, total quantity sold, and total sales value).*

  ```sql

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

  ```


- ***Customer Lifetime Value (CLTV)** Calculate the total value of orders placed by each customer over their lifetime. (Challenge: 	Rank customers based on their CLTV and display the top 10).*

  ```sql

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

  ```


#### Advanced Techniques Used:
- **Subqueries:** Used to filter datasets dynamically, such as identifying delayed shipping orders or calculating category contributions to revenue.
- **Common Table Expressions (CTEs):** Employed to simplify complex queries into logical steps, such as breaking down monthly revenue before aggregating for trends.
- **Window Functions:** Utilized for ranking (e.g., `RANK()` for top customers) and cumulative calculations (e.g., `SUM()` for running totals).
- **Join Optimization:** Leveraged inner and left joins to efficiently link key tables (e.g., orders, products, and inventory) for comprehensive insights.

---

## *Project Objective*
The Apple Sales Analysis project aims to leverage advanced data analysis techniques to gain actionable insights into sales performance, customer behavior, and operational efficiency. 
The project aims to identify key trends, optimize business processes, and provide data-driven recommendations to enhance 
decision-making and drive revenue growth by utilizing a well-structured PostgreSQL database, complex queries, and Python-generated datasets.



