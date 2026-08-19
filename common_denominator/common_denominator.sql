CREATE TABLE IF NOT EXISTS stg.campaign_performance (
	campaign_name VARCHAR(50),
	channel VARCHAR(50),
	impressions VARCHAR(15),
	ctr VARCHAR(10)
);

SELECT * FROM stg.campaign_performance LIMIT 10;

WITH campaign_cte AS (
	SELECT
		campaign_name,
		channel,
		REPLACE(impressions, ',', '')::NUMERIC AS impressions,
		REPLACE(ctr, '%', '')::NUMERIC / 100 AS ctr
	FROM stg.campaign_performance
),
clicks_cte AS (
	SELECT
		campaign_name,
		channel,
		impressions,
		ctr * impressions AS clicks
	FROM campaign_cte
)

SELECT
	channel,
	SUM(clicks) / SUM(impressions) * 100.0 AS ctr
FROM clicks_cte
GROUP BY channel
HAVING SUM(clicks) / SUM(impressions) * 100.0 > 4.0
;

