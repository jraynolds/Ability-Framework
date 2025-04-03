extends ValueResource
## A ValueResource gathered from a Stat.
class_name StatValueResource

@export var stat_entity : Targeting.Target = Targeting.Target.Caster ## The Entity this Value takes the Stat from. By default, the caster.
@export var stat : StatResource.StatType ## The type of Stat this Value compares.
@export var amount : ValueResource ## The amount of the Stat this Value should return.
@export var ignore_statuses : bool ## Whether we should get the base stat instead of one modified by 

## Returns the value of the given Entity's given Stat, multiplied by the given amount.
func get_value(caster: Entity, targets: Array[Entity]) -> float:
	var value = 0
	match stat_entity :
		Targeting.Target.Target:
			assert(targets[0], "there is no target to take a stat value from")
			value = targets[0].stats_component.get_stat_value(stat, ignore_statuses)
		Targeting.Target.Caster:
			value = caster.stats_component.get_stat_value(stat, ignore_statuses)
	var amount_value = amount.get_value(caster, targets)
	return value * amount_value
