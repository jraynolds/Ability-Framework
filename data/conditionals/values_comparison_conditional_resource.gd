extends ConditionalResource
## A ConditionalResource that compares two values. Not meant to be mutated in runtime.
class_name ValuesComparisonConditionalResource

@export var value_1 : ValueResource ## The value we're comparing.
@export var value_2 : ValueResource ## The value we're checking against.
@export var comparison : Math.Comparison = Math.Comparison.Equal ## The math comparison we're undertaking. By default, equality.

## Returns whether the ability caster last cast the given Ability.
func is_met(effect: Effect, ability: Ability, caster: Entity, targets: Array[Entity]) -> bool:
	match comparison:
		Math.Comparison.Equal:
			return value_1.get_value(caster, targets) == value_2.get_value(caster, targets)
		Math.Comparison.GreaterThan:
			return value_1.get_value(caster, targets) > value_2.get_value(caster, targets)
		Math.Comparison.GreaterThanOrEqual:
			return value_1.get_value(caster, targets) >= value_2.get_value(caster, targets)
		Math.Comparison.LessThan:
			return value_1.get_value(caster, targets) < value_2.get_value(caster, targets)
		Math.Comparison.LessThanOrEqual:
			return value_1.get_value(caster, targets) <= value_2.get_value(caster, targets)
	return false
