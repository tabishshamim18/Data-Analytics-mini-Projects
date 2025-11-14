/*
=================================================================================
Product Report
=================================================================================
Purpose: 
	-This report consolidates key product metrics and behaviours

Highlights:
	1. Gather essential fields such as product name, category, subcategory and cost.
	2. Segment products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
	3. Aggregates product-level metrics:
		-total orders
		-total sales
		-total quantity sold
		-total customers(unique)
		-lifespan (in months)
	4. Calculates valuable KPIs:
		-Recency(months since last sale)
		-average order revenue
		-average monthl revenue

=================================================================================
*/

WITH Base_query AS
	(
	SELECT
		order_number,
		order_date,
		customer_key,
		sales_amount,
		quantity,
		p.product_key,
		product_name,
		category,
		subcategory,
		cost
	FROM dbo.fact_sales s
	JOIN dbo.dim_products p
	ON s.product_key = p.product_key
		WHERE order_date IS NOT NULL
		),
	product_aggregation AS
		(
	SELECT
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		COUNT(order_number) AS total_orders,
		CAST(SUM(sales_amount) AS DECIMAL(18,0)) AS total_sales,
		SUM(quantity) AS total_quantity,
		CAST(AVG(sales_amount/ NULLIF(quantity,0)) AS DECIMAL(6,0)) AS avg_selling_price,
		COUNT(DISTINCT customer_key) AS total_customers,
		MAX(order_date) AS last_order_date,
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
	FROM Base_query
	GROUP BY
		product_key,
		product_name,
		category,
		subcategory,
		cost
		)
	SELECT
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		last_order_date,
		DATEDIFF(MONTH, last_order_date, GETDATE()) AS Recency,
		CASE
			WHEN total_sales > 50000 THEN 'High Performer'
			WHEN total_sales >= 10000 THEN 'Mid-Range'
			ELSE 'Low-Performer'
		END AS product_segment,
		lifespan,
		total_orders,
		total_sales,
		total_quantity,
		total_customers,
		avg_selling_price,

		-- Average Order Revenue (AOR)
		CAST(total_sales / total_orders AS DECIMAL(5,0)) AS avg_order_revenue,

		-- Average Monthly Revenue (AOR)
		CAST(total_sales / NULLIF(lifespan,0) AS DECIMAL(15,0)) AS avg_monthly_revenue

	FROM product_aggregation