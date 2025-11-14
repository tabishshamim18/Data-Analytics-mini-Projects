-- 1. Analyze Sales Performance over time

-- Sales performance by year

SELECT YEAR(order_date) AS year,
CAST(SUM(sales_amount) AS DECIMAL(10,0)) AS total_sales,
COUNT(customer_key) AS total_Customers,
SUM(quantity) AS total_quantity
FROM dbo.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY year

-- Sales performance by month

SELECT MONTH(order_date) AS month,
CAST(SUM(sales_amount) AS DECIMAL(10,0)) AS total_sales,
COUNT(customer_key) AS total_Customers,
SUM(quantity) AS total_quantity
FROM dbo.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY month

-- Sales performance by year-month

SELECT FORMAT(order_date, 'yyyy-MM') AS year_month,
CAST(SUM(sales_amount) AS DECIMAL(10,0)) AS total_sales,
COUNT(customer_key) AS total_Customers,
SUM(quantity) AS total_quantity
FROM dbo.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY year_month

-- 2. Calculate the total sales per month and the running total of sales over time

--Running sales by Year

WITH yearly_running_sales AS
(
SELECT YEAR(order_date) AS year,
CAST(SUM(sales_amount) AS DECIMAL(10,0)) AS total_sales
FROM dbo.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
	)
SELECT*,
SUM(total_sales) OVER(ORDER BY year) AS running_sales
FROM yearly_running_sales

--Running Sales by month

WITH monthly_running_sales AS
(
SELECT MONTH(order_date) AS month,
CAST(SUM(sales_amount) AS DECIMAL(10,0)) AS total_sales
FROM dbo.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
	)
SELECT*,
SUM(total_sales) OVER(ORDER BY month) AS running_sales
FROM monthly_running_sales

--Running sales and moving average by Year-Month

WITH running_sales AS
(
SELECT CONVERT(VARCHAR(7), order_date, 120) AS year_month,
CAST(SUM(sales_amount) AS DECIMAL(18,0)) AS total_sales,
AVG(price) AS avg_Price
FROM dbo.fact_sales
WHERE order_date IS NOT NULL
GROUP BY CONVERT(VARCHAR(7), order_date, 120)
	)
SELECT year_month, total_sales,
SUM(total_sales) OVER(ORDER BY year_month) AS running_sales,
CAST(AVG(avg_Price) OVER(ORDER BY year_month) AS DECIMAL(6,0)) AS moving_average
FROM running_sales


/* 3. Analyze the yearly performance of products by comparing their sales
	to both the average sales performance of the product and the previous year's sales. */

WITH product_sales AS
(
SELECT product_name,
YEAR(order_date) AS year,
CAST(SUM(sales_amount) AS DECIMAL(18,0)) AS curr_sales
FROM dbo.fact_sales s
LEFT JOIN dbo.dim_products p
ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY product_name,  YEAR(order_date)
	)
	SELECT *,
	CAST(AVG(curr_sales) OVER(PARTITION BY product_name) AS DECIMAL(6,0)) AS avg_sales,
	COALESCE(LAG(curr_sales) OVER(PARTITION BY product_name ORDER BY year),0) AS prev_yr_sales,

	-- Comparing current year sales with the average sales

	CAST(curr_sales - AVG(curr_sales) OVER(PARTITION BY product_name) AS DECIMAL(6,0)) AS sales_diff,
	CASE
		WHEN curr_sales - AVG(curr_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Average'
		WHEN curr_sales - AVG(curr_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Average'
		ELSE 'No Change'
	END AS avg_change,

-- Comparing current year sales with the previous year sales
	CASE WHEN COALESCE(LAG(curr_sales) OVER(PARTITION BY product_name ORDER BY year),0) <> 0 THEN
		CAST(curr_sales - COALESCE(LAG(curr_sales) OVER(PARTITION BY product_name ORDER BY year),0) AS DECIMAL(16,0))
		ELSE 0
	END AS curr_vs_prev_sales,
	CASE
		WHEN curr_sales - LAG(curr_sales) OVER(PARTITION BY product_name ORDER BY year) > 0 THEN 'Increase'
		WHEN curr_sales - LAG(curr_sales) OVER(PARTITION BY product_name ORDER BY year) < 0 THEN 'Decrease'
		ELSE 'No Change'
	END AS prev_year_change
	FROM product_sales
	ORDER BY product_name, year

-- 4. Which category is contributing the most to overcall sales?

SELECT 
category,
sales_by_category,
SUM(sales_by_category) OVER() AS total_sales,
CONCAT(CAST(ROUND(sales_by_category/SUM(sales_by_category) OVER()*100, 2) AS DECIMAL(5,2)),'%') AS pct
FROM
	(
SELECT category, 
CAST(SUM(sales_amount) AS DECIMAL(18,0)) AS sales_by_category
FROM dbo.fact_sales s
LEFT JOIN dbo.dim_products p
ON s.product_key = p.product_key
GROUP BY category ) x
GROUP BY category, sales_by_category
ORDER BY sales_by_category DESC

-- 4. Segment products into cost ranges and count how many products
--	fall into each segment.

WITH product_segments AS
	(
SELECT product_key, product_name, cost,
CASE
	WHEN cost < 100 THEN 'Below 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	ELSE 'Above 1000'
END AS cost_range
FROM dbo.dim_products
	)
	SELECT cost_range, COUNT(product_key) AS total_products,
	SUM(cost) AS total_cost
	FROM product_segments
	GROUP BY cost_range
	ORDER BY total_cost DESC

/* 5. Group customers into three segments based on their spending behaviour:
	- VIP: Customers with at least 12 months of history and spending more than 5000
	- Regular: Customers with at least 12 months of history and spending less than 5000
	- New: Customers with a lifespan of less than 12 months.
And find the total number of customers by each group
*/

WITH customer_spending AS(
	SELECT
	c.customer_key,
	MIN(order_date) AS first_order,
	MAX(order_date)AS last_order,
	CAST(SUM(sales_amount) AS DECIMAL(18,0)) AS total_spend,
	CONCAT(
			DATEDIFF(MONTH, MIN(order_date), MAX(order_date)), ' ',
			CASE 
				WHEN DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) >= 10 THEN 'Months' 
				ELSE 'Month' 
			END
		) AS life_span
	FROM dbo.fact_sales s
	LEFT JOIN dbo.dim_customers c
	ON s.customer_key = c.customer_key
	GROUP BY c.customer_key),
	customer_segment AS(
	SELECT *,
	CASE
		WHEN CAST(PARSENAME(REPLACE(life_span, ' ', '.'), 2) AS INT) >= 12 AND total_spend >= 5000 THEN 'VIP'
		WHEN CAST(PARSENAME(REPLACE(life_span, ' ', '.'), 2) AS INT) >= 12 AND total_spend < 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment
	FROM customer_spending)
	
	SELECT customer_segment, COUNT(customer_key) AS total_customers
	FROM customer_segment
	GROUP BY customer_segment
	ORDER BY total_customers DESC
