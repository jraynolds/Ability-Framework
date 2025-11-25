extends Resource
class_name TargetingResource
## Base class for a resource that, given information, finds targets.

## Base, overloadable function for retrieving targets for this Ability.
func get_targets(_caster: Entity, _ability: Ability=null, _effect=null) -> Array[Entity]:
	return []
