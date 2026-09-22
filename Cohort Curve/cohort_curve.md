Sharing my solution to the @Maven Analytics data drill: Cohort Curve

Given a dataset with approximately 19,000 subscription records for a monthly streaming service, group subscribers into cohorts by signup month and calculate each cohort's retention rate after 1 month, 2 months, 3 months, and so on.

My solution involves creating 2 CTEs. The first CTE represents the November 2025 cohort, which is defined as those subscriptions that started on November 2025. The question later addresses the retention rate for the November 2025 cohort. The second CTE computes the number of months between the created_date and canceled_date in the November 2025 cohort. The calculation involves computing the number of years * 12 plus the number of months (without taking into account the number of years). The main query computes the retention rate for the November 2025 cohort which is the number of renewals divided by the number of records in the November 2025 cohort CTE. Computing the number of renewals isn't as simple as counting the number of rows grouped by the number of renewals. This is because the number of 3-month renewals isn't just the number of 3-month renewals; it has to include the number of 4-month, 5-months renewals, and so on as well. To do the proper calculation, we have to use SUM(number of renewals) OVER (the November 2025 cohort in descending order). The FLOOR() function is used because the question asks for the percentage rounded down to the nearest whole percentage point.

Check out my solution written in PostgreSQL:

WITH nov_2025_cohort AS (
	SELECT
		subscription_id,
		customer_id,
		created_date,
		canceled_date
	FROM
		stg.streaming_subscriptions
	WHERE
		EXTRACT(MONTH FROM created_date) = 11 AND
		EXTRACT(YEAR FROM created_date) = 2025
),
nov_2025_cohort_renewals AS (
	SELECT
		subscription_id AS "Sub ID",
		created_date AS Signup,
		canceled_date AS Cancellation,
		EXTRACT(YEAR FROM AGE(COALESCE(canceled_date, '2026-08-03'), created_date)) * 12 +
		EXTRACT(MONTH FROM AGE(COALESCE(canceled_date, '2026-08-03'), created_date)) AS Renewals
	FROM nov_2025_cohort
)

SELECT
	Renewals AS "Months Since Signup",
	FLOOR(
		SUM(num_renewals) OVER (ORDER BY Renewals DESC) /
		(SELECT COUNT(*) FROM nov_2025_cohort)::NUMERIC * 100.0
	) AS "Retention Rate"
FROM (
	SELECT Renewals, COUNT(*) AS num_renewals
	FROM nov_2025_cohort_renewals
	GROUP BY Renewals
) AS nov_2025_renewals
WHERE Renewals > 0
ORDER BY Renewals ASC
;

Now, to answer the question "What was the 3-month retention rate for the November 2025 cohort? (Round down to the nearest whole percentage point)" Below is the result set from the above query:

| Months Since Signup | Retention Rate |
| --- | --- |
| 1 | 54 |
| 2 | 38 |
| 3 | 30 |
| 4 | 23 |
| 5 | 19 |
| 6 | 16 |
| 7 | 13 |
| 8 | 11 |
| 9 |  1 |

The answer is "30%."

#SQL #MavenDataDrill #data #analytics #PostgreSQL
