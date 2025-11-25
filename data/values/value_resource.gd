extends Resource
## A Resource representing a value. Not meant to be mutated in runtime.
class_name ValueResource

@export var is_int : bool ## Whether or not this value is an integer.
## If this Value should output an integer, the rounding method it should use. By default, floor.
@export var rounding_behavior : Math.Rounding = Math.Rounding.Floor

## Returns a calculated value.
func get_value(_caster: Entity, _targets: Array[Entity]) -> float:
	return NAN


## Returns a calculated value as an int.
func get_value_int(_caster: Entity, _targets: Array[Entity]) -> int:
	return int(get_value(_caster, _targets))
