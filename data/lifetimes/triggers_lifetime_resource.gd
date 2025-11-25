extends LifetimeResource
## A LifetimeResource that counts down triggers until it's finished.
class_name TriggersLifetimeResource

@export var triggers : ValueResource ## Number of triggers before it's finished.

## Returns whether this DurationLifetimeResource is expired. Returns true if the duration is greater than ours.
func is_lifetime_expired(caster: Entity, targets: Array[Entity], _time_alive: float, times_triggered: float):
	return times_triggered > triggers.get_value(caster, targets)
