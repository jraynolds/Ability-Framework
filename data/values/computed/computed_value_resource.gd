extends ValueResource
## A ValueResource that returns the result of a series of ValueResources, combined using the given math operation.
class_name ComputedValueResource

@export var values : Array[ValueResource] ## The values that will be combined.
## The math operation that will be used to combine the values. By default, multiplication.
@export var math_operation : Math.Operation = Math.Operation.Multiplication

## Returns a value calculated from the given values, combined with the given operation.
func get_value(caster: Entity, targets: Array[Entity]) -> float:
	assert(!values.is_empty(), "There are no values for us to calculate!")
	var end_value = values[0].get_value(caster, targets)
	for value in values:
		Math.perform_operation(end_value, value.get_value(caster, targets), math_operation)
	return end_value
