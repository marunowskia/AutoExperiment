CREATE OR REPLACE FUNCTION GENERATE_SEED_EXPERIMENTS(PARAM_EXPERIMENT_GROUP_ID BIGINT) RETURNS VOID
AS
$$
DECLARE EXPERIMENTS_TO_CREATE INT;
DECLARE NEWLY_CREATED_EXPERIMENT_ID BIGINT;
BEGIN

	
	SELECT
		GC.STARTING_POPULATION_SIZE - COUNT(*) INTO EXPERIMENTS_TO_CREATE
	FROM
		EXPERIMENT_GROUP EG
	LEFT JOIN
		EXPERIMENT E
	ON
		E.EXPERIMENT_GROUP_ID = EG.ID
	JOIN
		GROUP_CONFIG GC
	ON
		GC.ID = EG.GROUP_CONFIG_ID
	WHERE
		EG.ID = PARAM_EXPERIMENT_GROUP_ID
	GROUP BY
		GC.STARTING_POPULATION_SIZE;

	RAISE NOTICE 'CREATEING % EXPERIMENTS' , EXPERIMENTS_TO_CREATE;

	IF EXPERIMENTS_TO_CREATE > 0 THEN

		INSERT INTO EXPERIMENT ( EXPERIMENT_GROUP_ID)
		VALUES ( PARAM_EXPERIMENT_GROUP_ID )
		RETURNING ID INTO NEWLY_CREATED_EXPERIMENT_ID;
		
		PERFORM FILL_IN_MISSING_PARAMETERS(NEWLY_CREATED_EXPERIMENT_ID);
		
		PERFORM GENERATE_SEED_EXPERIMENTS(PARAM_EXPERIMENT_GROUP_ID); -- SAFE, BUT I/O HEAVY WAY TO GUARANTEE WE DON'T OVERFILL THE STARTING POPULATION FOR THIS EXPERIMENT_GROUP
	END IF;
END
$$
LANGUAGE PLPGSQL;	