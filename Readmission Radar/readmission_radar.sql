CREATE TABLE IF NOT EXISTS stg.inpatient_admissions (
	admission_id CHAR(8) PRIMARY KEY,
	patient_id CHAR(5),
	admission_date DATE,
	discharge_date DATE
);

SELECT '2025-02-05'::DATE - '2025-03-07'::DATE;

WITH readmission_cte AS (
	SELECT
		patient_id,
		admission_date,
		discharge_date,
		LAG(discharge_date) OVER (PARTITION BY patient_id ORDER BY admission_date) AS prev_discharge,
		admission_date - LAG(discharge_date) OVER (PARTITION BY patient_id ORDER BY admission_date) AS date_diff
	FROM stg.inpatient_admissions
	ORDER BY patient_id, admission_date
)

SELECT
	FLOOR(
		(SELECT COUNT(*) FROM readmission_cte WHERE date_diff <= 30)::NUMERIC / 
		(SELECT COUNT(*) FROM stg.inpatient_admissions) 
		* 100
	)
	AS readmission_rate
;

/*
SELECT
	*
FROM readmission_cte
WHERE date_diff <= 30
;

SELECT COUNT(*) FROM stg.inpatient_admissions;
*/
