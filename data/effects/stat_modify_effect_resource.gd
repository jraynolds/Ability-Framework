extends EffectResource
## An EffectResource that modifies an Entity's Stat.
class_name StatModifyEffectResource

 ## An optional targeting resource to use for this effect. If left empty, affects the Ability's targets.
@export var targeting_resource_override : TargetingResource
@export var stat_type : StatResource.StatType ## The Stat this Effect adds to.
@export var modifier : ValueResource ## The value that will modify the Stat.
@export var math_operation : Math.Operation ## The type of mathematics operation we'll perform.
@export var ignore_statuses : bool ## Whether we should find the base stat value, no matter the target's ongoing StatusEffects.
@export var ignore_transforms : bool ## Whether we should modify the base stat, bypassing the target's Transforms.

## Called when an Effect containing this Resource affects targets.
## Adds the given value to the given targets' given stats.
func on_affect(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]):
	#print(
		#"Affecting " + Natives.enum_name(Targeting.Target, entity_target) + 
		#"'s " + Natives.enum_name(StatResource.StatType, stat_type) +
		#" with " + Natives.enum_name(Math.Operation, math_operation)
	#)
	
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(caster, ability)
	
	for target in targets:
		target.stats_component.modify_stat_value(
			stat_type,
			modifier.get_value(caster, targets),
			effect,
			math_operation,
			ignore_statuses,
			ignore_transforms
		)
		#var new_stat_value = get_modified_value(
			#stat_target.stats_component.get_stat_value(stat_type, ignore_modifiers),
			#caster,
			#targets
		#)
		#print(stat_target.title + "'s new value is " + str(new_stat_value))
		#stat_target.stats_component.set_stat_value(stat_type, new_stat_value)


## Returns what our modification to the given value would result in.
func get_modified_value(value: float, caster: Entity, targets: Array[Entity]) -> float:
	var value_modifier = modifier.get_value(caster, targets)
	DebugManager.debug_log(
		"Transforming the value " + str(value) + " using " + str(value_modifier) +
		" with operation " + Natives.enum_name(Math.Operation, math_operation)
	, self)
	var value_modified = Math.perform_operation(value, value_modifier, math_operation)
	DebugManager.debug_log(
		"Original value " + str(value) + " has become " + str(value_modified)
	, self)
	return value_modified
	
