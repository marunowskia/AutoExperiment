CREATE OR REPLACE FUNCTION get_active_experiment_group()
RETURNS bigint AS
$$
BEGIN
	RETURN
	(
		SELECT
			EG.ID
		FROM
			EXPERIMENT_GROUP EG
		LEFT JOIN
			EXPERIMENT E
		ON
			EG.ID = E.EXPERIMENT_GROUP_ID
		GROUP BY
			EG.ID, 
			EG.MAX_EXPERIMENT_COUNT 
		HAVING
			COUNT(*) < EG.MAX_EXPERIMENT_COUNT
			-- this approach is not well suited to large scale experiment databases (1 million experiments or more)
			-- may want replace this solution with an approach that decrements a "REMAINING_EXPERIMENTS" column on the EXPERIMENT_GROUP table
		LIMIT 1
	);	
END
$$
LANGUAGE plpgsql