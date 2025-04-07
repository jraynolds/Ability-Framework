extends Resource
## A Resource representing a value. Not meant to be mutated in runtime.
class_name ValueResource

@export var is_int : bool ## Whether or not this value is an integer.
## If this Value should output an integer, the rounding method it should use. By default, floor.
@export var rounding_behavior : Math.Rounding = Math.Rounding.Floor

## Returns a calculated value.
func get_value(caster: Entity, targets: Array[Entity]) -> float:
	return NAN
