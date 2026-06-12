
WITH group_streaks AS (
 -- Group consecutive dates via the (date - row_number) trick
 -- Rows with the same (date - row_number) denotes groups of dates that have a streak of consecutive days
 SELECT
 user_id,
 user_name,
 dt,
 dt - (ROW_NUMBER() OVER (PARTITION BY user_id, user_name ORDER BY dt ))::int AS consec_grp_id
 FROM
 (
 SELECT DISTINCT
 user_id,
 user_name,
 "date"::date AS dt
 FROM stg.lessonstreaks
 ORDER BY dt ASC
 )
),
streak_counts AS (
 SELECT
 user_id,
 user_name,
 MIN(dt) AS start_date,
 MAX(dt) AS end_date,
 COUNT(*)::int AS length_days
 FROM group_streaks
 GROUP BY user_id, user_name, consec_grp_id
)

SELECT * FROM streak_counts ORDER BY length_days DESC LIMIT 10;
