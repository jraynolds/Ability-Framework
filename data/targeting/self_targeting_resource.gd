extends TargetingResource
class_name SelfTargetingResource
## Base class for a resource that, given the caster, finds itself as a target.

## Returns the caster as its target.
func get_targets(caster: Entity, ability: Ability=null, effect=null) -> Array[Entity]:
	return [caster]
