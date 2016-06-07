﻿INSERT INTO PARAMETER_GROUP
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
	'' || generate_series || '.vx',
	-100,
	100
FROM
	generate_series(1,5)

union all
SELECT
	'NBODY_PARAMETER_GROUP',
	'' || generate_series || '.vy',
	-100,
	100
FROM
	generate_series(1,5)
union all
	SELECT
	'NBODY_PARAMETER_GROUP',
	'' || generate_series || '.vz',
	-100,
	100
FROM
	generate_series(1,5);

INSERT INTO EXPERIMENT_SCRIPT
(
	ID,
	SCRIPT,
	LAUNCHER
)
VALUES
(
	'NBODY_SCRIPT',
	'score = parameterData[''1.x'']]',
	'python'
);

insert into experiment_group
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
)