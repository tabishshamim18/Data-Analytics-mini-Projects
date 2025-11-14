
WITH Base_query AS
	(
	SELECT
		c.customer_key,
		CONCAT(first_name,' ', last_name) AS full_name,
		MAX(order_date) AS last_order_date,
		COUNT(DISTINCT product_key) AS products_purchased,
		DATEDIFF(MONTH, MAX(order_date), GETDATE()) AS recency_months,
		COUNT(DISTINCT order_number) AS frequency,
		CAST(SUM(sales_amount) AS DECIMAL(18,0)) AS monetary
	FROM dbo.fact_sales s
		LEFT JOIN dbo.dim_customers c
	ON s.customer_key = c.customer_key
	WHERE order_date IS NOT NULL
	GROUP BY c.customer_key, CONCAT(first_name,' ', last_name)
	),
	rfm_calculation AS
	(
	SELECT *,
		NTILE(5) OVER(ORDER BY recency_months DESC) AS recency_score,
		NTILE(5) OVER(ORDER BY frequency) AS frequency_score,
		NTILE(5) OVER(ORDER BY monetary) AS monetary_score
	FROM Base_query
	),
	Customer_segment AS
	(
	SELECT *,
		CONCAT(recency_score, frequency_score, monetary_score) AS rfm_cell,
		(recency_score + frequency_score+ monetary_score) AS rfm_score_total,
		CASE
			WHEN (recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4) THEN 'Champions'
			WHEN (recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3) THEN 'Loyal Customers'
			WHEN (recency_score >= 3 AND frequency_score >= 1 AND monetary_score >= 2) THEN 'Potential Loyalists'
			WHEN (recency_score >= 2 AND frequency_score >= 2 AND monetary_score >= 2) THEN 'Recent Customers'
			WHEN (recency_score >= 2 AND frequency_score <= 2 AND monetary_score <= 2) THEN 'Needs Attention'
			WHEN (recency_score <= 2 AND frequency_score >= 3 AND monetary_score >= 3) THEN 'At Risk'
			WHEN (recency_score <= 1 AND frequency_score <= 1 AND monetary_score <= 1) THEN 'Hibernating'
			ELSE 'Lost Customers'
		END AS rfm_segment
	FROM rfm_calculation
	)

	-- Customer Segment ASnalysis
	/* 1. Segment Distribution
	SELECT rfm_segment,
	COUNT(DISTINCT customer_key) AS total_customers
	FROM Customer_segment
	GROUP BY rfm_segment
	ORDER BY total_customers */

	SELECT rfm_segment,
	SUM(monetary) AS total_sales
	FROM Customer_segment
	GROUP BY rfm_segment
	ORDER BY total_sales DESC