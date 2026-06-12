CREATE DATABASE Maven;

USE Maven
GO
CREATE SCHEMA stg;

CREATE TABLE stg.manhattan_property_sales (
	neighborhood VARCHAR(50),
	address VARCHAR(50),
	zip_code SMALLINT,
	building_class CHAR(2),
	sq_ft INT,
	sale_price BIGINT
);

BULK INSERT stg.manhatten_property_sales
FROM 'C:\Users\FongTony\Downloads\manhatten_property_sales.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
);

WITH avg_price_per_sqft AS (
	SELECT DISTINCT
		zip_code,
		building_class,
		AVG( CASE WHEN sale_price > 0 THEN sale_price / CAST(square_feet AS FLOAT) END) OVER (PARTITION BY zip_code, building_class) AS avg_price_sqft
	FROM stg.manhattan_property_sales
),
manhattan_market_value AS (
	SELECT
		s.neighborhood,
		s.address,
		s.zip_code,
		s.building_class,
		s.square_feet AS sq_ft,
		s.sale_price,
		CASE
			WHEN sale_price = 0 THEN s.square_feet * a.avg_price_sqft
			ELSE sale_price
		END AS market_value
	FROM
		stg.manhattan_property_sales AS s
		INNER JOIN avg_price_per_sqft AS a
		ON s.zip_code = a.zip_code AND
		s.building_class = a.building_class
)

SELECT
	COUNT(*)
FROM manhattan_market_value
WHERE market_value > 15000000
;
