extends EffectResource
## An EffectResource that modifies an Entity's Stat.
class_name StatModifyEffectResource

## The Entity(s) this Effect affects. By default, all valid targets.
@export var entity_target : Targeting.Target = Targeting.Target.Targets 
@export var stat_type : StatResource.StatType ## The Stat this Effect adds to.
@export var modifier : ValueResource ## The value that will modify the Stat.
@export var math_operation : Math.Operation ## The type of mathematics operation we'll perform.
@export var ignore_modifiers : bool ## Whether we should modify the base stat, no matter the modified targets' stats.

## Called when an Effect containing this Resource affects targets.
## Adds the given value to the given targets' given stats.
func on_affect(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]):
	print(
		"Affecting " + Natives.enum_name(Targeting.Target, entity_target) + 
		"'s " + Natives.enum_name(StatResource.StatType, stat_type) +
		" with " + Natives.enum_name(Math.Operation, math_operation)
	)
	
	var stat_targets : Array[Entity] = []
	match entity_target :
		Targeting.Target.Targets:
			assert(targets[0], "There are no valid targets")
			stat_targets.append_array(targets)
		Targeting.Target.Target:
			assert(targets[0], "There is no valid target")
			stat_targets.append(targets[0])
		Targeting.Target.Caster:
			stat_targets.append(caster)
	
	for stat_target in stat_targets:
		var new_stat_value = get_modified_value(
			stat_target.stats_component.get_stat_value(stat_type, ignore_modifiers),
			caster,
			targets
		)
		print(stat_target.title + "'s new value is " + str(new_stat_value))
		stat_target.stats_component.set_stat_value(stat_type, new_stat_value)


## Returns what our modification to the given value would result in.
func get_modified_value(value: float, caster: Entity, targets: Array[Entity]) -> float:
	var value_modifier = modifier.get_value(caster, targets)
	match math_operation:
		Math.Operation.Addition:
			return value + value_modifier
		Math.Operation.Subtraction:
			return value - value_modifier
		Math.Operation.Multiplication:
			return value * value_modifier
		Math.Operation.Division:
			return value / value_modifier
		Math.Operation.Power:
			return pow(value, value_modifier)
	assert(false, "How did we get here?")
	return -1
	
