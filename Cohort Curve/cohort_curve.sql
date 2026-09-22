CREATE TABLE IF NOT EXISTS stg.streaming_subscriptions (
	subscription_id INT,
	customer_id INT,
	created_date DATE,
	canceled_date DATE
);

SELECT
	MAX(created_date) AS max_created_date,
	MAX(canceled_date) AS max_canceled_date
FROM stg.streaming_subscriptions;

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
