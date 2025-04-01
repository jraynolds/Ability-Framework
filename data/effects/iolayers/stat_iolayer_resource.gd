extends IOLayerResource
## An IOLayer Resource that transforms a given stat. Not meant to be mutated in runtime.
class_name StatIOLayerResource

@export var stat : StatResource.StatType ## The stat to be transformed.
@export var value : ValueResource ## The amount it's transformed by.
@export var value_mult_negative : bool ## Whether the value should be multiplied by -1.
@export var operation : Math.Operation ## The math operation the value modifies the input by.

## Modifies the given float and returns it. Meant to be overloaded.
func apply_layer(input: float, effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]) -> float:
	var val = value.get_value(caster, targets)
	if value_mult_negative:
		val *= -1
	match operation:
		Math.Operation.Addition:
			return input + val
		Math.Operation.Subtraction:
			return input - val
		Math.Operation.Multiplication:
			return input * val
		Math.Operation.Division:
			return input / val
		Math.Operation.Power:
			return pow(input, val)
	assert(false, "How did we get here?")
	return -1
