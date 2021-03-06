CREATE OR REPLACE FUNCTION GET_NEXT_EXPERIMENT() RETURNS BIGINT
AS
$$
DECLARE EXPERIMENT_GROUP_ID BIGINT;
DECLARE EXPERIMENT_ID BIGINT;
BEGIN
	SELECT EXPERIMENT_GROUP_ID = GET_ACTIVE_EXPERIMENT_GROUP();
	SELECT EXPERIMENT_ID = GET_NEXT_EXPERIMENT_FOR_GROUP(EXPERIMENT_GROUP_ID);
	IF EXPERIMENT_ID IS NULL THEN
		EXPERIMENT_ID = GENERATE_NEW_EXPERIMENT(EXPERIMENT_GROUP_ID);
	END IF;
	RETURN EXPERIMENT_ID;
END
$$
LANGUAGE PLPGSQL
