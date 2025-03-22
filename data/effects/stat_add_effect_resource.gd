extends EffectResource
## An EffectResource that adds to an Entity's Stat.
class_name StatAddEffectResource

## The Entity(s) this Effect affects. By default, all valid targets.
@export var entity_target : Targeting.Target = Targeting.Target.Targets 
@export var stat_type : StatResource.StatType ## The Stat this Effect adds to.
@export var addition : ValueResource ## The value that will be added to the Stat.
@export var negative : bool ## Whether the amount should be multiplied by -1 before it's added.
 
func affect(caster: Entity, targets: Array[Entity]):
	var addition_value = addition.get_value(caster, targets)
	print(addition_value)
	if negative:
		addition_value *= -1
	match entity_target :
		Targeting.Target.Targets:
			assert(targets[0], "There are no valid targets")
			for target in targets:
				target.stats_component.add_stat_value(stat_type, addition_value)
		Targeting.Target.Target:
			assert(targets[0], "There is no valid target")
			targets[0].stats_component.add_stat_value(stat_type, addition_value)
		Targeting.Target.Caster:
			caster.stats_component.add_stat_value(stat_type, addition_value)
