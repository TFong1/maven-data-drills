Sharing my solution to the @Maven Analytics data drill: Full Assembly

The dataset contains order records for six bicycle models, along with a bill of materials (BOM) describing how each model breaks down into subassemblies, and those subassemblies broken down further. The task is to calculate the total quantity of each individual part required to fulfill all orders in the dataset.

To solve this problem, I created a recursive CTE. Typically, problems involving tree hierarchies are solved using recursive CTEs. A recursive CTE consists of two parts (anchor & recursive) that are merged using the UNION ALL statement. The first part, the anchor member, is the non-recursive part of the query that provides the initial rows in the result set. In this case, this is the query that contains the top level elements of the tree which are the items ordered in the bike_orders table (e.g., Trailhawk 700, Coastal Cruiser, etc.). The recursive member traverses down the hierarchy where the parts have as their parent item the distinct bike models in the bike_orders table. And if the parts are subassemblies, then the recursive member will traverse down the tree again where the individual parts have the subassemblies as parents, and so on.

To display a result set containing only individual parts, I filter out the parts that are not parent_items in the bike_bom table.

Check out my solution written in Postgres SQL:

WITH RECURSIVE individual_parts AS (
	-- Anchor: Start with product item orders
	SELECT
		bike_model AS part,
		SUM(quantity) AS quantity
	FROM stg.bike_orders
	GROUP BY bike_model

	UNION ALL

	-- Recursion: Join to BOM to find children and multiply quantities
	SELECT
		b.child_item AS part,
		(ip.quantity * b.quantity_per) AS quantity
	FROM individual_parts AS ip
	JOIN stg.bike_bom AS b
		ON ip.part = b.parent_item
)

-- Aggregate final parts, filtering for leaf nodes only

SELECT
	part,
	SUM(quantity) AS quantity
FROM individual_parts
WHERE part NOT IN (SELECT DISTINCT parent_item FROM stg.bike_bom)
GROUP BY part
ORDER BY quantity DESC
;

The answer to the question, "How many M5x20 Hex Bolts are needed in total to fulfill every order in the dataset?" is 59642.

#SQL #MavenDataDrill #data #analytics #PostgreSQL
