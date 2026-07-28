use EcommerceDB;

-- 🔹 Level 8A — RFM Segmentation (Recency, Frequency, Monetary)

/*
Ye sabse valuable customer analysis technique hai retail/e-commerce mein. Isse hum customers ko categorize karte hain:

Recency (R): Customer ne kitne din pehle last order kiya
Frequency (F): Customer ne kitni baar order kiya
Monetary (M): Customer ne total kitna kharch kiya
*/

-- 5.35 — RFM Base Metrics nikaalna (CTE + Aggregation)
WITH rfm_base as (
	SELECT 
		customer_id,
		--			ISME customer ki max hai , or second me total ka max hai to usme se minus ho rha hai
		DATEDIFF(DAY,MAX(order_date),(SELECT MAX(order_date) FROM orders)) AS recency_days,
		COUNT(order_id) AS frequency,
		SUM(order_amount) AS monetry
	FROM orders
	GROUP BY customer_id
)


SELECT * FROM rfm_base ORDER BY monetry DESC


-- 5.36 — RFM Scoring (NTILE — ek naya window function jo abhi tak nahi use kiya!)

WITH rfm_base AS (
    SELECT 
        customer_id,
        DATEDIFF(DAY, MAX(order_date), (SELECT MAX(order_date) FROM orders)) AS recency_days,
        COUNT(order_id) AS frequency,
        SUM(order_amount) AS monetary
    FROM orders
    GROUP BY customer_id
),

rfm_scored AS (

SELECT
	customer_id,
	recency_days,
	frequency,
	monetary,
	NTILE(5) OVER (ORDER BY recency_days DESC) AS R_score,
	NTILE(5) OVER (ORDER BY frequency DESC) AS F_score,
	NTILE(5) OVER (ORDER BY monetary DESC) AS M_score
FROM rfm_base
)

SELECT * FROM rfm_scored ORDER BY customer_id




------------------------------------------------------------

--5.37 — Final RFM Segments (CASE WHEN + combined scores)
WITH rfm_base AS (
    SELECT 
        customer_id,
        DATEDIFF(DAY, MAX(order_date), (SELECT MAX(order_date) FROM orders)) AS recency_days,
        COUNT(order_id) AS frequency,
        SUM(order_amount) AS monetary
    FROM orders
    GROUP BY customer_id
),
rfm_scored AS (
    SELECT 
        customer_id, recency_days, frequency, monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS R_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS F_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS M_score
    FROM rfm_base
)
SELECT 
    customer_id, recency_days, frequency, monetary,
    R_score, F_score, M_score,
    (R_score + F_score + M_score) AS total_rfm_score,
    CASE 
        WHEN R_score >= 4 AND F_score >= 4 AND M_score >= 4 THEN 'Champions'
        WHEN R_score >= 3 AND F_score >= 3 THEN 'Loyal Customers'
        WHEN R_score <= 2 AND F_score <= 2 THEN 'At Risk'
        WHEN R_score <= 2 AND F_score >= 3 THEN 'Cant Lose Them'
        ELSE 'Regular Customers'
    END AS customer_segment
FROM rfm_scored
ORDER BY total_rfm_score DESC;



----------------------------------------------------------------------------------------------------------

/*

Excellent! Chalo ab Level 8B — Cohort Analysis + Running Totals (Cumulative Revenue) — 
ye advanced window function techniques hain jo growth/retention track karne ke liye use hoti hain.
*/


-- 🔹 Cohort Analysis — "Customers ko unke registration month ke hisaab se group karke dekhna ki wo kitna retain hue"
-- 5.38 — Customer Cohort banana (registration month ke basis pe)
WITH customer_cohort AS (
SELECT 
    customer_id,
    FORMAT(registration_date,'yyyy-MM') as cohort_month
FROM customers
),

order_activity AS (
SELECT
    o.customer_id,
    FORMAT(o.order_date,'yyyy-MM') AS order_month
FROM orders o

)
SELECT 
    cc.cohort_month,
    oa.order_month,
    COUNT(DISTINCT oa.customer_id) AS active_customers
FROM customer_cohort cc
JOIN order_activity oa ON oa.customer_id = cc.customer_id
GROUP BY cc.cohort_month, oa.order_month
ORDER BY cc.cohort_month, oa.order_month


-- 5.39 — Cohort Index (kitne mahine baad customer active raha — DATEDIFF use karke)
WITH customer_cohort AS (
SELECT 
    customer_id,
    FORMAT(registration_date,'yyyy-MM') as cohort_month,registration_date
FROM customers
),

order_activity AS (
SELECT
    o.customer_id,
    o.order_date
    -- FORMAT(o.order_date,'yyyy-MM') AS order_month
FROM orders o

)

SELECT
    cc.cohort_month,
    DATEDIFF(MONTH,cc.registration_date,oa.order_date) AS months_since_signup,
    COUNT(DISTINCT oa.customer_id) AS active_customers
FROM customer_cohort cc
JOIN order_activity oa ON oa.customer_id = cc.customer_id
WHERE DATEDIFF(MONTH,cc.registration_date,oa.order_date) >=0
GROUP BY cc.cohort_month, DATEDIFF(MONTH, cc.registration_date, oa.order_date)
ORDER BY cc.cohort_month, months_since_signup;

/*
Result : Cohort analysis me ham dekh rhe hai ki customer kab active hai or kab se hmaare saath hai ya kitne customer hmarre saath hai within a specific time period
*/


/*
🔹 Running Totals & Cumulative Revenue (SUM() OVER — advanced window function pattern)

*/
-- 5.40 — Daily Cumulative Revenue (Running Total)

