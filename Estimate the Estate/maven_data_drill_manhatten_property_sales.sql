CREATE TABLE IF NOT EXISTS stg.manhatten_property_sales (
	neighborhood TEXT,
	address TEXT,
	zip_code smallint,
	building_class character(2),
	sq_ft integer,
	sale_price bigint
);

WITH avg_price_per_sqft AS (
	SELECT DISTINCT
		zip_code,
		building_class,
		--sale_price / sq_ft AS price_sqft,
		AVG (sale_price / sq_ft) FILTER (WHERE sale_price > 0) OVER (PARTITION BY zip_code,building_class) AS avg_price_sqft
	FROM stg.manhatten_property_sales
	--ORDER BY zip_code, building_class
),
manhatten_market_value AS (
	SELECT
		s.neighborhood,
		s.address,
		s.zip_code,
		s.building_class,
		s.sq_ft,
		s.sale_price,
		CASE
			WHEN sale_price = 0 THEN s.sq_ft * a.avg_price_sqft
			ELSE sale_price
		END AS market_value
	FROM
		stg.manhatten_property_sales AS s
		INNER JOIN avg_price_per_sqft AS a
		ON s.zip_code = a.zip_code AND
		s.building_class = a.building_class
)

SELECT * FROM manhatten_market_value
WHERE market_value > 15000000
;
