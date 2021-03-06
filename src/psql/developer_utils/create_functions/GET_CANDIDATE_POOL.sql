CREATE OR REPLACE FUNCTION GET_CANDIDATE_POOL
(
	EXPERIMENT_GROUP_ID BIGINT,
	NUMBER_RECENT INT,
	NUMBER_BEST INT,
	NUMBER_RANDOM INT
)
RETURNS TABLE
(
	EXPERIMENT_ID BIGINT,
	SCORE REAL
)
AS
$$
	
	-- THIS COULD BE MADE FASTER THROUGH THE USE OF GENERATION NUMBERS, 
	-- RATHER THAN CHECKING TO ENSURE THAT EACH EXPERIMENT ACTUALLY HAS CORRESPONDING RESULTS, 
	-- WE COULD SIMPLY KNOW THAT ALL EXPERIMENTS FROM THE PREVIOUS GENERATION HAVE COMPLETED.
	
	-- RANDOM CONTENDERS
	SELECT
		EXPERIMENT_ID,
		SCORE
	FROM
		GET_RANDOM_EXPERIMENTS(EXPERIMENT_GROUP_ID, NUMBER_RANDOM)

	-- BEST CONTENDERS
	UNION ALL
	SELECT
		EXPERIMENT_ID,
		SCORE
	FROM
		GET_BEST_EXPERIMENTS(EXPERIMENT_GROUP_ID, NUMBER_BEST)
	
	-- RECENT CONTENDERS  
	UNION ALL
	SELECT
		EXPERIMENT_ID,
		SCORE
	FROM
		GET_RECENT_EXPERIMENTS(EXPERIMENT_GROUP_ID, NUMBER_RECENT);
$$
LANGUAGE SQL;
