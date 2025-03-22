extends ValueResource
## A ValueResource gathered from a given value. In other words, just a number.
class_name FlatValueResource

@export var value : float ## The value of this Value.

## Returns the value of the given Entity's given Stat, multiplied by the given amount.
func get_value(caster: Entity, targets: Array[Entity]) -> float:
	return value
