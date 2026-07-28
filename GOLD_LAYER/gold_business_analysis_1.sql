use EcommerceDB

--5.1 — Overall Business Snapshot
SELECT 
	COUNT(DISTINCT order_id) AS total_orders,
	COUNT(DISTINCT customer_id) AS total_customers,
	SUM(order_amount) AS total_revenue,
	AVG(order_amount) AS avg_order_value,
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date
FROM orders;

-- 5.2 — Order Status Breakdown (kitne % orders delivered/cancelled/pending hain)
-- WE USED SUM WINDOW FUNCTION HERE FOR EVERY ORDER_STATUS
SELECT 
	order_status,
	COUNT(*) AS order_count,
	CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS percentage
FROM orders
GROUP BY order_status
ORDER BY order_count DESC

-- PAYMENT STATUS BREAKDOWN

SELECT
	payment_status,
	COUNT(*) AS payment_count,
	CAST(COUNT(*) *100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS percentage
FROM payments
GROUP BY payment_status
ORDER BY payment_count DESC

-- PAYMENT STATUS WITH SALE AMOUNT BREAKDOWN
SELECT 
    payment_status,
    COUNT(*) AS count_orders,
    SUM(order_amount) AS revenue_impact
FROM orders
GROUP BY payment_status
ORDER BY revenue_impact DESC;

/* AFTER ABOVE QUERY I GO THAT

Pehla important observation: customers table mein total 10,100 customers hain, 
lekin sirf 9,927 ne order kiya hai. Matlab ~173 customers aise hain jinhone kabhi order hi nahi kiya (zero orders). 
Ye ek business insight hai jo hum baad mein deep-dive karenge (Level 2/3 mein) — 
"dormant/never-purchased customers" ek real marketing target segment hota hai.
*/

------------LEVEL-2--------------------FILTERING--------------------------
-- 5.4 — Sirf 'Delivered' aur high-value orders (₹1,00,000 se zyada)

SELECT
	*
FROM orders
WHERE order_status = 'Delivered' AND order_amount >50000
ORDER BY order_amount

-- 5.5 — Multiple statuses ek saath (IN operator)
SELECT
	order_id,order_status,order_amount
FROM orders
WHERE order_status IN ('Cancelled','Returned')

-- 5.6 — Ek specific date range ke orders (BETWEEN)
SELECT
	order_id,order_status,order_date,order_amount
FROM orders
WHERE order_date BETWEEN '2025-01-01' AND '2025-03-31'
ORDER BY order_date ASC

-- LIKE OPERATOR
SELECT * 
FROM customers
WHERE city LIKE '%Delhi%';

-- 5.8 — Combine karke complex filter (AND + OR + IN)
-- look for customers whose order status is dellivered hai ya shipped hai but paid jarur ho 
	-- order amount 10000 to 50k ke bich me ho

SELECT *
FROM orders
WHERE (order_status = 'Delivered' or order_status = 'Shipped')
	AND payment_status = 'Paid'
	AND order_amount BETWEEN 10000 and 50000



-----------------------------------------🔹 Level 3 — Grouping Data-------------------------------------------

-- 5.9 — Category-wise Revenue (GROUP BY with JOIN)
-- catoegories are in different table and revenue are in different table thats why we will join them first then grouping

/*
SELECT TOP 10 * 

FROM orders

SELECT TOP 10 * 

FROM order_items

SELECT TOP 10 * 

FROM categories

This help us to find which column is common to build relation among tables
*/

SELECT 
	c.category_name,
	COUNT(oi.order_item_id) AS item_sold,
	SUM(oi.total_amount) AS total_revenue,
	AVG(oi.total_amount) AS avg_item_value
FROM order_items oi
	JOIN products p on oi.product_id = p.product_id
	JOIN categories c on c.category_id =p.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC

-- 5.10 — Month-wise Order Trend (Date-based Grouping)

SELECT TOP 10
	YEAR(order_date) AS order_year,
	MONTH(order_date) AS order_month,
	COUNT(order_id) as total_orders,
	SUM(order_amount) as total_revenue
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY total_revenue DESC


-- 5.11 — City-wise Customer Count aur Revenue

SELECT 
	c.city,
	count(c.customer_id) AS toal_customer,
	SUM(O.order_amount) AS total_revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.city
ORDER BY total_revenue


-- 5.12 — HAVING ka use — sirf wahi categories dikhao jinka revenue ₹5 Crore se zyada hai
SELECT 
    c.category_name,
    SUM(oi.total_amount) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
HAVING SUM(oi.total_amount) > 50000000
ORDER BY total_revenue DESC;


-- 5.13 — Employee-wise performance (kaunse employee ne sabse zyada orders handle kiye)

SELECT 
e.employee_id,
e.first_name,
e.department,
COUNT(o.order_id) as order_handled,
SUM(o.order_amount) AS revenue_generated
FROM employees e
JOIN orders o ON o.employee_id = e.employee_id
GROUP BY e.employee_id,e.first_name,e.department
ORDER BY order_handled DESC

--------------------------------Chalo ab Level 4 — Ranking & Window Functions-----------------------------------------

-- 🔹 Level 4 — Sorting, Limiting & Ranking

-- 5.14 — Simple TOP: Top 10 highest-value orders
SELECT TOP 10 *
FROM ORDERS
ORDER BY order_amount DESC

-- 5.15 — Top 5 customers by total spend (TOP + GROUP BY combo)

SELECT TOP 5 
	c.customer_id,
	    c.first_name + ' ' + c.last_name AS customer_name,
	SUM(o.order_amount) AS total_spend
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name + ' ' + c.last_name
ORDER BY total_spend DESC


WITH ranked_products AS(
	SELECT
		c.category_name,
		p.product_name,
		SUM(oi.total_amount) AS product_revenue,
		ROW_NUMBER() OVER(PARTITION BY c.category_name ORDER BY SUM(oi.total_amount) DESC) AS rn
	FROM order_items oi
	JOIN products p ON oi.product_id = p.product_id
	JOIN categories c ON c.category_id = p.category_id
	GROUP BY c.category_name,p.product_name
)
SELECT * FROM ranked_products WHERE rn<=2
ORDER BY category_name,rn;


-- 5.17 — Customer ranking by spend, with RANK vs DENSE_RANK comparison


WITH ranked_customers AS(
SELECT 
	c.customer_id,
	c.first_name,
	SUM(o.order_amount) AS total_spend,
	RANK() OVER (ORDER BY SUM(o.order_amount) DESC) AS rank_position,
	DENSE_RANK() OVER (ORDER BY SUM(o.order_amount) DESC) AS dense_rank_position
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id,c.first_name
ORDER BY total_spend DESC
)

SELECT TOP 5 * FROM ranked_customers
ORDER BY customer_id,first_name


-- 5.18 — Employee ranking within their department (PARTITION BY practical use)
SELECT 
    e.department,
    e.first_name + ' ' + e.last_name AS employee_name,
    e.salary,
    DENSE_RANK() OVER (PARTITION BY e.department ORDER BY e.salary DESC) AS salary_rank_in_dept
FROM employees e
ORDER BY e.department, salary_rank_in_dept;






-------------------------------------- 🔹 Level 5 — LEAD, LAG, FIRST_VALUE, LAST_VALUE---------------------------------

SELECT TOP 10
	order_date,
	LAG(order_date) OVER(PARTITION BY customer_id ORDER BY order_date) AS previous_order_date,
	DATEDIFF(DAY,LAG(order_date) OVER(PARTITION BY customer_id ORDER BY order_date),order_date) AS days_since_last

FROM orders
ORDER BY order_date


-- 5.19 — Customer ke consecutive orders ke beech gap (LAG use-case)
SELECT 
    customer_id,
    order_id,
    order_date,
    LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date,
    DATEDIFF(DAY, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date), order_date) AS days_since_last_order
