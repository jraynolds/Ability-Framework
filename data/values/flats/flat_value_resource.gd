extends ValueResource
## A ValueResource gathered from a given value. In other words, just a number.
class_name FlatValueResource

@export var value : float ## The value of this Value.

## Returns our value.
func calc_value(_effect_info: EffectInfo, _overrides: Dictionary={}) -> float:
	return value
