CREATE TABLE IF NOT EXISTS stg.hotelbookings (
	booking_id int,
	booking_date DATE,
	cancel_date DATE,
	checkin_date DATE,
	checkout_date DATE,
	is_canceled INT
);

--------------------------------------

SELECT
	booking_id,
	GENERATE_SERIES(
		checkin_date,
		checkout_date - INTERVAL '1 day',
		INTERVAL '1 day'
	)::date AS room_night
FROM stg.hotelbookings
WHERE is_canceled = 0;

------------------------------------------------

WITH RECURSIVE ExpandBookings AS (
	SELECT
		booking_id,
		checkin_date AS room_night,
		checkout_date
	FROM stg.hotelbookings
	WHERE is_canceled = 0

	UNION ALL

	SELECT
		booking_id,
		(room_night + INTERVAL '1 day')::date AS room_night,
		checkout_date
	FROM ExpandBookings
	WHERE (room_night + INTERVAL '1 day')::date < checkout_date
),
DailyOccupancy AS (
	SELECT
		room_night,
		COUNT(*) AS Bookings,
		200 AS Capacity,
		EXTRACT( MONTH FROM room_night ) AS room_month,
		EXTRACT( YEAR FROM room_night ) AS room_year
	FROM ExpandBookings
	GROUP BY room_night
),
MonthlyOccupancy AS (
	SELECT
		room_month,
		room_year,
		SUM(Bookings) AS Bookings,
		SUM(Capacity) AS Capacity,
		FLOOR( (SUM(Bookings) / SUM(Capacity) * 100.0)::NUMERIC ) AS Occupancy
	FROM DailyOccupancy
	GROUP BY room_year, room_month
)

SELECT * FROM MonthlyOccupancy
WHERE room_month = 7 AND room_year = 2016
ORDER BY room_year, room_month;
