CREATE TABLE IF NOT EXISTS stg.users (
	user_id SMALLINT PRIMARY KEY,
	country VARCHAR(50),
	timezone VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS stg.tickets (
	ticket_id SMALLINT PRIMARY KEY,
	user_id SMALLINT REFERENCES stg.users(user_id),
	submitted_at_utc TIMESTAMPTZ
);

SELECT * FROM stg.users LIMIT 100;
SELECT * FROM stg.tickets LIMIT 100;

SELECT DISTINCT
	SUBSTRING(timezone FROM 4 FOR 7) AS tzone
FROM stg.users
LIMIT 100;

WITH local_time_cte AS (
	SELECT
		t.ticket_id,
		u.user_id,
		t.submitted_at_utc AS Time_UTC,
		SUBSTRING( u.timezone FROM 4 FOR 4 ) || ' hours' AS adj,
		t.submitted_at_utc + (SUBSTRING( u.timezone FROM 4 FOR 4 ) || ' hours')::INTERVAL AS Time_Local
		--t.submitted_at_utc AT TIME ZONE u.timezone AS local_tz
	FROM stg.tickets AS t
	LEFT JOIN stg.users AS u
		ON t.user_id = u.user_id
)

SELECT
	EXTRACT( HOUR FROM Time_Local ) AS hr,
	COUNT(*) AS ticket_submissions
FROM local_time_cte
GROUP BY 1
ORDER BY ticket_submissions DESC
LIMIT 1
;
