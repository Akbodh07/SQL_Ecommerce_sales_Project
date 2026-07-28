SELECT @@VERSION;

 -- 1.1 Check tables and rows of data

SELECT 
		t.name AS table_name,
		p.rows AS row_count
FROM sys.tables t
JOIN sys.partitions p 
	ON t.object_id = p.object_id AND p.index_id IN(0,1)

ORDER BY p.rows DESC;



-- 1.2 — Check structure (columns, data types, nullability) properly.

SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'orders'   -- ek ek table karke check karunga
ORDER BY ORDINAL_POSITION;


-- 1.3 — Primary Key / Foreign Key check 

SELECT 
    tc.TABLE_NAME,
    tc.CONSTRAINT_TYPE,
    kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
ORDER BY tc.TABLE_NAME;


-- 🔹 STEP 2 — Data Profiling & Cleaning 

/*
1.Duplicate primary keys (jaise duplicate order_id)
2.NULLs in important columns
3.Orphan records (jaise order_items.order_id jo orders mein exist nahi karta — "referential integrity" check, kyunki FK hai hi nahi)
4. Value mismatches jaise humne pehle dekha (bool columns mein VARCHAR, data type inconsistency)


*/


--1.Count of Duplicate primary keys 

SELECT order_id ,
COUNT(*) AS count_id
FROM orders
GROUP BY order_id
HAVING COUNT(*)> 1


-- 2.2 — Orphan Check: order_items mein aise rows jinka order_id orders table mein exist hi nahi karta

SELECT 
oi.order_id,COUNT(*) AS orphan_item_count
FROM order_items oi
LEFT JOIN orders o on oi.order_id = o.order_id
WHERE o.order_id IS NULL
GROUP BY oi.order_id;

-- Result : No Orphan Count

-- orders and payment mismatch rows

SELECT o.order_id,o.order_status,o.payment_status
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id
WHERE p.order_id IS NULL

-- Result : No data error

---------------------------------------------------------------------------------
-- 2.4 — NULL check across important columns (orders)

SELECT 
SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customers,
SUM(CASE WHEN employee_id IS NULL THEN 1 ELSE 0 END) AS null_employee_id,
SUM(CASE WHEN shipper_id IS NULL THEN 1 ELSE 0 END) AS null_shipper_id,
SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
SUM(CASE WHEN order_amount IS NULL THEN 1 ELSE 0 END) AS null_order_amount
 -- SUM(CASE WHEN coupon_code IS NULL THEN 1 ELSE 0 END) AS null_coupons
FROM orders;


-- Result : No null in keys id


-------------------------------------------------------------------
SELECT p.order_id , COUNT(*) AS payment_count
from payments p
GROUP BY order_id
HAVING COUNT(*) >1 
ORDER BY payment_count DESC

-- Result : 100 order id are duplicates


-------------------------------------------
-- 3.1 — customers mein orphan orders check (kya koi order aisa hai jiska customer exist nahi karta?)
SELECT o.customer_id, COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN customers c on o.customer_id = c.customer_id
WHERE c.customer_id IS NULL 
GROUP BY o.customer_id;

-- 3.2 — products mein orphan order_items check
SELECT oi.product_id, COUNT(*) AS orphan_items
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL
GROUP BY oi.product_id;

-- 3.3 — products mein orphan category/supplier check

SELECT p.category_id
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id
WHERE c.category_id IS NULL AND p.category_id IS NOT NULL


SELECT p.supplier_id
FROM products p
LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id
WHERE s.supplier_id IS NULL AND p.supplier_id IS NOT NULL;
--Result : All are not matched values


SELECT DISTINCT manager_id
FROM employees 
WHERE manager_id IS NOT NULL
-- Reslut : iye values decimal me aa rhi hai but inka datatype varchar store hai to ham ise decimal ya int me karenge

SELECT 
    TRY_CAST(manager_id AS DECIMAL(10,2)) AS converted_value
FROM employees
WHERE manager_id IS NOT NULL
    AND TRY_CAST(manager_id AS DECIMAL(10,2)) IS NULL;
-- Ye query kya karegi? Ye sirf wahi rows dikhayegi jaha conversion fail hua —

-- CONVERT FROM VARCHAR TO DECIMAL TO INT
SELECT 
    employee_id,
    manager_id AS original_value,
    CAST(TRY_CAST(manager_id AS DECIMAL(10,2)) AS INT) AS manager_id_clean
FROM employees
-- Result : isme kuch null values hai jo ki genuine null hai and we will not do anything with that


----------------------------------------------------------------------------------------------------------------------------


