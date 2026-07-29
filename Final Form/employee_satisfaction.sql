
CREATE TABLE IF NOT EXISTS stg.employee_satisfaction (
	"Timestamp" TIMESTAMP,
	email VARCHAR(30),
	satisfaction SMALLINT
);

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
