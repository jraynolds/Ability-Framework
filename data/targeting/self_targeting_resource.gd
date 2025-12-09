extends TargetingResource
## Base class for a resource that, given the caster, finds itself as a target.
class_name SelfTargetingResource

## Returns the caster as its target.
func get_targets(effect_info: EffectInfo, overrides: Dictionary={}) -> Array[Entity]:
	#var effect : Effect = overrides.effect if "effect" in overrides else effect_info.effect
	#var ability : Ability = overrides.ability if "ability" in overrides else effect_info.ability
	var caster : Entity = overrides.caster if "caster" in overrides else effect_info.caster
	#var targets : Array[Entity] = overrides.targets if "targets" in overrides else effect_info.targets
	#if targeting_resource_override:
		#targets = targeting_resource_override.get_targets(effect_info, overrides)
		#overrides.targets = targets
	
	return [caster]