-- ORDERS
SELECT order_id , count(*) as duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*)>1

-- Example: categories
SELECT category_id, COUNT(*) AS cnt
FROM categories
GROUP BY category_id
HAVING COUNT(*) > 1;

-- customers
SELECT customer_id, COUNT(*) AS cnt
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- suppliers
SELECT supplier_id, COUNT(*) AS cnt
FROM suppliers
GROUP BY supplier_id
HAVING COUNT(*) > 1;

-- employees
SELECT employee_id, COUNT(*) AS cnt
FROM employees
GROUP BY employee_id
HAVING COUNT(*) > 1;

-- shippers
SELECT shipper_id, COUNT(*) AS cnt
FROM shippers
GROUP BY shipper_id
HAVING COUNT(*) > 1;

-- products
SELECT product_id, COUNT(*) AS cnt
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- order_items
SELECT order_item_id, COUNT(*) AS cnt
FROM order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1;

-- payments
SELECT payment_id, COUNT(*) AS cnt
FROM payments
GROUP BY payment_id
HAVING COUNT(*) > 1;

-- returns
SELECT return_id, COUNT(*) AS cnt
FROM returns
GROUP BY return_id
HAVING COUNT(*) > 1;

 --------------------------------------------------------------

 -- LETS BACKUP OF THE TABLE FIRST 
SELECT * INTO orders_backup FROM orders;
SELECT * INTO customers_backup FROM customers;
SELECT * INTO suppliers_backup FROM suppliers;
SELECT * INTO employees_backup FROM employees;
SELECT * INTO shippers_backup FROM shippers;
SELECT * INTO products_backup FROM products;
SELECT * INTO order_items_backup FROM order_items;
SELECT * INTO payments_backup FROM payments;
SELECT * INTO returns_backup FROM returns;
SELECT * INTO categories_backup FROM categories;

-- WE CAN CHECK THAT EITHER JUST ID COPIED OR FULL ROWS ARE COPIED
SELECT customer_id, COUNT(*) AS total_rows, COUNT(DISTINCT CONCAT_WS('|', first_name, last_name, email, phone, city)) AS distinct_versions
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-------------------------------------------------------------------------------
-- START OF USING WINDOW FUNCTINO TO GET DUPLICATES
-- BEFORE DELETION WE WILL CHECK ABOUT NUMBER OF DUPLICATES IN TABLE
WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY (customer_id)) AS rn
FROM customers
)
SELECT * FROM duplicate_cte WHERE rn > 1;  -- FOR DUPLICATES
                                            -- rn = 1 for unique

-- NOW ITS TIME TO DELETE THE DUPLICATES FROM customer table
WITH duplicate_cte AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY (SELECT NULL)) AS rn
    FROM customers
)
DELETE FROM duplicate_cte WHERE rn > 1;


-- NOW ITS TIME TO DELETE THE DUPLICATES FROM empoyees table
WITH duplicate_cte AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY employee_id ORDER BY (SELECT NULL)) AS rn
    FROM employees
)
DELETE FROM duplicate_cte WHERE rn > 1;

WITH duplicate_cte AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY order_item_id ORDER BY (SELECT NULL)) AS rn
    FROM order_items
)
DELETE FROM duplicate_cte WHERE rn > 1;


WITH duplicate_cte AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY (SELECT NULL)) AS rn
    FROM orders
)
DELETE FROM duplicate_cte WHERE rn > 1;

WITH duplicate_cte AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY payment_id ORDER BY (SELECT NULL)) AS rn
    FROM payments
)
DELETE FROM duplicate_cte WHERE rn > 1;


WITH duplicate_cte AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY (SELECT NULL)) AS rn
    FROM products
)
DELETE FROM duplicate_cte WHERE rn > 1;


WITH duplicate_cte AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY return_id ORDER BY (SELECT NULL)) AS rn
    FROM returns
)
DELETE FROM duplicate_cte WHERE rn > 1;


WITH duplicate_cte AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY shipper_id ORDER BY (SELECT NULL)) AS rn
    FROM shippers
)
DELETE FROM duplicate_cte WHERE rn > 1;


WITH duplicate_cte AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY supplier_id ORDER BY (SELECT NULL)) AS rn
    FROM suppliers
)
DELETE FROM duplicate_cte WHERE rn > 1;

-- change from null to not null condition in category table

ALTER TABLE categories
ALTER COLUMN category_id INT NOT NULL;

