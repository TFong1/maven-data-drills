
WITH rolling_avg AS (
 SELECT
 "Date",
 "Close Price",
 ROUND( AVG("Close Price") OVER (
 ORDER BY "Date" ASC
 ROWS BETWEEN 49 PRECEDING AND CURRENT ROW), 2
 ) AS fifty_avg,
 ROUND( AVG("Close Price") OVER (
 ORDER BY "Date" ASC
 ROWS BETWEEN 199 PRECEDING AND CURRENT ROW), 2
 ) AS twoH_avg
 FROM stg.spy_close_price
 ORDER BY "Date" ASC
),
Golden_Cross AS (
 SELECT
 "Date",
 "Close Price",
 fifty_avg AS "50-Day Avg",
 twoH_avg AS "200-Day Avg",
 CASE
 WHEN
 ( fifty_avg > twoH_avg ) AND
 ( LAG(fifty_avg) OVER (ORDER BY "Date" ASC) <= LAG(twoH_avg) OVER (ORDER BY "Date" ASC) )
 THEN 1
 ELSE 0
 END AS "Golden Cross"
 FROM rolling_avg
)

SELECT *
FROM Golden_Cross
WHERE "Golden Cross" = 1
ORDER BY "Date" DESC
;
