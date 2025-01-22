-- APPLE SQL PROJECT 

-- CREATING TABLE

-- category TABLE 
CREATE TABLE categories
(
category_id INT PRIMARY KEY,
category_name VARCHAR(30)
);

-- customer TABLE
CREATE TABLE customers
(
customer_id INT PRIMARY KEY,
first_name VARCHAR(30),
last_name VARCHAR(30),
province VARCHAR (50)
);

-- seller TABLE 
CREATE TABLE sellers
(
seller_id INT PRIMARY KEY,
seller_name VARCHAR(100),
origin VARCHAR (30)
);

-- product TABLE 
CREATE TABLE products
(
product_id INT PRIMARY KEY, 
product_name VARCHAR(50),
price FLOAT,
cogs FLOAT,
category_id INT, -- FK
CONSTRAINT category_fk_in_products FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- order TABLE 
CREATE TABLE orders
(
order_id INT PRIMARY KEY,
order_date DATE,
customer_id INT, -- FK 
order_status VARCHAR(30),
seller_id INT, -- FK
CONSTRAINT customer_fk_in_orders FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
CONSTRAINT seller_fk_in_orders FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

-- order_items TABLE
CREATE TABLE order_items 
(
order_item_id INT PRIMARY KEY,
order_id INT, -- FK
product_id INT, -- FK
Quantity INT,
price_per_unit FLOAT, 
total_price FLOAT,
CONSTRAINT order_fk_in_order_item FOREIGN KEY (order_id) REFERENCES orders(order_id),
CONSTRAINT product_fk_in_order_item FOREIGN KEY (product_id) REFERENCES products(product_id)
);


-- payment TABLE
CREATE TABLE payments
(
payment_id INT PRIMARY KEY, 
payment_date DATE, 
payment_mode VARCHAR(30),
order_id INT, -- FK
payment_status VARCHAR(30),
CONSTRAINT order_fk_in_payment FOREIGN KEY (order_id) REFERENCES orders(order_id)
); 

-- shipping TABLE
CREATE TABLE shipping
(
shipping_id INT PRIMARY KEY,
order_id INT, -- FK
shipping_provider VARCHAR(30),
delivery_status VARCHAR(30),
shipping_date DATE,
return_date DATE,
CONSTRAINT order_fk_in_shipping FOREIGN KEY (order_id) REFERENCES orders(order_id)
);



-- inventory TABLE
CREATE TABLE inventory
(
inventory_id INT PRIMARY KEY,
product_id INT, -- FK
stock_remaining INT,
warehouse_id VARCHAR(30),
restock_date DATE,
CONSTRAINT product_fk_in_inventory FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- END OF SCHEMAS