FROM orders
ORDER BY customer_id, order_date;


----------------5.20 — Month-over-Month Revenue Growth (LAG + CTE combo)----------------

WITH monthly_revenue AS(
	SELECT
		YEAR(order_date) AS yr,
		MONTH(order_date) AS mo,
		SUM(order_amount) AS revenue
	FROM orders
	GROUP BY YEAR(order_date),MONTH(order_date)
)

SELECT 
	yr,mo,revenue,
	LAG(revenue) OVER(ORDER BY yr,mo) AS prev_mon_rev,
	revenue - LAG(revenue) OVER(ORDER BY yr,mo) AS rev_change,
	CAST((revenue - LAG(revenue) OVER (ORDER BY yr, mo)) * 100.0 
         / NULLIF(LAG(revenue) OVER (ORDER BY yr, mo), 0) AS DECIMAL(6,2)) AS growth_percent
FROM monthly_revenue
ORDER BY yr,mo;

----------------------- Year over year  change in revenue--------------------------
WITH yaerly_revenue AS(
	SELECT
		YEAR(order_date) AS yr,
		SUM(order_amount) AS revenue
	FROM orders
	GROUP BY YEAR(order_date)
)

SELECT 
	yr,revenue,
	LAG(revenue) OVER(ORDER BY yr) AS prev_mon_rev,
	revenue - LAG(revenue) OVER(ORDER BY yr) AS rev_change
