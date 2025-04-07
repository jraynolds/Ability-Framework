extends EffectResource
## An EffectResource that reduces the target's HP based on the caster's Stats.
class_name DamageEffectResource

## The Entity(s) this Effect affects. By default, all valid targets.
@export var entity_target : Targeting.Target = Targeting.Target.Targets 
## The caster's Stat the damage is calculated from. By default, Attack.
@export var stat_type : StatResource.StatType = StatResource.StatType.Attack
@export var modifier : ValueResource ## The value that will multiply the Stat.
@export var damage_type : DamageType ## The type of damage.
enum DamageType {
	Physical,
	Fire,
	Ice,
	Lightning,
	Acid,
	None
}
## The type of mathematics operation we'll perform on the Stat to find damage. By default, multiplication.
@export var math_operation : Math.Operation = Math.Operation.Multiplication
@export var ignore_caster_statuses : bool ## Whether we should find the base stat value, no matter the caster's ongoing StatusEffects.
@export var ignore_target_statuses : bool ## Whether we should find the base stat value, no matter the target's ongoing StatusEffects.
@export var ignore_transforms : bool ## Whether we should modify the base stat, bypassing the target's Transforms.

## Called when an Effect containing this Resource affects targets.
## reduces the calculated amount from the targets' HP.
func on_affect(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]):
	#print(
		#"Affecting " + Natives.enum_name(Targeting.Target, entity_target) + 
		#"'s " + Natives.enum_name(StatResource.StatType, stat_type) +
		#" with " + Natives.enum_name(Math.Operation, math_operation)
	#)
	
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
	
	var damage_dealt = Math.perform_operation(
		caster.stats_component.get_stat_value(stat_type, ignore_caster_statuses),
		modifier.get_value(caster, targets),
		math_operation,
	)
	
	for stat_target in stat_targets:
		stat_target.stats_component.take_damage(
			damage_dealt,
			damage_type,
			effect,
			ignore_target_statuses,
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
	