--------------------------------------------------------------------------------------------------------------------
-- Add primary key on required tables
ALTER TABLE categories ADD CONSTRAINT PK_categories PRIMARY KEY (category_id);
ALTER TABLE suppliers ADD CONSTRAINT PK_suppliers PRIMARY KEY (supplier_id);
ALTER TABLE customers ADD CONSTRAINT PK_customers PRIMARY KEY (customer_id);
ALTER TABLE employees ADD CONSTRAINT PK_employees PRIMARY KEY (employee_id);
ALTER TABLE shippers ADD CONSTRAINT PK_shippers PRIMARY KEY (shipper_id);
ALTER TABLE products ADD CONSTRAINT PK_products PRIMARY KEY (product_id);
ALTER TABLE orders ADD CONSTRAINT PK_orders PRIMARY KEY (order_id);
ALTER TABLE order_items ADD CONSTRAINT PK_order_items PRIMARY KEY (order_item_id);
ALTER TABLE payments ADD CONSTRAINT PK_payments PRIMARY KEY (payment_id);
ALTER TABLE returns ADD CONSTRAINT PK_returns PRIMARY KEY (return_id);


----------------------------------------------------------------------------------------------

-- Step 4.4 — Foreign Keys
-- Orphan check (dedup ke baad wapas confirm karna)
SELECT COUNT(*) AS orphan_orders
FROM orders o 
LEFT JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NOT NULL AND o.customer_id NOT IN (SELECT customer_id FROM customers)

-- Add foreign keys in table
ALTER TABLE products ADD CONSTRAINT fk_products_categories
FOREIGN KEY(category_id) REFERENCES categories(category_id)

ALTER TABLE products ADD CONSTRAINT fk_products_suppliers
FOREIGN KEY(supplier_id) REFERENCES suppliers(supplier_id)

ALTER TABLE orders ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

ALTER TABLE orders ADD CONSTRAINT FK_orders_employees 
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id);

ALTER TABLE orders ADD CONSTRAINT FK_orders_shippers 
    FOREIGN KEY (shipper_id) REFERENCES shippers(shipper_id);

ALTER TABLE order_items ADD CONSTRAINT FK_orderitems_orders 
    FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE order_items ADD CONSTRAINT FK_orderitems_products 
    FOREIGN KEY (product_id) REFERENCES products(product_id);

ALTER TABLE payments ADD CONSTRAINT FK_payments_orders 
    FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE returns ADD CONSTRAINT FK_returns_orders 
    FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE returns ADD CONSTRAINT FK_returns_customers 
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id);



    --------------------------------------------

-- 🔹 Step 4.5 — manager_id ka datatype permanently fix karna

-- Step 1: naya column add karo

ALTER TABLE employees ADD manager_id_new INT NULL;

-- Step 2: data clean karke migrate karo
UPDATE employees
SET manager_id_new = CAST(TRY_CAST(manager_id AS DECIMAL(10,2)) AS INT);

-- Step 3: verify karo dono column match kar rahe hain (sanity check)
SELECT manager_id,manager_id_new FROM employees
WHERE manager_id IS NOT NULL

-- Step 4: agar sab sahi dikhe, purana column drop karo aur naya rename karo
ALTER TABLE employees DROP COLUMN manager_id
EXEC sp_rename 'employees.manager_id_new','manager_id','COLUMN';


SELECT * FROM employees
WHERE manager_id  = 18

-- SELF REFERECING IN employees and manager id , kyuki multiple employees ka ek manager ho sakta hai
ALTER TABLE employees ADD CONSTRAINT fk_employees_manager
FOREIGN KEY(manager_id) REFERENCES employees(employee_id);



------------------------------------------INDEXING-------------------------------
-- I CREATED A CLUSTERED INDEX OVER ALL FK ON ORDER TABLE SO THAT OUR LOOK UP GOT EASY
CREATE NONCLUSTERED INDEX IX_orders_customer_id ON orders(customer_id)
CREATE NONCLUSTERED INDEX IX_orders_employee_id ON orders(employee_id)
CREATE NONCLUSTERED INDEX IX_orders_shipper_id ON orders(shipper_id);
CREATE NONCLUSTERED INDEX IX_orderitems_order_id ON order_items(order_id);
CREATE NONCLUSTERED INDEX IX_orderitems_product_id ON order_items(product_id);
CREATE NONCLUSTERED INDEX IX_payments_order_id ON payments(order_id);
CREATE NONCLUSTERED INDEX IX_returns_order_id ON returns(order_id);
CREATE NONCLUSTERED INDEX IX_products_category_id ON products(category_id);
CREATE NONCLUSTERED INDEX IX_products_supplier_id ON products(supplier_id);


-- it gives and full structure of table or deep detail of tables
-- EXEC sp_help 'orders'