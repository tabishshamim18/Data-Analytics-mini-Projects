/*
=================================================================================
Customer Report
=================================================================================
Purpose: 
	-This report consolidates key customer metrics and behaviours

Highlights:
	1. Gather essential fields such as names, age,  and transaction details.
	2. Segment customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
		-total orders
		-total sales
		-total quantity purchased
		-total products
		-lifespan (in months)
	4. Calculates valuable KPIs:
		-Recency(months since last order)
		-average order value
		-average monthly spend

=================================================================================
*/
 
WITH base_query AS
	(
	SELECT
	order_number,
	product_key,
	order_date,
	CAST(sales_amount AS DECIMAL(6,2)) AS sales_amount,
	quantity,
	c.customer_key,
	customer_number,
	CONCAT(first_name,' ', last_name) AS full_name,
	DATEDIFF(YEAR, birthdate, GETDATE()) AS age
	FROM dbo.fact_sales s
	LEFT JOIN dbo.dim_customers c
	ON s.customer_key = c.customer_key
	WHERE order_date IS NOT NULL
	),
customer_aggregation as
	(
	SELECT customer_key,
	customer_number,
	full_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	CONCAT(DATEDIFF(MONTH, MIN(order_date), MAX(order_date)), ' ',
	CASE
		WHEN DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) < 10 THEN 'Month'
		ELSE 'Months'
	END) AS life_span
	FROM base_query
	GROUP BY
		customer_key,
		customer_number,
		full_name,
		age
	)
SELECT 
	customer_key,
	customer_number,
	full_name,
	age,
	CASE
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50 AND above'
	END AS age_group,
	CASE
		WHEN CAST(LEFT(life_span, CHARINDEX(' ', life_span) - 1) AS INT) >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN CAST(LEFT(life_span, CHARINDEX(' ', life_span) - 1) AS INT) >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	last_order_date,
	DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
-- Calculating average order value
	CAST(total_sales/total_orders AS DECIMAL(6,2)) AS avg_order_value,
-- Calculating average monthly expenditure
	COALESCE(CAST(total_sales/NULLIF(CAST(LEFT(life_span, CHARINDEX(' ', life_span) - 1) AS INT),0) AS DECIMAL(6,2)),0) AS avg_monthly_spend,
	life_span
FROM customer_aggregation