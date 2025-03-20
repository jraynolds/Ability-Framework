extends Node
## The runtime instance of a Value.
class_name Value

var _resource : ValueResource ## The base ValueResource this Value represents.
var _added_value : float ## An addition made after the value is calculated.
var _added_multiplication : float = 1.0 ## A multiplication made to the value, finally.

## Returns an instance of this initialized with the given ValueResource.
func from_resource(resource: ValueResource) -> Value:
	_resource = resource
	return self


## Returns the value of this Value added and multiplied by any additional values.
func get_value(caster: Entity, targets: Array[Entity]) -> float:
	var value = _resource.get_value(caster, targets)
	value += _added_value
	value *= _added_multiplication
	return value
