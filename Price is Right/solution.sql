SELECT
	trans.order_date,
	prod.name,
	trans.quantity,
	hist.price,
	(trans.quantity * hist.price) AS sub_total,
	SUM(trans.quantity * hist.price) OVER (
		ORDER BY trans.order_date ASC
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	) AS running_total
FROM
	stg.pizza_transactions AS trans
	INNER JOIN stg.pizza_products AS prod
		ON trans.pizza_id = prod.pizza_ID
	LEFT JOIN LATERAL (
		SELECT price
		FROM stg.pizza_price_history AS price_hist
		WHERE trans.pizza_id = price_hist.pizza_id
			AND price_hist.effective_date <= trans.order_date
		ORDER BY price_hist.effective_date DESC
		LIMIT 1
	) AS hist ON true
ORDER BY trans.order_date ASC
;