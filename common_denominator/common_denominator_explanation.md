Sharing my solution to the @Maven Analytics data drill: Common Denominator.

Given a dataset of campaign performance summary for an outdoor gear brand covering 50 campaigns across 5 marketing channels (including impression volume and click-through rate (CTR) for each campaign), calculate the click-through rate for each channel and for the account as a whole.

To solve this problem, created two CTEs. The first one, campaign_cte, simply converts the impressions and CTR to numeric values to make them easier to do calculations. The clicks_cte calculates the number of clicks from each campaign. The CTR is calculated by taking the number of clicks divided by the number of impressions. So to calculate the number of clicks per campaign, simply multiply the CTR by the number of impressions. The main query calculates the CTR GROUPed BY each channel.

The question for this data drill is: "How many channels have a click-through rate of at least 4%?" To answer this question, we filter the GROUP BY query with HAVING SUM(clicks) / SUM(impressions) * 100.0 > 4.0.

The answer is one (Paid Search channel with 4.43% CTR).

Check out my solution written in Postgres SQL:

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
HAVING SUM(clicks) / SUM(impressions) * 100.0 > 4.0;

#SQL #MavenDataDrill #data #analytics #PostgreSQL