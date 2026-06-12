
WITH mlb_cte AS (
SELECT
name,
REGEXP_SPLIT_TO_TABLE(Position, '/') AS Position
FROM stg.mlb
)

SELECT
Position,
COUNT(*) AS Players
FROM mlb_cte
GROUP BY Position
ORDER BY Players DESC
;
