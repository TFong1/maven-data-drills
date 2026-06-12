
CREATE TABLE stg.marathon (
	age INT,
	gender CHAR,
	split TIME,
	final TIME
);

SELECT
	"Finish Band",
	COUNT(*) AS Runners,
	FLOOR( COUNT(*) * 100.0 / (SELECT COUNT(*) FROM stg.marathon) ) AS "% of Field"
FROM (
	SELECT
		CASE
			WHEN final < '3:00:00' THEN 'Sub 3:00'
			WHEN (final >= '3:00:00'::TIME) AND (final < '3:30:00'::TIME) THEN '3:00 - 3:30'
			WHEN (final >= '3:30:00'::TIME) AND (final < '4:00:00'::TIME) THEN '3:30 - 4:00'
			WHEN (final >= '4:00:00'::TIME) AND (final < '4:30:00'::TIME) THEN '4:00 - 4:30'
			WHEN (final >= '4:30:00'::TIME) AND (final < '5:00:00'::TIME) THEN '4:30 - 5:00'
			WHEN (final >= '5:00:00'::TIME) AND (final < '5:30:00'::TIME) THEN '5:00 - 5:30'
			WHEN (final >= '5:30:00'::TIME) AND (final < '6:00:00'::TIME) THEN '5:30 - 6:00'
			ELSE '6:00+'
		END AS "Finish Band"
	FROM stg.marathon
) AS Grouped_Runners
GROUP BY "Finish Band"
ORDER BY
	CASE "Finish Band"
		WHEN 'Sub 3:00' THEN 1
		WHEN '3:00 - 3:30' THEN 2
		WHEN '3:30 - 4:00' THEN 3
		WHEN '4:00 - 4:30' THEN 4
		WHEN '4:30 - 5:00' THEN 5
		WHEN '5:00 - 5:30' THEN 6
		WHEN '5:30 - 6:00' THEN 7
		WHEN '6:00+' THEN 8
	END
;
