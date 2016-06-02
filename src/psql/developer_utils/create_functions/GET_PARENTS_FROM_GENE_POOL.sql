


CREATE OR REPLACE FUNCTION GET_PARENTS_FROM_GENE_POOL(EXPERIMENT_GROUP_ID BIGINT) RETURNS TABLE (EXPERIMENT_PARENT_ALPHA BIGINT, EXPERIMENT_PARENT_BETA BIGINT)
AS
$$
DECLARE NUMBER_RECENT INT;
DECLARE NUMBER_BEST INT;
DECLARE NUMBER_RANDOM INT;
DECLARE PERFORMANCE_BIAS INT;
DECLARE CANDIDATE_POOL_SIZE INT;
BEGIN
	SELECT
		GC.NUMBER_OF_RECENT_CONTENDERS,
		GC.NUMBER_OF_RANDOM_CONTENDERS,
 		GC.NUMBER_OF_BEST_CONTENDERS,
 		GC.PERFORMANCE_BIAS
 	INTO
		NUMBER_RECENT,
		NUMBER_RANDOM,
		NUMBER_BEST,
		PERFORMANCE_BIAS
	FROM
		EXPERIMENT_GROUP EG
	JOIN	
		GROUP_CONFIG GC
	ON
		GC.ID = EG.GROUP_CONFIG_ID
	WHERE
		EG.ID = EXPERIMENT_GROUP_ID;

	CREATE TEMPORARY TABLE CANDIDATE_POOL (EXPERIMENT_ID BIGINT, SCORE REAL) ON COMMIT DROP;

	INSERT INTO CANDIDATE_POOL
	SELECT
		GCP.EXPERIMENT_ID, 
		GCP.SCORE
	FROM
		GET_CANDIDATE_POOL
		(
			EXPERIMENT_GROUP_ID,
			NUMBER_RECENT,
			NUMBER_BEST,
			NUMBER_RANDOM
		) GCP;


	SELECT
		COUNT(*) INTO CANDIDATE_POOL_SIZE
	FROM
		CANDIDATE_POOL;
		

	RETURN QUERY
	SELECT
		(
			SELECT
				CP.EXPERIMENT_ID
			FROM
				CANDIDATE_POOL CP
			ORDER BY
				SCORE DESC
			OFFSET 
				FLOOR(COMPUTE_BIAS_COEFFICIENT(PERFORMANCE_BIAS) * CANDIDATE_POOL_SIZE)
			LIMIT 1
		) AS EXPERIMENT_PARENT_ALPHA,
		(
			SELECT
				CP.EXPERIMENT_ID
			FROM
				CANDIDATE_POOL CP
			ORDER BY
				SCORE DESC
			OFFSET 
				FLOOR(COMPUTE_BIAS_COEFFICIENT(PERFORMANCE_BIAS) * CANDIDATE_POOL_SIZE)
			LIMIT 1
		) AS EXPERIMENT_PARENT_BETA;
		
END
$$
LANGUAGE PLPGSQL