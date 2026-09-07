CREATE TABLE IF NOT EXISTS stg.bike_bom (
	parent_item VARCHAR(30),
	child_item VARCHAR(30),
	quantity_per SMALLINT
);

CREATE TABLE IF NOT EXISTS stg.bike_orders (
	order_id INT PRIMARY KEY,
	order_date DATE,
	bike_model VARCHAR(30),
	quantity SMALLINT
);

WITH RECURSIVE individual_parts AS (
	-- Anchor: Start with aggregated orders
	SELECT
		bike_model AS part,
		SUM(quantity) AS quantity
	FROM stg.bike_orders
	GROUP BY bike_model

	UNION ALL

	-- Recursion: Join to BOM to find children and multiply quantities
	SELECT
		b.child_item AS part,
		(ip.quantity * b.quantity_per) AS quantity
	FROM individual_parts AS ip
	JOIN stg.bike_bom AS b
		ON ip.part = b.parent_item
)

--SELECT * FROM individual_parts;

-- Aggregate final parts, filtering for leaf nodes only

SELECT
	part,
	SUM(quantity) AS quantity
FROM individual_parts
WHERE part NOT IN (SELECT DISTINCT parent_item FROM stg.bike_bom)
GROUP BY part
ORDER BY quantity DESC
;

/*
SELECT ip.part, SUM(ip.quantity) AS quantity
FROM individual_parts ip
LEFT JOIN stg.bike_bom b ON ip.part = b.parent_item
WHERE b.parent_item IS NULL -- Keeps only items that are never parents
GROUP BY ip.part
ORDER BY quantity DESC;
*/