extends ExpirationResource
## Resource for a conditional expiration on a StatusEffect that occurs after a given amount of time.
class_name DurationExpirationResource

@export var duration : ValueResource ## The magnitude of time before the StatusEffect will expire.

## Calls the end() function on the given Effect at the appropriate time.
func register(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]):
	pass


func time_is_expired(time_alive: float, caster: Entity, targets: Array[Entity]) -> bool:
	return time_alive > duration.get_value(caster, targets)
