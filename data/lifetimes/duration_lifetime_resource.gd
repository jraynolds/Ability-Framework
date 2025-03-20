extends LifetimeResource
## A LifetimeResource that counts down active game time until it's finished.
class_name DurationLifetimeResource

@export var duration : ValueResource ## Duration in seconds.

## Returns whether this DurationLifetimeResource is expired. Returns true if the duration is greater than ours.
func is_lifetime_expired(caster: Entity, targets: Array[Entity], time_alive: float, times_triggered: int):
	return time_alive > duration.get_value(caster, targets)
