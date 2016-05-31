﻿INSERT INTO GROUP_CONFIG
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