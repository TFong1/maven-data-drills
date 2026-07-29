
Sharing my solution to the Maven Analytics data drill: Final Form.

You are given a dataset containing responses from an employee satisfaction form. The objective is to isolate each employee's most recent response and count how many employees fall into each satisfaction rating.

To solve this problem, I create a CTE, use the ROW_NUMBER() Window function to partition the responses by e-mail address and sort them by the response timestamp. I sort the responses by timestamp in descending order so that the latest response will always occupy row #1.

When I query the CTE, I get the count for each rating where the ROW_NUMBER() is one.

Check out my solution written in SQL:

WITH employee_satisfaction_ratings AS (
	SELECT
		email,
		satisfaction,
		ROW_NUMBER() OVER (PARTITION BY email ORDER BY "Timestamp" DESC) AS rn
	FROM
		stg.employee_satisfaction
)
SELECT
	satisfaction,
	COUNT(*) AS Employees
FROM employee_satisfaction_ratings
WHERE rn = 1
GROUP BY satisfaction
ORDER BY satisfaction ASC
;

The following is the result of the query:

| satisfaction | Employees |
| --- | --- |
| 1 | 19 |
| 2 | 34 |
| 3 | 52 |
| 4 | 83 |
| 5 | 89 |

Now to answer the question to this challenge:
How many employees reported satisfaction scores of "1" on their most recent survey responses?

The answer is "19".

#SQL #MavenDataDrill #data #analytics
