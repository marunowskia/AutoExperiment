CREATE OR REPLACE FUNCTION RECORD_EXPERIMENT_RESULT(EXPERIMENT_ID BIGINT, SCORE REAL, DATA TEXT) RETURNS VOID
AS
$$
BEGIN
	INSERT INTO RESULT
	(
		EXPERIMENT_ID,
		SCORE,
		DATA
	)
	VALUES
	(
		EXPERIMENT_ID,
		SCORE,
		DATA
	);

-- 	THIS NEEDS TO BE REPLACED BY AN "AFTER INSERT" TRIGGER
--	UPDATE EXPERIMENT
--	SET
--		NET_SCORE = NET_SCORE + NEW_SCORE,
--		TOTAL_TRIALS = TOTAL_TRIALS + 1
--	WHERE
--		ID = EXPERIMENT_ID;
END;
$$
LANGUAGE PLPGSQL;
