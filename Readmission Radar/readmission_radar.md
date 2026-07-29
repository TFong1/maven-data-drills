
Sharing my solution to the Maven Analytics data drill: Readmission Radar

Given a dataset containing 623 inpatient stay records from a small hospital, calculate the hospital's 30-day readmission rate.

To solve this problem, I created a CTE that includes patient ID, date of admission, date of discharge, the previous discharge date, and the number of days between the current admission date and the previous discharge date. The LAG() window function is used to retrieve the previous discharge date partitioned by the patient_id and sorted by the discharge_date in ascending order.

Once the CTE has been created, I just count the number of records that have a 30 days or less from the previous discharge date and divide that number by the total number of records (623) to get the readmission rate.

Check out my solution below:

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

#SQL #MavenDataDrill #data #analytics #Postgres