FROM yaerly_revenue
ORDER BY yr;


--------------5.21 — Customer ka pehla aur aakhri order (FIRST_VALUE + LAST_VALUE)--------------------

SELECT DISTINCT 
	customer_id,
	FIRST_VALUE(order_date) OVER(PARTITION BY customer_id ORDER BY customer_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS first_order_date,
	LAST_VALUE(order_date) OVER(PARTITION BY customer_id ORDER BY customer_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as last_order_date
FROM orders
order by customer_id


---------------5.22 — Customer ke first order ki value vs latest order ki value compare karna------------

WITH customer_orders AS (
    SELECT 
        customer_id,
        order_id,
        order_date,
        order_amount,
        FIRST_VALUE(order_amount) OVER (PARTITION BY customer_id ORDER BY order_date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS first_order_amount,
        LEAD(order_amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order_amount
    FROM orders
)
SELECT * FROM customer_orders ORDER BY customer_id, order_date;


------------------------------------------------------------------------------------------------------------------------------------

-----🔹 Level 6A — String Functions (CONCAT, SUBSTRING, REPLACE, TRIM)----------------------

--5.23 — Full Name banana aur Email domain nikaalna (CONCAT + SUBSTRING)
SELECT 
	customer_id,
	CONCAT(first_name,' ',last_name) AS full_name,
	email,
	SUBSTRING(email,CHARINDEX('@',email)+1,LEN(email)) AS email_domain
FROM customers


-- 5.24 — Phone number ya masked data clean karna (REPLACE)

SELECT 
	phone as original_phone,
	REPLACE(REPLACE(phone,'+91-',''),'-','') AS cleaned_phone
FROM customers


-- 5.25 — TRIM (extra spaces hatana — bohot common issue jab data Excel/CSV se aata hai)

SELECT 
	customer_id,
	TRIM(city) as cleaned_city
from customers


-- 5.26 — Email domain-wise customer distribution (business insight banane ke liye string function ka use)

SELECT 
	SUBSTRING(email,CHARINDEX('@',email)+1,LEN(email)) AS email_domain,
	COUNT(*) As customer_count
FROM customers
GROUP BY SUBSTRING(email,CHARINDEX('@',email)+1,LEN(email))
ORDER BY customer_count


---------------------------------------------------------------------------

--🔹 Level 6B — Date & Time Functions (DATEADD, DATEDIFF, DATETRUNC/formatting)

SELECT 
	customer_id,
	registration_date,
	DATEDIFF(YEAR,registration_date,GETDATE()) AS yaer_since_regn,
	DATEDIFF(DAY,registration_date,GETDATE()) AS day_since_regn
FROM customers

-- 5.28 — Expected delivery vs actual delivery — kitne din late/early (DATEDIFF real business use)

WITH delivery_tracking AS (
	SELECT
		order_id,
		expected_delivery,
		actual_delivery,
		DATEDIFF(DAY,expected_delivery,actual_delivery) As delays_days,
	CASE

		WHEN DATEDIFF(DAY,expected_delivery,actual_delivery) > 0 THEN 'Late'
		WHEN DATEDIFF(DAY,expected_delivery,actual_delivery) <= 0 THEN 'On Time'
	END AS delivery_status
	FROM orders
)

SELECT
	delivery_status,
	count(*) AS total_deliveries
FROM delivery_tracking
GROUP BY delivery_status;


------------------------

----5.30 — Last 90 din ke orders (DATEADD — "rolling window" pattern, bahut common)


SELECT order_id, customer_id, order_date, order_amount
FROM orders
WHERE order_date >= DATEADD(DAY,-90,(SELECT MAX(order_date) FROM orders));
-- is data me max date jo bhi ho uske hisaaab se 90 days ke data lega


------🔹 Level 7A — NULL Handling (COALESCE, ISNULL---------------------------------

-- 5.31 — Missing values ko default se replace karna (COALESCE vs ISNULL)

SELECT 
	city,
	COALESCE(city,'Not Mentioned') As cleaned_city
FROM customers
-- where city IS NULL;


--5.32 — 🔹 Level 7B — Data Type Conversion (CAST, CONVERT)


SELECT 
	order_id,
	order_amount,
	CAST(order_amount AS DECIMAL(10,0)) AS rounded_amount,
	CAST(order_amount AS INT) AS rounded_amount_int
FROM orders