﻿
-- UNFINISHED

CREATE OR REPLACE FUNCTION BASIC_OPTIMALITY_CHECK() RETURNS INT
AS
$$
	-- HARD CODED VALUES THAT THE TEST EXPERIMENT_GROUP WILL TRY TO DISCOVER
	DECLARE TARGET_W FLOAT DEFAULT -3041.5289;
	DECLARE TARGET_X FLOAT DEFAULT  1052.1344;
	DECLARE TARGET_Y FLOAT DEFAULT  1569.5192;
	DECLARE TARGET_Z FLOAT DEFAULT -2323.5915;

	DECLARE GROUP_CONFIG CHARACTER VARYING(128);
	DECLARE PARAMETER_GROUP CHARACTER VARYING(128);
	DECLARE EXPERIMENT_GROUP_ID BIGINT;
BEGIN
	-- INTIAILIZE THE GROUP_CONFIG
	INSERT INTO GROUP_CONFIG
	(
	
	)
	VALUES
	(

	);

	-- INITIALIZE THE PARAMETER_GROUP
	INSERT INTO PARAMETER_GROUP
	(

	)
	VALUES
	(

	);
	
	
	-- INITIALIZE THE PARAMETER_TYPES
	INSERT INTO PARAMETER_TYPE
	(
		
	)
	VALUES
	--W
	(	
	
	), 
	--X
	(	

	),
	--Y
	(	

	),
	--Z
	(	

	)

	-- INITIALIZE THE EXPERIMENT_SCRIPT
	INSERT INTO EXPERIMENT_SCRIPT
	(

	)
	VALUES
	(
		
	)

	-- INITIALIZE THE EXPERIMENT_GROUP
	INSERT INTO EXPERIMENT_GROUP
	(
		
	)
	VALUES
	(

	);

	-- CREATE THE SEED EXPERIMENTS
	SELECT GENERATE_SEED_EXPERIMENTS();

	-- RUN THE EXPERIMENT TO COMPLETION
	
	-- VERIFY THE ACCURACY OF THE OUTCOME

	-- RETURN WHETHER OR NOT THE SYSTEM FOUND A GOOD SOLUTION
	RETURN 0;
	
END
$$
LANGUAGE plpgsql;