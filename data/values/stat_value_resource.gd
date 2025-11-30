extends ValueResource
## A ValueResource gathered from a Stat.
class_name StatValueResource

 ## An optional targeting resource to use for this value getter. If left empty, takes from the first given target.
@export var targeting_resource_override : TargetingResource
@export var stat : StatResource.StatType ## The type of Stat this Value compares.
@export var amount : ValueResource ## The amount of the Stat this Value should return. By default, 100%.
@export var ignore_caster_statuses : bool ## Whether we should get the base stat instead of one modified by statuses.
@export var ignore_target_statuses : bool ## Whether we should get the base stat instead of one modified by statuses.

## Returns the value of the given Entity's given Stat, multiplied by the given amount.
func calc_value(caster: Entity, targets: Array[Entity]) -> float:
	var value = 0
	
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(caster, null)
	value = caster.stats_component.get_stat_value(stat, ignore_caster_statuses)
	
	var amount_value = amount.get_value(caster, targets) if amount else 1.0
	return value * amount_value
