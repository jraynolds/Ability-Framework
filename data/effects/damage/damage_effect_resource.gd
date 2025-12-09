extends EffectResource
## An EffectResource that reduces the target's HP based on the caster's Stats.
class_name DamageEffectResource

@export var damage_amount : ValueResource ## The amount of damage we'll do. By default, the caster's attack stat.
@export var damage_type : ValueResource ## The type of damage. By default, physical.
enum DamageType {
	Physical,
	Fire,
	Ice,
	Lightning,
	Acid,
	None
}
@export var ignore_caster_statuses : bool ## Whether we should find the base stat value, no matter the caster's ongoing StatusEffects.
@export var ignore_target_statuses : bool ## Whether we should find the base stat value, no matter the target's ongoing StatusEffects.
@export var ignore_transforms : bool ## Whether we should modify the base stat, bypassing the target's Transforms.

## Called when an Effect containing this Resource affects targets.
## Deals our amount of damage of our type to the targets.
func on_affect(effect_info: EffectInfo, overrides: Dictionary={}):	
	#var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(effect_info, overrides)
		overrides.targets = targets
	
	#print(
		#"Affecting " + Natives.enum_name(Targeting.Target, entity_target) + 
		#"'s " + Natives.enum_name(StatResource.StatType, stat_type) +
		#" with " + Natives.enum_name(Math.Operation, math_operation)
	#)
	
	var damage_dealt = get_damage_dealt(effect_info, overrides)
	var damage_dealt_type = get_damage_type(effect_info, overrides)
	
	for target in targets:
		target.stats_component.take_damage(
			damage_dealt,
			damage_dealt_type,
			effect_info,
			overrides,
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

## Returns the amount of damage this effect does. If none is set, it does an amount equal to the caster's Attack.
func get_damage_dealt(effect_info: EffectInfo, overrides: Dictionary={}) -> float:
	#var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	#var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	#if targeting_resource_override:
		#targets = targeting_resource_override.get_targets(effect_info, overrides)
		#overrides.targets = targets
	
	if damage_amount:
		return damage_amount.get_value(effect_info, overrides)
	return caster.stats_component.get_stat_value(StatResource.StatType.Attack)
	
	
## Returns the type of damage this effect does. If none is set, it does physical.
func get_damage_type(effect_info: EffectInfo, overrides: Dictionary={}) -> DamageType:
	return damage_type.get_value_int(effect_info, overrides) as DamageType if damage_type else DamageType.Physical

### Returns what our modification to the given value would result in.
#func get_modified_value(value: float, caster: Entity, targets: Array[Entity]) -> float:
	#var value_modifier = modifier.get_value(caster, targets)
	#DebugManager.debug_log(
		#"Transforming the value " + str(value) + " using " + str(value_modifier) +
		#" with operation " + Natives.enum_name(Math.Operation, math_operation)
	#, self)
	#var value_modified = Math.perform_operation(value, value_modifier, math_operation)
	#DebugManager.debug_log(
		#"Original value " + str(value) + " has become " + str(value_modified)
	#, self)
	#return value_modified
	#
