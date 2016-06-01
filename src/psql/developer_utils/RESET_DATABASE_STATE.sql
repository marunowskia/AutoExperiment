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
	-- TODO: AUTOCOMPUTE MEAN_SCORE
	MEAN_SCORE REAL NOT NULL DEFAULT 0,
	NET_SCORE REAL NOT NULL DEFAULT 0,
	TOTAL_TRIALS INT NOT NULL DEFAULT 0,
	EXPERIMENT_PARENT_ALPHA BIGINT REFERENCES EXPERIMENT(ID),
	EXPERIMENT_PARENT_BETA BIGINT REFERENCES EXPERIMENT(ID),
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
	100, --STARTING_POPULATION_SIZE,
	100, --NUMBER_OF_RECENT_CONTENDERS,
	10, --NUMBER_OF_RANDOM_CONTENDERS,
	10, --NUMBER_OF_BEST_CONTENDERS,
	3, --PERFORMANCE_BIAS,
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

INSERT INTO EXPERIMENT_SCRIPT
(
	ID,
	SCRIPT,
	PARAMETER_GROUP_ID,
	LAUNCHER
)
VALUES
(
	'DUMMY_FOR_TESTING',
	'DUMMY_FOR_TESTING',
	-1,
	'DUMMY_FOR_TESTING'
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
	-3000,
	3000
),
(
	-1,
	'X',
	-3000,
	3000
),
(
	-1,
	'Y',
	-3000,
	3000
),
(
	-1,
	'Z',
	-3000,
	3000
);