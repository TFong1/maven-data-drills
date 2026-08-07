Sharing my solution to the @Maven Analytics data drill: Time Shift.

Given a dataset containing 22,000 support tickets from 700 users spread across 20 countries, each timestamped in UTC. The objective is to convert each ticket to it's user's local time and calculate the ticket volume by the local hour of the day (0-23) across the dataset.

To solve this problem, I created a common table expression (CTE) that converts the UTC timestamp to the local timestamp. I extracted the timezone differential (+03) in hours from the timezone column in the users table. Then I add (or subtract) the hour differential to the submitted_at_utc column to get the local time. In Postgres, you can do this by casting the differential hours to the INTERVAL data type. For example, t.submitted_at_utc + ('-03 hours')::INTERVAL will subtract 3 hours from the UTC timestamp.

Check out my solution written in Postgres SQL:

WITH local_time_cte AS (
	SELECT
		t.ticket_id,
		u.user_id,
		t.submitted_at_utc AS Time_UTC,
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

The following is the result of the query:

| hr | ticket_submissions |
| --- | --- |
| 10 | 3985 |

Now to answer the question for this challenge:

What local hour has the most ticket submissions?

The answer is hour 10.

#SQL #MavenDataDrill #data #analytics #PostgreSQL