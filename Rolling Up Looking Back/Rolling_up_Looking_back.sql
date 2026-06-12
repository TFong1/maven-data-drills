
ALTER TABLE stg.coffee_shop_sales
    ADD COLUMN Month CHAR(3)
;

-- SELECT EXTRACT(MONTH FROM date::date) AS Month FROM stg.coffee_shop_sales;

-- SELECT to_char(date::DATE, 'Mon') AS Month FROM stg.coffee_shop_sales;

UPDATE stg.coffee_shop_sales
    SET month = to_char(date::DATE, 'Mon')
;

ALTER TABLE stg.coffee_shop_sales
    ADD COLUMN intMon INTEGER
;

UPDATE stg.coffee_shop_sales
    SET intMon = EXTRACT(MONTH FROM date::DATE)
;

SELECT DISTINCT month FROM stg.coffee_shop_sales;

SELECT * FROM stg.coffee_shop_sales;

WITH monthly_sales_cte AS (
    SELECT
        month,
        intmon,
        store,
        SUM(sales) AS Sales
        --LAG(Sales,1) OVER (PARTITION BY store ORDER BY intmon ASC) AS last_month_sales
    FROM stg.coffee_shop_sales
    GROUP BY month, intmon, store
    ORDER BY intmon ASC
    /*
        CASE month
            WHEN 'Jan' THEN 1
            WHEN 'Feb' THEN 2
            WHEN 'Mar' THEN 3
            WHEN 'Apr' THEN 4
            WHEN 'May' THEN 5
            WHEN 'Jun' THEN 6
            ELSE 7
        END
    */
)

SELECT
    month,
    store,
    sales,
    COALESCE( sales - LAG(sales,1) OVER (PARTITION BY store ORDER BY intmon ASC) ,0) AS last_month
FROM monthly_sales_cte
ORDER BY store ASC, intmon ASC
;
