
Sharing my solution to the Maven Analytics data drill: Cart Combos.

The objective is to identify the five product pairs that are purchased together the most frequently from a dataset containing one year of point-of-sales from a grocery store.

To solve this problem, I created two CTEs in Postgres SQL.

The first CTE (transaction_cte) simply removes the duplicates of the same product within any given transaction using DISTINCT and sorts them in alphabetical order. Sorting product_name in alphabetical order is important because when we expand the combinations of pairs of products for each transaction, we don't create the same product pairs as separate rows. In other words, we don't have a situation where one transaction lists product A first and product B second and another transaction lists product B first and product A second. Both of these transactions should count as the same pair of products rather than as separate product pairings.

The second CTE (grouped_products) expands the combinations of each pair of products within each transaction into its own row. This is accomplished by self joining the grocery_transactions table with itself. To accomplish this, we make sure the products are within the same transaction_id and the t1.product_name < t2.product_name. The t1.product_name < t2.product_name allows us to prevent duplicate product pairings to be counted as two separate pairings instead of two instances of the same product pairing. Because we sorted the transaction_cte in alphabetical order, we make sure that all product pairings are taken into account without introducing duplicates.

Check out my solution:

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
