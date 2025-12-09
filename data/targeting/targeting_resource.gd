extends Resource
## Base class for a resource that, given information, finds targets.
class_name TargetingResource

## Base, overloadable function for retrieving targets for this Ability.
func get_targets(_effect_info: EffectInfo, _overrides: Dictionary={}) -> Array[Entity]:
	return []
