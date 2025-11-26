extends EffectResource
## An EffectResource that modifies a keyword in an Entity.
class_name KeywordModifyEffectResource

@export var keyword : Keyword ## The keyword this Effect adds to.
enum Keyword { ## The list of keyword options for this Effect to affect.
	Targetable ## Whether the Entity is targetable by Effects
}
@export var modifier : ValueResource ## The value that will modify the keyword.
@export var math_operation : Math.Operation ## The type of mathematics operation we'll perform.
@export var ignore_statuses : bool ## Whether we should find the base stat value, no matter the target's ongoing StatusEffects.
@export var ignore_transforms : bool ## Whether we should modify the base stat, bypassing the target's Transforms.

## Called when an Effect containing this Resource affects targets.
## Adds the given value to the given targets' given stats.
func on_affect(_effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]):
	if targeting_override:
		targets = targeting_override.get_targets(caster, ability)
	
	print(
		"Affecting the keyword " + Natives.enum_name(Keyword, keyword) + 
		" of targets " + ", ".join(targets.map(func(t: Entity): return t.title)) + 
		" with " + str(modifier.get_value(caster, targets)) +
		" via " + Natives.enum_name(Math.Operation, math_operation) +
		(" ignoring statuses" if ignore_statuses else "") +
		(" ignoring transforms " if ignore_transforms else "")
	)
	
	assert(false, "I thought we weren't getting here!")
	
	#for target in targets:
		#match keyword:
			#Keyword.Targetable:
				#
		#target.stats_component.modify_stat_value(
			#stat_type,
			#modifier.get_value(caster, targets),
			#effect,
			#math_operation,
			#ignore_statuses,
			#ignore_transforms
		#)
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
		"Imagining what would happen if we transformed the value " + str(value) + " using " + str(value_modifier) +
		" with operation " + Natives.enum_name(Math.Operation, math_operation)
	, self)
	var value_modified = Math.perform_operation(value, value_modifier, math_operation)
	DebugManager.debug_log(
		"Original value " + str(value) + " would become " + str(value_modified)
	, self)
	return value_modified
	
