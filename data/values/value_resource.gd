extends Resource
## A Resource representing a value. Not meant to be mutated in runtime.
class_name ValueResource

@export var is_int : bool ## Whether or not this value is an integer.
## If this Value should output an integer, the rounding method it should use. By default, floor.
@export var rounding_behavior : Math.Rounding = Math.Rounding.Ceiling

## Returns a calculated value. Meant to be overloaded.
func get_value(caster: Entity, targets: Array[Entity]) -> float:
	var value = calc_value(caster, targets)
	if is_int:
		return val_to_int(value)
	return value
	
	
## Returns a calculated value as an int.
func get_value_int(caster: Entity, targets: Array[Entity]) -> int:
	var value = calc_value(caster, targets)
	return val_to_int(value)


## Returns the value calculated according to our purposes. Meant to be overloaded.
func calc_value(_caster: Entity, _targets: Array[Entity]) -> float:
	return 0.0


## Returns the calculated value as an int.
func val_to_int(value: float) -> int:
	DebugManager.debug_log(
		"Returning the value " + str(value) + " as an int with rounding behavior " +
		Natives.enum_name(Math.Rounding, rounding_behavior)
	, self)
	var val_int : int = 0
	match rounding_behavior:
		Math.Rounding.Floor:
			val_int = floori(value)
		Math.Rounding.Nearest:
			val_int = int(value)
		Math.Rounding.Ceiling:
			val_int = ceili(value)
	DebugManager.debug_log(
		"End value is " + str(value)
	, self)
	return val_int
