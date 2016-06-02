CREATE OR REPLACE FUNCTION GET_RANDOM_CONTENDERS(PARAM_EXPERIMENT_GROUP_ID BIGINT, NUMBER_TO_RETURN INT) 
RETURNS TABLE (EXPERIMENT_ID BIGINT, SCORE REAL)
AS
$$
BEGIN
	SELECT
		E.ID,
		E.MEAN_SCORE AS SCORE
	FROM
		EXPERIMENT E
	WHERE
		E.EXPERIMENT_GROUP_ID = PARAM_EXPERIMENT_GROUP_ID
	AND
		TOTAL_TRIALS > 0
	ORDER BY
		RANDOM()
	LIMIT 
		NUMBER_TO_RETURN;
		-- VERY SLOW FOR LARGE DATA SETS.
		-- ALTERNATIVE APPROACH: ONLY ALLOW A SINGLE EXPERIMENT_GROUP TO BE ACTIVE AT A TIME, ENSURING CONTIGUOUS EXPERIMENT.ID VALUES. 
		-- GIVEN CONTIGUOUS IDS, SIMPLY COMPUTE A RANBDOM ID VIA RANDOM() * (THE NUMBER OF EXPERIMENTS IN THE GROUP)
END
$$
LANGUAGE PLPGSQL