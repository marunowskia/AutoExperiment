DROP TABLE PARAMETER;
DROP TABLE PARAMETER_TYPE;

DROP TABLE RESULT;
DROP TABLE EXPERIMENT;

DROP TABLE EXPERIMENT_GROUP;
DROP TABLE GROUP_CONFIG;
DROP TABLE EXPERIMENT_SCRIPT;
DROP TABLE PARAMETER_GROUP;

 CREATE TABLE GROUP_CONFIG
 (
 	
	ID CHARACTER VARYING(128) PRIMARY KEY,
 	STARTING_POPULATION_SIZE INT NOT NULL,
 	NUMBER_OF_RECENT_CONTENDERS INT NOT NULL,
 	NUMBER_OF_RANDOM_CONTENDERS INT NOT NULL,
 	NUMBER_OF_BEST_CONTENDERS INT NOT NULL,
 	PERFORMANCE_BIAS REAL NOT NULL,
 	RESAMPLE_BIAS REAL NOT NULL,
 	RESAMPLE_PROBABILITY REAL NOT NULL,
 	CREATED TIMESTAMP NOT NULL DEFAULT NOW(),
 	MODIFIED TIMESTAMP NOT NULL DEFAULT NOW()
 );


CREATE TABLE PARAMETER_GROUP
(
	ID CHARACTER VARYING (128) PRIMARY KEY,
	CREATED TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE EXPERIMENT_SCRIPT
(
	ID CHARACTER VARYING (128) PRIMARY KEY,
	SCRIPT TEXT NOT NULL,
	PARAMETER_GROUP_ID CHARACTER VARYING(128) NOT NULL REFERENCES PARAMETER_GROUP(ID),
	LAUNCHER TEXT NOT NULL,
	ALLOWED_DURATION_SECONDS INT NOT NULL,
	CREATED TIMESTAMP NOT NULL DEFAULT NOW(),
	MODIFIED TIMESTAMP NOT NULL DEFAULT NOW ()
);

CREATE TABLE EXPERIMENT_GROUP
(
	ID BIGSERIAL PRIMARY KEY,
	GROUP_CONFIG_ID CHARACTER VARYING (128) NOT NULL REFERENCES GROUP_CONFIG(ID),
	MAX_EXPERIMENT_COUNT BIGINT NOT NULL,
	EXPERIMENT_SCRIPT_ID CHARACTER VARYING (128) REFERENCES EXPERIMENT_SCRIPT(ID),
	CREATED TIMESTAMP NOT NULL DEFAULT NOW(),
	MODIFIED TIMESTAMP NOT NULL DEFAULT NOW()
);



CREATE TABLE EXPERIMENT
(
	ID BIGSERIAL PRIMARY KEY,
	EXPERIMENT_GROUP_ID BIGINT NOT NULL REFERENCES EXPERIMENT_GROUP(ID),
	MEAN_SCORE REAL NOT NULL DEFAULT 0,
	NET_SCORE REAL NOT NULL DEFAULT 0,
	TOTAL_TRIALS INT NOT NULL DEFAULT 0,
	EXPERIMENT_PARENT_ALPHA BIGINT REFERENCES EXPERIMENT(ID),
	EXPERIMENT_PARENT_BETA BIGINT REFERENCES EXPERIMENT(ID),
	NEXT_RUN TIMESTAMP NOT NULL DEFAULT NOW(),
	CREATED TIMESTAMP NOT NULL DEFAULT NOW(),
	MODIFIED TIMESTAMP NOT NULL DEFAULT NOW()
	
);

CREATE TABLE RESULT
(
	ID BIGSERIAL PRIMARY KEY,
	EXPERIMENT_ID BIGINT NOT NULL REFERENCES EXPERIMENT(ID),
	SCORE REAL NOT NULL,
	DATA TEXT,
	CREATED TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE PARAMETER_TYPE
(
	ID BIGSERIAL PRIMARY KEY,
	PARAMETER_GROUP_ID CHARACTER VARYING (128) NOT NULL REFERENCES PARAMETER_GROUP(ID),
	NAME CHARACTER VARYING(1000),
	MIN_VALUE REAL,
	MAX_VALUE REAL,
	CREATED TIMESTAMP NOT NULL DEFAULT NOW(),
	MODIFIED TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE PARAMETER
(
	ID BIGSERIAL PRIMARY KEY,
	EXPERIMENT_ID BIGINT REFERENCES EXPERIMENT(ID),
	PARAMETER_TYPE_ID BIGINT REFERENCES PARAMETER_TYPE(ID),
	PARAMETER_VALUE REAL NOT NULL,
	
	CREATED TIMESTAMP NOT NULL DEFAULT NOW()
);



INSERT INTO PARAMETER_GROUP
(
	ID
)
VALUES
(
	-1 -- USED FOR TESTING
);

INSERT INTO GROUP_CONFIG
(
	ID,
	STARTING_POPULATION_SIZE,
 	NUMBER_OF_RECENT_CONTENDERS,
 	NUMBER_OF_RANDOM_CONTENDERS,
 	NUMBER_OF_BEST_CONTENDERS,
 	PERFORMANCE_BIAS,
 	RESAMPLE_BIAS,
 	RESAMPLE_PROBABILITY
 )
VALUES
(
	'BASIC_DETERMINISTIC', --ID,
	10, --STARTING_POPULATION_SIZE,
	20, --NUMBER_OF_RECENT_CONTENDERS,
	10, --NUMBER_OF_RANDOM_CONTENDERS,
	3, --NUMBER_OF_BEST_CONTENDERS,
	2, --PERFORMANCE_BIAS,
	0, --RESAMPLE_BIAS,
	0 --RESAMPLE_PROBABILITY
),
(
	'BASIC_STOCHASTIC', --ID,
	100, --STARTING_POPULATION_SIZE,
	100, --NUMBER_OF_RECENT_CONTENDERS,
	10, --NUMBER_OF_RANDOM_CONTENDERS,
	10, --NUMBER_OF_BEST_CONTENDERS,
	3, --PERFORMANCE_BIAS,
	10, --RESAMPLE_BIAS,
	.1 --RESAMPLE_PROBABILITY
);
/*
INSERT INTO EXPERIMENT_SCRIPT
(
	ID,
	SCRIPT,
	PARAMETER_GROUP_ID,
	LAUNCHER,
	ALLOWED_DURATION_SECONDS
)
VALUES
(
	'DUMMY_FOR_TESTING',
	'DUMMY_FOR_TESTING',
	-1,
	'DUMMY_FOR_TESTING',
	20
);

INSERT INTO EXPERIMENT_GROUP
(
	GROUP_CONFIG_ID,
	MAX_EXPERIMENT_COUNT,
	EXPERIMENT_SCRIPT_ID
)
VALUES
(
	'BASIC_DETERMINISTIC',
	100000,
	'DUMMY_FOR_TESTING'
);

INSERT INTO PARAMETER_TYPE
(
	PARAMETER_GROUP_ID,
	NAME,
	MIN_VALUE,
	MAX_VALUE
)
VALUES
(
	-1,
	'W',
	5,
	-5
),
(
	-1,
	'X',
	5,
	-5
),
(
	-1,
	'Y',
	5,
	-5
),
(
	-1,
	'Z',
	5,
	-5
);


*/



CREATE OR REPLACE FUNCTION COMPUTE_BIAS_COEFFICIENT(BIAS INT) RETURNS REAL
AS
$$
DECLARE COEFFICIENT REAL DEFAULT 1;
BEGIN
	FOR I IN 1 .. BIAS LOOP
		COEFFICIENT = COEFFICIENT * RANDOM();
	END LOOP;
	RETURN COEFFICIENT;
END
$$
LANGUAGE PLPGSQL;



CREATE OR REPLACE FUNCTION FILL_IN_MISSING_PARAMETERS(PARAM_EXPERIMENT_ID BIGINT) RETURNS VOID
AS
$$
BEGIN
	INSERT INTO PARAMETER
	(
		EXPERIMENT_ID,
		PARAMETER_TYPE_ID,
		PARAMETER_VALUE
	)
	SELECT
		E.ID,
		PT.ID,
		(RANDOM()) * (PT.MAX_VALUE - PT.MIN_VALUE) + PT.MIN_VALUE
	FROM
		EXPERIMENT E
	JOIN
		EXPERIMENT_GROUP EG
	ON
		E.EXPERIMENT_GROUP_ID = EG.ID
	JOIN
		EXPERIMENT_SCRIPT ES
	ON
		ES.ID = EG.EXPERIMENT_SCRIPT_ID
	JOIN
		PARAMETER_GROUP PG
	ON
		PG.ID = ES.PARAMETER_GROUP_ID
	JOIN
		PARAMETER_TYPE PT
	ON
		PT.PARAMETER_GROUP_ID = PG.ID
	LEFT JOIN
		PARAMETER P
	ON
		P.PARAMETER_TYPE_ID = PT.ID
	AND
		P.EXPERIMENT_ID = E.ID
	WHERE
		E.ID = PARAM_EXPERIMENT_ID
	AND
		P.ID IS NULL;
	
END
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION GENERATE_NEW_EXPERIMENT(EXPERIMENT_GROUP_ID BIGINT) RETURNS BIGINT
AS
$$
DECLARE EXPERIMENT_PARENT_ALPHA BIGINT;
DECLARE EXPERIMENT_PARENT_BETA BIGINT;
BEGIN

	SELECT 
		GPFGP.EXPERIMENT_PARENT_ALPHA,
		GPFGP.EXPERIMENT_PARENT_BETA
	INTO
		EXPERIMENT_PARENT_ALPHA,
		EXPERIMENT_PARENT_BETA
	FROM
		GET_PARENTS_FROM_GENE_POOL(EXPERIMENT_GROUP_ID) GPFGP;

	RAISE NOTICE 'PARENTS: %, %' , EXPERIMENT_PARENT_ALPHA, EXPERIMENT_PARENT_BETA;
	RETURN 
		RECOMBINE_AND_MUTATE(EXPERIMENT_GROUP_ID, EXPERIMENT_PARENT_ALPHA, EXPERIMENT_PARENT_BETA);
END
$$
LANGUAGE PLPGSQL;


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

--	RAISE NOTICE 'CREATEING % EXPERIMENTS' , EXPERIMENTS_TO_CREATE;

	IF EXPERIMENTS_TO_CREATE > 0 THEN

		INSERT INTO EXPERIMENT ( EXPERIMENT_GROUP_ID)
		VALUES ( PARAM_EXPERIMENT_GROUP_ID )
		RETURNING ID INTO NEWLY_CREATED_EXPERIMENT_ID;
		
		PERFORM FILL_IN_MISSING_PARAMETERS(NEWLY_CREATED_EXPERIMENT_ID);
		
		-- SAFE, BUT I/O HEAVY WAY TO GUARANTEE WE DON'T OVERFILL THE STARTING POPULATION FOR THIS EXPERIMENT_GROUP
		PERFORM GENERATE_SEED_EXPERIMENTS(PARAM_EXPERIMENT_GROUP_ID); 
		
	END IF;
END
$$
LANGUAGE PLPGSQL;	

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
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GET_BEST_EXPERIMENTS(PARAM_EXPERIMENT_GROUP_ID BIGINT, PARAM_NUM_TO_RETURN INT ) RETURNS TABLE (EXPERIMENT_ID BIGINT, SCORE REAL)
AS
$$
	SELECT
		E.ID AS EXPERIMENT_ID,
		E.MEAN_SCORE
	FROM
		EXPERIMENT E
	WHERE
		E.EXPERIMENT_GROUP_ID = PARAM_EXPERIMENT_GROUP_ID
	AND
		TOTAL_TRIALS > 0
	ORDER BY
		E.MEAN_SCORE DESC
	LIMIT
		PARAM_NUM_TO_RETURN;
$$
LANGUAGE SQL;



CREATE OR REPLACE FUNCTION GET_RANDOM_EXPERIMENTS(PARAM_EXPERIMENT_GROUP_ID BIGINT, NUMBER_TO_RETURN INT) 
RETURNS TABLE (EXPERIMENT_ID BIGINT, SCORE REAL)
AS
$$
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
		-- VERY SLOW FOR LARGE EXPERIMENT_GROUPS.
		-- ALTERNATIVE APPROACH: ONLY ALLOW A SINGLE EXPERIMENT_GROUP TO BE ACTIVE AT A TIME, ENSURING CONTIGUOUS EXPERIMENT.ID VALUES. 
		-- GIVEN CONTIGUOUS IDS, SIMPLY COMPUTE A RANBDOM ID VIA RANDOM() * (THE NUMBER OF EXPERIMENTS IN THE GROUP)
$$
LANGUAGE SQL;






CREATE OR REPLACE FUNCTION GET_RECENT_EXPERIMENTS(PARAM_EXPERIMENT_GROUP_ID BIGINT, PARAM_NUM_TO_RETURN INT ) RETURNS TABLE (EXPERIMENT_ID BIGINT, SCORE REAL)
AS
$$
	SELECT
		E.ID AS EXPERIMENT_ID,
		MEAN_SCORE AS SCORE
	FROM
		EXPERIMENT E
	WHERE
		E.EXPERIMENT_GROUP_ID = PARAM_EXPERIMENT_GROUP_ID
	AND
		TOTAL_TRIALS > 0
	ORDER BY E.ID DESC
		LIMIT PARAM_NUM_TO_RETURN;
$$
LANGUAGE SQL;

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


CREATE OR REPLACE FUNCTION GET_NEXT_EXPERIMENT() RETURNS BIGINT
AS
$$
DECLARE EXPERIMENT_GROUP_ID BIGINT;
BEGIN
	EXPERIMENT_GROUP_ID = GET_ACTIVE_EXPERIMENT_GROUP();
	RETURN GET_NEXT_EXPERIMENT(EXPERIMENT_GROUP_ID);
END
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION GET_NEXT_EXPERIMENT(PARAM_EXPERIMENT_GROUP_ID BIGINT) RETURNS BIGINT
AS
$$
DECLARE EXPERIMENT_GROUP_ID BIGINT;
DECLARE EXPERIMENT_ID BIGINT;
BEGIN
	EXPERIMENT_ID = GET_PENDING_EXPERIMENT(EXPERIMENT_GROUP_ID);
	IF EXPERIMENT_ID IS NULL THEN
		EXPERIMENT_ID = GENERATE_NEW_EXPERIMENT(PARAM_EXPERIMENT_GROUP_ID);
	END IF;
	RETURN EXPERIMENT_ID;
END
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION GET_PENDING_EXPERIMENT(PARAM_EXPERIMENT_GROUP_ID BIGINT) RETURNS BIGINT
AS 
$$
DECLARE EXPERIMENT_ID BIGINT;
BEGIN
	-- This query seems icky. Redo?
	UPDATE EXPERIMENT AS E 
	SET NEXT_RUN = NOW() + interval '1 second' * ES.ALLOWED_DURATION_SECONDS
	FROM EXPERIMENT_GROUP EG
	JOIN EXPERIMENT_SCRIPT ES
	ON ES.ID = EG.EXPERIMENT_SCRIPT_ID
	WHERE E.ID =
	(
		SELECT ID
		FROM EXPERIMENT 	
		WHERE TOTAL_TRIALS = 0
		AND NOW() > NEXT_RUN
		ORDER BY NEXT_RUN
		LIMIT 1
		FOR UPDATE OF EXPERIMENT
	
	)
	AND EG.ID = E.EXPERIMENT_GROUP_ID
	RETURNING E.ID INTO EXPERIMENT_ID;

	RETURN EXPERIMENT_ID;
END
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION GET_PARENTS_FROM_GENE_POOL(PARAM_EXPERIMENT_GROUP_ID BIGINT) RETURNS TABLE (EXPERIMENT_PARENT_ALPHA BIGINT, EXPERIMENT_PARENT_BETA BIGINT)
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
		EG.ID = PARAM_EXPERIMENT_GROUP_ID;

	CREATE TEMPORARY TABLE IF NOT EXISTS CANDIDATE_POOL (EXPERIMENT_ID BIGINT, SCORE REAL);
	TRUNCATE TABLE CANDIDATE_POOL; -- THIS NEEDS TO BE DONE IFTHIS FUNCTION IS CALLED MULTIPLE TIMES WITHIN A SINGLE SESSION/TRANSACTION
	
	INSERT INTO CANDIDATE_POOL(EXPERIMENT_ID, SCORE)
	SELECT
		GCP.EXPERIMENT_ID, 
		GCP.SCORE
	FROM
		GET_CANDIDATE_POOL
		(
			PARAM_EXPERIMENT_GROUP_ID,
			NUMBER_RECENT,
			NUMBER_BEST,
			NUMBER_RANDOM
		) GCP;


	SELECT
		COUNT(*) INTO CANDIDATE_POOL_SIZE
	FROM
		CANDIDATE_POOL;
		

	--RAISE NOTICE 'BIAS COEFF1: %, %', COMPUTE_BIAS_COEFFICIENT(PERFORMANCE_BIAS), COMPUTE_BIAS_COEFFICIENT(PERFORMANCE_BIAS);
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
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION RECOMBINE_AND_MUTATE(EXPERIMENT_GROUP_ID BIGINT, PARENT_EXPERIMENT_ALPHA BIGINT, PARENT_EXPERIMENT_BETA BIGINT) RETURNS BIGINT
AS
$$
DECLARE NEW_EXPERIMENT_ID BIGINT;
BEGIN
	-- CREATE THE NEW EXPERIMENT
	INSERT INTO EXPERIMENT
	(
		EXPERIMENT_GROUP_ID,
		EXPERIMENT_PARENT_ALPHA,
		EXPERIMENT_PARENT_BETA
	)
	VALUES
	(
		EXPERIMENT_GROUP_ID,
		PARENT_EXPERIMENT_ALPHA,
		PARENT_EXPERIMENT_BETA
	)
	RETURNING ID INTO NEW_EXPERIMENT_ID;
	
	INSERT INTO PARAMETER
	(
		EXPERIMENT_ID,
		PARAMETER_TYPE_ID,
		PARAMETER_VALUE
		
	)
	SELECT
		NEW_EXPERIMENT_ID,
		PAR_ALPHA.PARAMETER_TYPE_ID,
		-- RECOMBINE:
		CASE 
			WHEN RANDOM() < .5
			THEN PAR_ALPHA.PARAMETER_VALUE
			ELSE PAR_BETA.PARAMETER_VALUE
		END

		-- MUTATE, BASED ON MAGNITUDE OF DIFFERENCE BETWEEN PARENT VALUES
		+ (RANDOM())*(RANDOM()-.5) * (ABS(PAR_ALPHA.PARAMETER_VALUE - PAR_BETA.PARAMETER_VALUE)+0.00001)

	FROM
		EXPERIMENT EXP
	JOIN
		PARAMETER PAR_ALPHA
	ON
		PAR_ALPHA.EXPERIMENT_ID = EXP.EXPERIMENT_PARENT_ALPHA
	JOIN
		PARAMETER PAR_BETA
	ON
		PAR_BETA.EXPERIMENT_ID = EXP.EXPERIMENT_PARENT_BETA
	AND
		PAR_BETA.PARAMETER_TYPE_ID = PAR_ALPHA.PARAMETER_TYPE_ID
	WHERE
		EXP.ID = NEW_EXPERIMENT_ID;

	RETURN NEW_EXPERIMENT_ID;
		
END
$$
LANGUAGE PLPGSQL;


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


END;
$$
LANGUAGE PLPGSQL;



-- Workaround for python's default numeric type. Would like to look into how to avoid the need for this extra function.
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

END;
$$
LANGUAGE PLPGSQL;








CREATE OR REPLACE FUNCTION RESULT_AFTER_INSERT() RETURNS TRIGGER AS
$$
BEGIN
	UPDATE
		EXPERIMENT
	SET
		TOTAL_TRIALS = TOTAL_TRIALS + 1,
		NET_SCORE = NET_SCORE + NEW.SCORE,
		MEAN_SCORE = (NET_SCORE + NEW.SCORE) / (TOTAL_TRIALS+1)
	WHERE
		ID = NEW.EXPERIMENT_ID;
	RETURN NEW;

END
$$
LANGUAGE PLPGSQL;

CREATE TRIGGER RESULT_AFTER_INSERT AFTER INSERT ON RESULT
FOR EACH ROW
WHEN (PG_TRIGGER_DEPTH() = 0)
EXECUTE PROCEDURE RESULT_AFTER_INSERT();




/*CREATE OR REPLACE FUNCTION GET_NEXT_EXPERIMENT(PARAM_EXPERIMENT_GROUP_ID BIGINT) RETURNS BIGINT
AS
$$
DECLARE EXPERIMENT_ID BIGINT;
BEGIN





	-- This query seems icky. Redo?
	UPDATE EXPERIMENT AS E 
	SET NEXT_RUN = NOW() + interval '1 second' * ES.ALLOWED_DURATION_SECONDS
	FROM EXPERIMENT_GROUP EG
	JOIN EXPERIMENT_SCRIPT ES
	ON ES.ID = EG.EXPERIMENT_SCRIPT_ID
	WHERE E.ID =
	(
		SELECT ID
		FROM EXPERIMENT 	
		WHERE TOTAL_TRIALS = 0
		AND NOW() > NEXT_RUN
		ORDER BY NEXT_RUN
		LIMIT 1
		FOR UPDATE OF EXPERIMENT
	
	)
	AND EG.ID = E.EXPERIMENT_GROUP_ID
	RETURNING E.ID INTO EXPERIMENT_ID;

	IF EXPERIMENT_ID IS NULL THEN
		RETURN GENERATE_NEW_EXPERIMENT();
	END IF;
	
	RETURN EXPERIMENT_ID;
END
$$
LANGUAGE PLPGSQL;*/




CREATE OR REPLACE FUNCTION BASIC_OPTIMALITY_CHECK() RETURNS INT
AS
$$
DECLARE EXPERIMENT_GROUP_ID BIGINT;
DECLARE EXPERIMENTS_TO_PERFORM INT;
DECLARE CURRENT_EXPERIMENT BIGINT;

DECLARE TARGET_W REAL DEFAULT 10;
DECLARE TARGET_X REAL DEFAULT 1024.1024;
DECLARE TARGET_Y REAL DEFAULT -50;
DECLARE TARGET_Z REAL DEFAULT -256.1286432168421;

DECLARE W REAL;
DECLARE X REAL;
DECLARE Y REAL;
DECLARE Z REAL;

	
BEGIN

	SELECT GET_ACTIVE_EXPERIMENT_GROUP() INTO EXPERIMENT_GROUP_ID;
	--RAISE NOTICE 'ACTIVE EXPERIMENT GROUP ID = %', EXPERIMENT_GROUP_ID;


	-- HARD CODED DURING TESTING...
	SELECT 10000 INTO EXPERIMENTS_TO_PERFORM;
	
	FOR I IN 1 .. EXPERIMENTS_TO_PERFORM LOOP
-- 
-- 		RAISE NOTICE '
-- 
-- 
-- 		====
-- 		NEXT EXPERIMENT
-- 		====
-- 
-- 		';
		
		CURRENT_EXPERIMENT = GET_NEXT_EXPERIMENT(EXPERIMENT_GROUP_ID);

--		CURRENT_EXPERIMENT = GENERATE_NEW_EXPERIMENT(EXPERIMENT_GROUP_ID);
		
		SELECT
			HCPRTC.W,HCPRTC.X,HCPRTC.Y,HCPRTC.Z
		INTO	
			W,X,Y,Z
		FROM
			HACK_CONVERT_PARAMETER_ROWS_TO_COLUMNS(CURRENT_EXPERIMENT) HCPRTC;

		RAISE NOTICE 'W,X,Y,Z: %, %, %, %, %' ,W,X,Y,GET_PARAMETER_VALUE(CURRENT_EXPERIMENT, 'Z'), CURRENT_EXPERIMENT;
		
		PERFORM RECORD_EXPERIMENT_RESULT(CURRENT_EXPERIMENT, -HACK_GET_DISTANCE(W-TARGET_W, X-TARGET_X, Y-TARGET_Y, Z-TARGET_Z), 'NO DATA');
	END LOOP;


	RETURN CURRENT_EXPERIMENT;
END
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION HACK_GET_DISTANCE(DW REAL, DX REAL, DY REAL, DZ REAL)
RETURNS REAL
AS
$$
BEGIN
	RETURN DW * DW + DX * DX + DY * DY + DZ * DZ;
END
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION GET_PARAMETER_VALUE(PARAM_EXPERIMENT_ID BIGINT, PARAMETER_NAME CHARACTER VARYING(128))
RETURNS REAL
AS
$$

	SELECT
		PARAMETER_VALUE
	FROM
		EXPERIMENT E
	JOIN
		PARAMETER P
	ON
		P.EXPERIMENT_ID = E.ID
	JOIN
		PARAMETER_TYPE PT
	ON
		P.PARAMETER_TYPE_ID = PT.ID
	WHERE
		E.ID = PARAM_EXPERIMENT_ID
	AND
		PT.NAME = PARAMETER_NAME
$$
LANGUAGE SQL;

CREATE OR REPLACE FUNCTION HACK_CONVERT_PARAMETER_ROWS_TO_COLUMNS(EXPERIMENT_ID BIGINT) 
RETURNS TABLE 
(
	W REAL,
	X REAL,
	Y REAL,
	Z REAL
)
AS
$$
	SELECT
		GET_PARAMETER_VALUE(EXPERIMENT_ID, 'W') AS W,
		GET_PARAMETER_VALUE(EXPERIMENT_ID, 'X') AS X,
		GET_PARAMETER_VALUE(EXPERIMENT_ID, 'Y') AS Y,
		GET_PARAMETER_VALUE(EXPERIMENT_ID, 'Z') AS Z;

$$
LANGUAGE SQL;



create or replace function get_experiment_script(param_experiment_id bigint) returns text
as
$$
	select 
		es.script
	from
		experiment_script es
	join
		experiment_group eg
	on
		eg.experiment_script_id
		=
		es.id
	join
		experiment e
	on
		e.experiment_group_id = param_experiment_id
	where
		e.id = param_experiment_id
$$
language sql;

create or replace function get_experiment_parameters(param_experiment_id bigint) returns table
(
	name character varying (1000),
	paramter_value real
)
as
$$
	select
		name,
		parameter_value
	from
		experiment e 
	join
		parameter p
	on
		p.experiment_id = e.id
	join
		parameter_type pt
	on
		pt.id = p.parameter_type_id
	where
		e.id = param_experiment_id
$$
language sql;


select generate_seed_experiments(get_active_experiment_group());

INSERT INTO PARAMETER_GROUP
(
	ID
)
VALUES
(
	'NBODY_PARAMETER_GROUP'
);


INSERT INTO PARAMETER_TYPE
(
	PARAMETER_GROUP_ID,
	NAME,
	MIN_VALUE,
	MAX_VALUE
)
SELECT
	'NBODY_PARAMETER_GROUP',
	'' || GENERATE_SERIES || '.VX',
	-100,
	100
FROM
	GENERATE_SERIES(1,5)

UNION ALL
SELECT
	'NBODY_PARAMETER_GROUP',
	'' || GENERATE_SERIES || '.VY',
	-100,
	100
FROM
	GENERATE_SERIES(1,5)
UNION ALL
	SELECT
	'NBODY_PARAMETER_GROUP',
	'' || GENERATE_SERIES || '.VZ',
	-100,
	100
FROM
	GENERATE_SERIES(1,5);

INSERT INTO EXPERIMENT_SCRIPT
(
	ID,
	SCRIPT,
	LAUNCHER,
	PARAMETER_GROUP_ID,
	ALLOWED_DURATION_SECONDS
)
VALUES
(
	'NBODY_SCRIPT',
	'SCORE = PARAMETERDATA[''1.X'']]',
	'PYTHON',
	'NBODY_PARAMETER_GROUP',
	300
);

INSERT INTO EXPERIMENT_GROUP
(
	GROUP_CONFIG_ID,-- CHARACTER VARYING (128) NOT NULL REFERENCES GROUP_CONFIG(ID),
	MAX_EXPERIMENT_COUNT,-- BIGINT NOT NULL,
	EXPERIMENT_SCRIPT_ID-- CHARACTER VARYING (128) REFERENCES EXPERIMENT_SCRIPT(ID),
)
VALUES
(
	'BASIC_DETERMINISTIC',
	100000,
	'NBODY_SCRIPT'
);
select generate_seed_experiments(get_active_experiment_group());

