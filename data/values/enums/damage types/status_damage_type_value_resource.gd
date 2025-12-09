extends ValueResource
## A ValueResource that returns the int value of a DamageType enum found on a Status.
class_name StatusDamageTypeValueResource

 ## An optional targeting resource to use for this value getter. If left empty, takes from the first given target.
@export var targeting_resource_override : TargetingResource
@export var status : EffectResource ## The Status we're checking DamageType for.

## Returns the int value of the DamageType enum on the given target's StatusEffect.
func get_value(effect_info: EffectInfo, overrides: Dictionary={}) -> float:
	#var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	#var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	if targeting_resource_override:
		targets = targeting_resource_override.get_targets(effect_info, overrides)
		overrides.targets = targets
	
	var matching_status = targets[0].statuses_component.get_status_by_resource(status)
	if !matching_status:
		return NAN
	var damage_resource = matching_status._resource as DamageEffectResource
	assert(damage_resource, "We found the resource, but it's not a damage resource!")
	var damage_type = damage_resource.get_damage_type(effect_info, overrides)
	return damage_type
