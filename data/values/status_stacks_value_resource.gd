extends ValueResource
## A ValueResource gathered from the target Entity's number of stacks for the matching effect.
class_name StatusStocksValueResource

 ## An optional targeting resource to use for this value getter. If left empty, takes from the first given target.
@export var targeting_resource_override : TargetingResource
@export var status_resource : EffectResource ## The Effect we're checking stacks for.

## Returns the number of stacks the given Entity has for the matching StatusEffect.
func calc_value(effect_info: EffectInfo, overrides: Dictionary={}) -> float:
	#var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(effect_info, overrides)
		overrides.targets = targets
	
	var matching_status = targets[0].statuses_component.get_status_by_resource(status_resource)
	if matching_status:
		return targets[0].statuses_component.get_status_stacks(matching_status)
	return NAN