WITH daily_revenue AS (
    SELECT 
        order_date,
       SUM(order_amount) AS daily_sales
    FROM orders
    GROUP BY order_date
)

SELECT 
    order_date,
    daily_sales,
    CAST(SUM(daily_sales) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as DECIMAL(10,0)) AS cumulateive_rev  
FROM daily_revenue
ORDER BY order_date;

-- Result : har din ki sales cummulative sales me add hoke bad rhi hai 




--5.41 — Moving Average (3-month rolling average — trend smoothing ke liye)
WITH monthly_revenue AS (
    SELECT YEAR(order_date) AS yr, MONTH(order_date) AS mo, SUM(order_amount) AS revenue
    FROM orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    yr, mo, revenue,
    AVG(revenue) OVER (ORDER BY yr, mo ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3month
FROM monthly_revenue
ORDER BY yr, mo;






/*
Perfect! Chalo ab Level 9 — Subqueries + Set Operators, jo humne abhi tak directly touch nahi kiya. 
Ye tumhare original topic list ke important pending items hain.

*/

-- 🔹 Level 9A — Subqueries (Scalar, Multi-row, Correlated)

-- 5.42 — Scalar Subquery (sirf ek value return karta hai)
-- Business question: "Kaunse customers ka order average se zyada hai?"
SELECT 
    order_id,order_amount
FROM orders
WHERE order_amount > (SELECT AVG(order_amount) FROM orders)


-- 5.43 — Multi-row Subquery (IN ke saath — multiple values return karta hai)
-- Business question: "Un customers ke saare orders dikhao jinhone kabhi return kiya hai"
SELECT TOP 10 *
FROM orders 
WHERE customer_id IN (SELECT DISTINCT customer_id FROM returns)


-- 5.44 — Correlated Subquery (sabse advanced type — outer query se link hota hai)
-- Business question: "Har customer ka sabse latest (last) order dikhao"
SELECT 
    o1.customer_id,
    o1.order_date
FROM orders o1
WHERE o1.order_date = (
    SELECT MAX(o2.order_date)
FROM orders o2
WHERE o2.customer_id = o1.customer_id
)


-- 5.45 — EXISTS (correlated subquery ka common variant — sirf existence check karta hai)

-- Business question: "Wo saare customers dikhao jinke koi order hi nahi hai" (jo humne Step 5.1 mein 173 customers ka gap dekha tha — ab actual list nikaalte hain!)
SELECT
       c.customer_id,
       c.first_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o where o.customer_id = c.customer_id
);


SELECT 1 FROM orders

-------------------------------------------------------------------------------------------------------------
-- 🔹 Level 9B — Set Operators (UNION, UNION ALL, INTERSECT, EXCEPT)

-- 5.46 — UNION vs UNION ALL (Delhi ke customers + Mumbai ke customers ek saath)

SELECT customer_id,city FROM customers where city = 'Delhi'

UNION
SELECT customer_id,city FROM customers where city = 'Mumbai'

--Result : Union removes duplicates as well , agar hame pta hai ki customer 2 sirf Delhi ho sakta hai or mumbai me bhi to union chalaao verna union all chalao 


SELECT customer_id,city FROM customers where city = 'Delhi'

UNION ALL
SELECT customer_id,city FROM customers where city = 'Mumbai'


-- 5.47 — INTERSECT (dono conditions mein common rows)

SELECT customer_id FROM orders
INTERSECT
SELECT customer_id FROM returns 

-- 5.48 — EXCEPT (pehli query mein hai, dusri mein nahi)
-- Business question: "Wo customers jinhone order kiya hai lekin kabhi return nahi kiya"

SELECT customer_id FROM orders
EXCEPT
SELECT customer_id FROM returns 


----------------------------Level 10 — Views (Final Wrap-up)------------------------------------------------

-- 🔹 Level 10 — Views & Materialized Reporting
-- Complex logic ek jagah likho, baar-baar reuse karo.
-- 5.49 — View 1: Customer 360 Summary (sab kuch ek jagah — order history, spend, RFM basics)

CREATE VIEW vw_customer_360 AS
SELECT 
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    c.city,
    c.state,
    c.customer_segment,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.order_amount), 0) AS total_spend,
    MAX(o.order_date) AS last_order_date,
    COALESCE(SUM(o.order_amount), 0) / NULLIF(COUNT(DISTINCT o.order_id), 0) AS avg_order_value
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.city, c.state, c.customer_segment;

SELECT * FROM vw_customer_360 WHERE total_orders = 0 -- never purchased customers
SELECT * FROM vw_customer_360 ORDER BY total_spend DESC;  -- top spenders, direct



-- 5.50 — View 2: Monthly Business Performance Dashboard
CREATE VIEW vw_monthly_performance AS
SELECT 
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(order_id) AS total_orders,
    SUM(order_amount) AS total_revenue,
    AVG(order_amount) AS avg_order_value,
    SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(CASE WHEN order_status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date);

SELECT * FROM vw_monthly_performance ORDER BY order_year,order_month


-- 5.51 — View 3: Product Performance (category + supplier context ke saath)
CREATE VIEW vw_product_performance AS
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    s.supplier_name,
    p.stock_quantity,
    COALESCE(SUM(oi.quantity), 0) AS total_units_sold,
    COALESCE(SUM(oi.total_amount), 0) AS total_revenue,
    COALESCE(SUM(oi.profit), 0) AS total_profit
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id
LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, c.category_name, s.supplier_name, p.stock_quantity;


SELECT * FROM vw_product_performance ORDER BY total_revenue DESC;
SELECT * FROM vw_product_performance WHERE total_units_sold = 0;  -- dead stock/never sold