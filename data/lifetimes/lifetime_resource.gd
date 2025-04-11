extends Resource
## A Resource representing an Effect's lifetime. Not meant to be mutated in runtime.
class_name LifetimeResource

@export var title : String ## The title of this Lifetime.
@export_multiline var description : String ## The description of this Lifetime.

## Returns whether this LifetimeResource is expired. Returns true by default.
func is_lifetime_expired(caster: Entity, targets: Array[Entity], time_alive: float, times_triggered: float):
	return true
