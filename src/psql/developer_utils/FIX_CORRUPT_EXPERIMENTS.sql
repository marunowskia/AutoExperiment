select
	fill_in_missing_parameters(e.id)
from
	experiment e
join
	experiment_group eg
on
	e.experiment_group_id
	=
	eg.id
join
	experiment_script es
on
	es.id = eg.experiment_script_id
join
	parameter_group pg
on
	pg.id = es.parameter_group_id
join
	parameter_type pt
on
	pt.parameter_group_id = pg.id
left join
	parameter p
on
	p.parameter_type_id = pt.id
and
	p.experiment_id = e.id
where
	p.id is null
