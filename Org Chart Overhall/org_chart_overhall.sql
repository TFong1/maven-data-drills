
--SELECT * FROM stg.employees;

WITH RECURSIVE org_chart_cte AS (
      -- Anchor member
      SELECT
            employee_name,
            manager_name,
            employee_name AS reporting_hierarchy
      FROM stg.employees
      WHERE manager_name IS NULL
      UNION ALL
      -- Recursive
      SELECT
            e.employee_name,
            e.manager_name,
            CONCAT( occ.reporting_hierarchy, ' > ', e.employee_name ) AS reporting_hierarchy
      FROM stg.employees AS e, org_chart_cte AS occ
      WHERE e.manager_name = occ.employee_name
),
direct_reports AS (
      SELECT
            manager_name,
            COUNT(*) AS direct_reports
      FROM stg.employees
      WHERE manager_name IS NOT NULL
      GROUP BY manager_name
)

WITH RECURSIVE total_reports AS (
      -- Anchor member
      SELECT
            manager_name AS root_manager_name,
            employee_name AS employee_name
      FROM stg.employees
      WHERE manager_name IS NOT NULL
      UNION ALL
      -- Recursive
      SELECT
            tr.root_manager_name,
            e.employee_name
      FROM total_reports AS tr
      JOIN stg.employees AS e
            ON e.manager_name = tr.employee_name
)


--SELECT * FROM org_chart_cte;
--SELECT * FROM direct_reports;
--SELECT * FROM total_reports;

SELECT
      m.employee_name AS manager_name,
      COUNT(tr.employee_name) AS total_reports
FROM 
      stg.employees m
      LEFT JOIN total_reports AS tr
            ON m.employee_name = tr.root_manager_name
WHERE
      EXISTS(
            SELECT 1 FROM stg.employees AS e WHERE e.manager_name = m.employee_name
      )
GROUP BY m.employee_name
;

SELECT
      occ.employee_name,
      occ.manager_name,
      occ.reporting_hierarchy,
      COALESCE( dr.direct_reports, 0 ) AS direct_reports
FROM
      org_chart_cte AS occ
      LEFT JOIN direct_reports AS dr
            ON occ.employee_name = dr.manager_name
;
