extends ValueResource
class_name ComputedValueResource
## A ValueResource that returns the result of a series of ValueResources, combined using the given math operation.

@export var values : Array[ValueResource] ## The values that will be combined.
## The math operation that will be used to combine the values. By default, multiplication.
@export var math_operation : Math.Operation = Math.Operation.Multiplication

## Returns a value calculated from the given values, combined with the given operation.
func get_value(caster: Entity, targets: Array[Entity]) -> float:
	assert(!values.is_empty(), "There are no values for us to calculate!")
	DebugManager.debug_log(
		"Computing the values " + (",".join(values.map(func(v: ValueResource): return v.get_value(caster, targets)))) + 
		" with the math operation " + Natives.enum_name(Math.Operation, math_operation)
	, self)
	
	var end_value = values[0].get_value(caster, targets)
	for i in range(len(values)):
		if i == 0:
			continue
		end_value = Math.perform_operation(end_value, values[i].get_value(caster, targets), math_operation)
	
	DebugManager.debug_log(
		"End value is " + str(end_value)
	, self)
	return end_value
