extends Node
## The runtime instance of an StatResource.
class_name Stat

## The base resource of this Stat. Changing it creates instance copies of many of its fields.
var _resource : StatResource :
	set(val):
		_resource = val
		_title = _resource.title
		_type = _resource.type
		_description = _resource.description
		_is_int = _resource.is_int
		_rounding_behavior = _resource.rounding_behavior
		_maximum = _resource.maximum
		_minimum = _resource.minimum
var _title : String ## The title of this Stat.
var _type : StatResource.StatType ## The type of this Stat.
var _description : String ## The description for this Stat's purpose.
var _is_int : bool ## Whether this Stat is an integer.
## If this Value should output an integer, the rounding method it should use.
var _rounding_behavior : Math.Rounding
var _maximum : float = 9999 ## The maximum allowed value of this Stat.
var _minimum : float = -9999 ## The minimum allowed value of this Stat.

var _value : float ## The value of this Stat.
var value : float : ## Get/Setter for the value. Changing it emits on_value_change.
	get :
		return _value
	set(val):
		var old_val = _value
		val = clampf(val, _minimum, _maximum)
		_value = val
		on_value_change.emit(_value, old_val)

signal on_value_change(new_val: float, old_val: float) ## Emitted when this Stat's value changes.

## Constructor.
func from_resource(resource: StatResource, val: float) -> Stat:
	_resource = resource
	_value = val
	return self

## Returns the value of this Stat, rounded if it's an integer.
func get_value() -> float:
	if not _is_int:
		return _value
	else :
		match _rounding_behavior:
			Math.Rounding.Floor:
				return floori(_value)
			Math.Rounding.Nearest:
				return roundi(_value)
			Math.Rounding.Ceiling:
				return ceili(_value)
	assert(false, "How did we get here?")
	return -1


## Adds the given amount to the Stat.
func add_value(addition: float):
	value += addition


## Multiplies the Stat by the given value.
func multiply_value(multiplier: float):
	value *= multiplier


## Sets the Stat to the given value.
func set_value(new_value: float):
	value = new_value
