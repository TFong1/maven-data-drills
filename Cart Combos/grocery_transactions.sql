
CREATE TABLE IF NOT EXISTS stg.grocery_transactions (
	transaction_id INT,
	transaction_datetime TIMESTAMP,
	register INT,
	line_item INT,
	upc BIGINT,
	product_name TEXT,
	quantity INT,
	unit_price NUMERIC(10,2)
);

WITH transaction_cte AS (
	SELECT DISTINCT
		transaction_id,
		product_name
	FROM stg.grocery_transactions
	ORDER BY transaction_id ASC, product_name ASC
),
grouped_products AS (
	SELECT
		t1.transaction_id,
		t1.product_name AS product_1,
		t2.product_name AS product_2
	FROM
		transaction_cte AS t1
	JOIN
		transaction_cte AS t2
		ON 
			t1.transaction_id = t2.transaction_id
			AND t1.product_name < t2.product_name
)
SELECT
	product_1,
	product_2,
	COUNT(*) AS quantity
FROM grouped_products
GROUP BY product_1, product_2
ORDER BY quantity DESC
LIMIT 5
;
