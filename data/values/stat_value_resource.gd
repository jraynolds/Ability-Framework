extends ValueResource
## A ValueResource gathered from a Stat.
class_name StatValueResource

## An optional targeting resource to use for this value getter. If left empty, takes from the first given target.
@export var targeting_resource_override : TargetingResource
@export var stat : StatResource.StatType ## The type of Stat this Value compares.
@export var amount : ValueResource ## The amount of the Stat this Value should return. By default, 100%.
@export var ignore_caster_statuses : bool ## Whether we should get the base stat instead of one modified by statuses.
@export var ignore_target_statuses : bool ## Whether we should get the base stat instead of one modified by statuses.

## Returns the value of the target Entity's Stat, multiplied by our amount. Optionally, ignores active statuses.
func calc_value(effect_info: EffectInfo, overrides: Dictionary={}) -> float:
	#var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(effect_info, overrides)
		overrides.targets = targets
	
	var value = 0
	value = caster.stats_component.get_stat_value(stat, ignore_caster_statuses)
	
	var amount_value = amount.get_value(effect_info, overrides) if amount else 1.0
	return value * amount_value
